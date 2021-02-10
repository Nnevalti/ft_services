BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
SET='\033[0m'

find_and_replace_cluster_ip
{
	# When installed docker creates 3 network. try : "docker network ls"
	# By default containers are connected to the Bridge docker0. Try : "ifconfig" (give information about the bridge network)
	# The command "docker network inspect bridge" give us information about docker0 in a JSON format
	# The option format specify that we want at the index IPAM.Config[0] the value of the Gateway. ex : "172.17.0.1"
	# command cut RTFM
	echo "${YELLOW}Finding an IP...:${SET}"
	HOST=`docker network inspect bridge --format='{{(index .IPAM.Config 0).Gateway}}' | cut -d . -f 4`
	NETWORK=`docker network inspect bridge --format='{{(index .IPAM.Config 0).Gateway}}' | cut -d . -f 1-2`
	CLUSTER_IP=${NETWORK}.0.$((HOST+1))
	echo "${GREEN} Cluster IP :${SET} $CLUSTER_IP"

	#replace and create external ip in config files
	echo " ${YELLOW}Replacing $CLUSTER_IP in templates files.${SET}"

	export CLUSTER_IP=$CLUSTER_IP
	RES=0
	envsubst '$CLUSTER_IP' < srcs/templates/metallb_configmap.yaml > srcs/config/metallb_configmap.yaml
	RES=$((RES+$?))

	# envsubst '$CLUSTER_IP' < srcs/templates/nginx_configmap.yaml > ./srcs/config/nginx_configmap.yaml
	# RES=$((RES+$?))
	# envsubst '$CLUSTER_IP' < srcs/templates/nginx.yaml > srcs/kubernetes/nginx.yaml
	# RES=$((RES+$?))
	# envsubst '$CLUSTER_IP' < srcs/templates/phpmyadmin.yaml > srcs/kubernetes/phpmyadmin.yaml
	# RES=$((RES+$?))
	# envsubst '$CLUSTER_IP' < srcs/templates/wordpress.yaml > srcs/kubernetes/wordpress.yaml
	# RES=$((RES+$?))

	# envsubst '$CLUSTER_EXTERNAL_IP' < srcs/templates_for_cluster_ip/grafana_configmap.yaml > ./srcs/configmaps/grafana_configmap.yaml
	# RES=$((RES+$?))
	# envsubst '$CLUSTER_EXTERNAL_IP' < srcs/templates_for_cluster_ip/ftps_deployment_svc.yaml > srcs/ftps/ftps_deployment_svc.yaml
	# RES=$((RES+$?))
	# envsubst '$CLUSTER_EXTERNAL_IP' < srcs/templates_for_cluster_ip/grafana_deployment_svc.yaml > srcs/grafana/grafana_deployment_svc.yaml
	# RES=$((RES+$?))

	if [ $? != 0 ]
	then
		echo "${RED}Error: failed to replce cluster IP in templates...${SET}" > /dev/stderr
		exit
	fi
	echo "${GREEN}Files succesfully created ! ✅${SET}"


}

minikube_start
{
	minikube status > /dev/null
	if [ $? -eq 0 ]
	then
		echo "${YELLOW}Minikube has already been started.${SET}"
		return
	fi
	# Retrieving Operating System (Kernel Name).
	OS=`uname -s`

	# Defining a custom range for minikube
	PORT_RANGE="--extra-config=apiserver.service-node-port-range=20-65535"

	echo "${YELLOW}Starting Minikube on \"$CURRENT_OS\"...${SET}"
	if [ $OS = "Linux" ]
	then
		minikube start --vm-driver=docker --cpus=2 $PORT_RANGE
	elif [ $OS = "Darwin" ]
	then
		minikube start --vm-driver=virtualbox --disk-size=3g --cpus=3 --memory=2448 $PORT_RANGE
	else
		echo "${RED}Error: Operation system: $OS: This script only handle Linux or Mac OS.${SET}"
		exit 1
	fi
	if [ $? -gt 0 ]
	then
		echo "${RED}Could not start minikube for $OS OS.${SET}"
		exit 1
	fi
	# Enable the dashboard
	minikube addons enable dashboard
}

metallb_setup
{
	# Setup MetalLB
	RES=0
	echo "${YELLOW}Setting up metallb...${SET}"
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/namespace.yaml 2>&1 > /dev/null
	RES=$((RES+$?))
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/metallb.yaml 2>&1 > /dev/null
	RES=$((RES+$?))
	kubectl get secret -n metallb-system memberlist  > /dev/null 2>&1
	if [ $? != 0 ]
	then
		kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)" 2>&1 > /dev/null
		RES=$((RES+$?))
	fi
	kubectl apply -f ./srcs/config/metallb_configmap.yaml
	RES=$((RES+$?))
	if [ $RES -gt 0 ]
	then
		echo "${RED}Error: could not setup metallb.${SET}"
		exit 1
	fi
}

build_docker_image
{
	eval $(minikube docker-env)
	echo "${YELLOW}Building Docker images...${SET}"
	for SERVICE in $LIST_SERVICES
	do
		echo -n "${YELLOW}🐳 ${SERVICE} container "
		docker build -t "$SERVICE"_container srcs/$SERVICE > /dev/null
		if [ $? != 0 ]
		then
			echo "❌"
			echo "${RED}Building for $SERVICE failed...${SET}"
			exit
		fi
		echo "✅"
	done
}

create_secrets
{
	echo "${YELLOW}Creating secrets...${SET}"
	kubectl apply -f srcs/config/secret_key.yaml > /dev/null
	if [ $? -gt 0 ]
	then
		echo "${RED}Error: could not create secrets${SET}"
		exit 1
	fi
}

create_configmap
{
	echo "${YELLOW} Creating configmap...${SET}"
	kubectl apply -f srcs/config/k8s_configmap.yaml
	if [ $? -gt 0 ]
	then
		echo "❌"
		echo "${RED}Error: Could not create configmap${SET}"
		exit 1
	fi
	echo "✅"
	done
}

build_kubernetes_svc_deploy
{
	echo "${YELLOW}Building kubernetes...${SET}"
	for SERVICE in $LIST_SERVICES
	do
		kubectl apply -f srcs/kubernetes/$SERVICE.yaml > /dev/null
		echo "${GREEN}✅ $SERVICE built${SET}"
	done
}
# List of services
# LIST_SERVICES='ftps grafana nginx mysql wordpress phpmyadmin influxdb telegraf'
LIST_SERVICES='mysql wordpress phpmyadmin nginx'

# Allow user42 to use docker
echo "user42" | sudo -S chmod 666 /var/run/docker.sock > /dev/null
find_and_replace_cluster_ip;
minikube_start;
metallb_setup;
build_docker_image;
create_secrets;
create_configmaps;
build_kubernetes_svc_deploy;
minikube dashboard
