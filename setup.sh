BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
SET='\033[0m'

export MINIKUBE_HOME=/goinfre/$USER/

# move docker to goinfre
echo "${YELLOW}🔄 Moving docker to goinfre...${SET}"
rm -rf ~/Library/Containers/com.docker.docker ~/.docker
mkdir -p /Volumes/Storage/goinfre/$USER/docker/{com.docker.docker,.docker}
ln -sf /Volumes/Storage/goinfre/$USER/docker/com.docker.docker ~/Library/Containers/com.docker.docker
ln -sf /Volumes/Storage/goinfre/$USER/docker/.docker ~/.docker
echo "${GREEN}✅️ Done !${SET}"


# Start the cluster and install addons
# if [ $(minikube status | grep -c "Running") == 0 ]
# then
echo "${YELLOW}Starting Minikube...${SET}"
minikube start --vm-driver=virtualbox --disk-size=5000MB
eval $(minikube docker-env)
echo "${GREEN}✅ Minikube started${SET}"
echo "${YELLOW}Activating addons...${SET}"
sleep 3
minikube addons enable metrics-server
minikube addons enable dashboard
minikube addons enable logviewer
echo "${GREEN}✅ Addons activated${SET}"
# fi

# Install Metallb and secret key
echo "${YELLOW}Installing MetalLB...${SET}"
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
kubectl apply -f srcs/config/metallb.yaml
kubectl apply -f srcs/config/kustomization.yaml
echo "${GREEN}✅ MetalLB installed${SET}"

# Docker build
LIST_SERVICES='ftps grafana nginx mysql wordpress phpmyadmin influxdb telegraf'

echo "${BLUE}Building Docker images...${SET}"
for SERVICE in $LIST_SERVICES
do
	echo "${YELLOW}🐳 Building $SERVICE..."
	docker build -t $SERVICE srcs/$SERVICE > /dev/null
	echo "${GREEN}✅ $SERVICE built${SET}"
done

# kubernetes build
echo "${YELLOW}Building kubernetes...${SET}"
for SERVICE in $LIST_SERVICES
do
	kubectl apply -f srcs/kubernetes/$SERVICE.yaml
	echo "${GREEN}✅ $SERVICE built${SET}"
done
echo

export MINIKUBE_IP=$(minikube ip)

echo ${MINIKUBE_IP}

printf "\n🎉 : FT_SERVICES ${Green}READY${Default_color}\n"
echo " ---------------------------------------------------------------------------------------"
printf "| ${Blue}Wordpress${Default_color}	 | user: admin     | password: admin    | ip: http://"
kubectl get svc | grep wordpress-service | cut -d " " -f 11,12,13 | tr -d "\n" | tr -d " "
printf ":5050  |\n"
echo " ---------------------------------------------------------------------------------------"
printf "| ${Yellow}PhpMyAdmin${Default_color}     | user: wp_user   | password: password | ip: http://"
kubectl get svc | grep phpmyadmin-service | cut -d " " -f 10,11,12 | tr -d "\n" | tr -d " "
printf ":5000  |\n"
echo " ---------------------------------------------------------------------------------------"
printf "| ${Green}Ftps${Default_color}           | user: ftps_user | password: password | ip: "
kubectl get svc | grep ftps-service | cut -d " " -f 15,16,17,18 | tr -d "\n" | tr -d " "
printf ":21           |\n"
echo " ---------------------------------------------------------------------------------------"
printf "| ${Light_red}Grafana${Default_color}        | user: admin     | password: admin    | ip: http://"
kubectl get svc | grep grafana-service | cut -d " " -f 13,14,15 | tr -d "\n" | tr -d " "
printf ":3000  |\n"
echo " ---------------------------------------------------------------------------------------"
printf "| ${Orange}Nginx${Default_color}          | user: ssh_user  | password: password | ip: https://"
kubectl get svc | grep nginx-service | cut -d " " -f 15,16,17 | tr -d "\n" | tr -d " "
printf ":443  |\n"
echo " ---------------------------------------------------------------------------------------"

sleep 2
minikube dashboard



# verif_dependencies()
# {
# 	echo "${YELLOW}Verifying dependencies...${SET}"
# 	if [ "$(VboxManage > /dev/null && echo $?)" == "0" ]
# 	then
# 				printf "✅ : VirtualBox installed\n"
# 	else
# 		echo "❗ : Please install ${RED}VirtualBox"
# 		exit
# 	fi
#
# 	if [ "$(brew list > /dev/null 2>&1 && echo $?)" != "0" ]; then
# 		rm -rf $HOME/.brew &
# 		git clone --depth=1 https://github.com/Homebrew/brew $HOME/.brew &
# 		echo 'export PATH=$HOME/.brew/bin:$PATH' >> $HOME/.zshrc &
# 		source $HOME/.zshrc &
# 		brew update
# 	fi
# 	echo "🤖 : Brew installed\n"
# }
