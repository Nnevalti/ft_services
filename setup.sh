BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
SET='\033[0m'

# move docker to goinfre
# echo "${YELLOW}🔄 Moving docker to goinfre...${SET}"
# rm -rf ~/Library/Containers/com.docker.docker ~/.docker
# mkdir -p /Volumes/Storage/goinfre/$USER/docker/{com.docker.docker,.docker}
# ln -sf /Volumes/Storage/goinfre/$USER/docker/com.docker.docker ~/Library/Containers/com.docker.docker
# ln -sf /Volumes/Storage/goinfre/$USER/docker/.docker ~/.docker
# echo "${GREEN}${BOLD}✅️ Done !${SET}"

export MINIKUBE_HOME=/goinfre/$USER/

# Start the cluster and install addons
if [ $(minikube status | grep -c "Running") == 0 ]
then
	echo "${YELLOW}${BOLD}Starting Minikube...${SET}"
	minikube start --vm-driver=virtualbox --disk-size=5000MB
	eval $(minikube docker-env)
	echo "${GREEN}${BOLD}✅ Minikube started${SET}"
	echo "${YELLOW}${BOLD}Activating addons...${SET}"
	minikube addons enable dashboard
	minikube addons enable metrics-server
	minikube addons enable logviewer
	echo "${GREEN}${BOLD}✅ Addons activated${SET}"
fi

# Install Metallb and secret key
echo "${YELLOW}${BOLD}Installing MetalLB...${SET}"
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
kubectl apply -f srcs/config/metallb.yaml
kubectl apply -f srcs/config/kustomization.yaml
echo "${GREEN}${BOLD}✅ MetalLB installed${SET}"

# Docker build
LIST_SERVICES='wordpress mysql'

echo "${BLUE}${BOLD}Building Docker images...${SET}"
for SERVICE in $LIST_SERVICES
do
	echo "🐳 Building $SERVICE..."
	docker build -t $SERVICE srcs/$SERVICE
	echo "${GREEN}✅ $SERVICE built${SET}"
done

# kubernetes build
echo "${YELLOW}${BOLD}Building kubernetes...${SET}"
for SERVICE in $LIST_SERVICES
do
	kubectl apply -f srcs/kubernetes/$SERVICE.yaml
	echo "${GREEN}✅ $SERVICE built${SET}"
done
echo

# export MINIKUBE_IP=$(minikube ip)
#
# echo ${MINIKUBE_IP}

minikube dashboard



# verif_dependencies()
# {
# 	echo "${YELLOW}${BOLD}Verifying dependencies...${SET}"
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
