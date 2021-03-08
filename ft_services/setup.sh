#!/bin/sh
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
SET='\033[0m'

cluster_ip()
{
	# When installed docker creates 3 network. try : "docker network ls"
	# By default containers are connected to the Bridge docker0. Try : "ifconfig" (give information about the bridge network)
	# The command "docker network inspect bridge" give us information about docker0 in a JSON format
	# The option format specify that we want at the index IPAM.Config[0] the value of the Gateway. ex : "172.17.0.1"
	# command cut RTFM
	echo "\n${YELLOW}Finding a valid cluster IP...${SET}"
	HOST=`docker network inspect bridge --format='{{(index .IPAM.Config 0).Gateway}}' | cut -d . -f 4`

	NETWORK=`docker network inspect bridge --format='{{(index .IPAM.Config 0).Gateway}}' | cut -d . -f 1-2`
	CLUSTER_IP=${NETWORK}.0.$((HOST+1))
	echo "${GREEN} Cluster IP :${SET} $CLUSTER_IP"
	echo "${YELLOW}Replacing $CLUSTER_IP in templates files.${SET}"
	export CLUSTER_IP=$CLUSTER_IP
	RES=0
	envsubst '$CLUSTER_IP' < srcs/templates/metallb_configmap.yaml > srcs/metallb/metallb_configmap.yaml
	RES=$((RES+$?))
	envsubst '$CLUSTER_IP' < srcs/templates/nginx_configmap.yaml > ./srcs/configmaps/nginx_configmap.yaml
	RES=$((RES+$?))
	envsubst '$CLUSTER_IP' < srcs/templates/grafana_configmap.yaml > ./srcs/configmaps/grafana_configmap.yaml
	RES=$((RES+$?))
	envsubst '$CLUSTER_IP' < srcs/templates/nginx.yaml > srcs/nginx/nginx.yaml
	RES=$((RES+$?))
	envsubst '$CLUSTER_IP' < srcs/templates/phpmyadmin.yaml > srcs/phpmyadmin/phpmyadmin.yaml
	RES=$((RES+$?))
	envsubst '$CLUSTER_IP' < srcs/templates/wordpress.yaml > srcs/wordpress/wordpress.yaml
	RES=$((RES+$?))
	envsubst '$CLUSTER_IP' < srcs/templates/ftps.yaml > srcs/ftps/ftps.yaml
	RES=$((RES+$?))
	envsubst '$CLUSTER_IP' < srcs/templates/grafana.yaml > srcs/grafana/grafana.yaml
	RES=$((RES+$?))
	if [ $? != 0 ]
	then
		echo "${RED}Error: failed to replace cluster IP in templates...${SET}" > /dev/stderr
		exit
	fi
	echo "${GREEN}Files succesfully created ! ✅${SET}"

}

minikube_start()
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

	echo "${YELLOW}Starting Minikube on \"$OS\"...${SET}"
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
	minikube addons enable dashboard
}

setup_metallb()
{
	RES=0
	echo "${YELLOW}Setting up metallb...${SET}"
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/namespace.yaml 2>&1 > /dev/null
	RES=$((RES+$?))
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/metallb.yaml 2>&1 > /dev/null
	RES=$((RES+$?))
	kubectl get secret -n metallb-system memberlist  > /dev/null 2>&1
	if [ $? != 0 ]
	then
		# On first install only
		kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)" 2>&1 > /dev/null
		RES=$((RES+$?))
	fi
	kubectl apply -f ./srcs/metallb/metallb_configmap.yaml
	RES=$((RES+$?))
	if [ $RES -gt 0 ]
	then
		echo "${RED}Error: could not setup metallb.${SET}"
		exit 1
	fi
}

build_docker()
{
	eval $(minikube docker-env)
	echo "${YELLOW}Building Docker images...${SET}"
	for SERVICE in $LIST_SERVICES
	do
		echo -n "🐳 ${SERVICE} image "
		docker build -t "$SERVICE"_image srcs/$SERVICE > /dev/null
		if [ $? != 0 ]
		then
			echo "${RED}❌"
			echo " Building for $SERVICE failed...${SET}\n"
			exit
		fi
		echo "${GREEN}✅${SET}"
	done
}

create_secrets()
{
	echo "${YELLOW}Creating secrets...${SET}"
	kubectl apply -f ./srcs/secrets
	if [ $? -gt 0 ]
	then
		echo "${RED}Error: could not create secrets${SET}"
		exit 1
	fi
}

create_kubernetes_configmaps()
{
	echo "${YELLOW} Creating configmap...${SET}"
	kubectl apply -f ./srcs/configmaps
	if [ $? -gt 0 ]
	then
		echo ""
		echo "${RED}❌ Error: Could not create configmap${SET}"
		exit 1
	fi
	echo "✅"
}

build_kubernetes()
{
	RES=0
	echo "${YELLOW}Building kubernetes...${SET}"
	for SERVICE in $LIST_SERVICES
	do
		kubectl apply -f srcs/$SERVICE > /dev/null
		echo "${GREEN}✅ $SERVICE built${SET}"
		RES=$((RES+$?))
	done
	if [ $? -gt 0 ]
	then
		echo "${RED}Error: couldn't create services and deployments${SET}"
		exit 1
	fi
}

ft_services_link()
{
	clear;
	echo "Cluster IP : $CLUSTER_IP"
	echo "Wordpress link: http://$CLUSTER_IP:5050"
	echo "Phpmyadmin:  http://$CLUSTER_IP:5000"
	echo "Grafana:     http://$CLUSTER_IP:3000"
	echo "Nginx:       https://$CLUSTER_IP or http://$CLUSTER_IP or $CLUSTER_IP"
	echo "FTPS : \"sudo apt install filezilla\" to test"
	echo "  - IP : $CLUSTER_IP / PORT : 21"
	echo "  - ID: user / Password : password"
}

# List of services
LIST_SERVICES='ftps grafana nginx mysql wordpress phpmyadmin influxdb telegraf'

echo "user42" | sudo -S chmod 666 /var/run/docker.sock 2>&1 > /dev/null
cluster_ip;
minikube_start;
setup_metallb;
build_docker;
create_secrets;
create_kubernetes_configmaps;
build_kubernetes;

ft_services_link;
minikube dashboard
