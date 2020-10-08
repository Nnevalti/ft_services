BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
SET='\033[0m'

minikube delete

echo "${YELLOW}Verifying dependencies...${SET}"

# DOCKER
if [ "$(docker -v > /dev/null && echo $?)" == "0" ]
then
	echo "✅️ ${GREEN}Docker is installed !${SET}"
else
	echo "❗ : Please install ${RED}Docker${SET} for Mac from the Managed Software Center${Default_color}\n${YELLOW}Opening MSC..."
	open -a "Managed Software Center"
	exit
fi

# Move docker to goinfre
if [ "$(ls -la ~ | grep .docker | cut -d " " -f 18-99)" != ".docker -> /Volumes/Storage/goinfre/$USER/docker/.docker" ]
then
	echo "${YELLOW}🔄 Moving Docker to goinfre...${SET}"
	rm -rf ~/Library/Containers/com.docker.docker ~/.docker
	mkdir -p /Volumes/Storage/goinfre/$USER/docker/{com.docker.docker,.docker}
	ln -sf /Volumes/Storage/goinfre/$USER/docker/com.docker.docker ~/Library/Containers/com.docker.docker
	ln -sf /Volumes/Storage/goinfre/$USER/docker/.docker ~/.docker
	echo "${GREEN}✅️ Done !${SET}"
fi

#VirtualBox
if [ "$(vboxmanage -v > /dev/null && echo $?)" == "0" ]
then
	echo "✅️ ${GREEN}VirtualBox is installed !${SET}"
else
	echo "❗ : Please install ${RED}VirtualBox${SET} for Mac from the Managed Software Center${Default_color}\n${YELLOW}Opening MSC..."
	open -a "Managed Software Center"
	exit
fi

# Brew
if [ "$(brew -v > /dev/null && echo $?)" == "0" ]
then
	echo "✅️ ${GREEN}Brew is installed !${SET}"
else
	echo "Installing Brew...\n"
	rm -rf $HOME/.brew
	git clone --depth=1 https://github.com/Homebrew/brew $HOME/.brew
	echo "export PATH=$HOME/.brew/bin:$PATH" >> $HOME/.zshrc
	source $HOME/.zshrc
	brew update
	echo "${GREEN}Brew installed\n${SET}"
fi

# Minikube
if [ "$(brew list | grep minikube)" != "minikube" ]
then
	echo "${YELLOW}Installing Minikube...\n${SET}"
	brew install minikube > /dev/null
	echo "${GREEN}Minikube installed\n${SET}"
else
	echo "✅️ ${GREEN}Minikube is installed !${SET}"
fi

if [ "$(ls -la ~ | grep .minikube | cut -d " " -f 19-99)" != ".minikube -> /Volumes/Storage/goinfre/vdescham/.minikube" ]
then
	echo "${YELLOW}🔄 Moving Minikube to goinfre...${SET}"
	mv ~/.minikube /Volumes/Storage/goinfre/$USER/ > /dev/null
	ln -sf /Volumes/Storage/goinfre/$USER/.minikube /Users/$USER/.minikube
	mkdir /Volumes/Storage/goinfre/$USER/.minikube > /dev/null
	echo "${GREEN}✅️ Done !${SET}"
fi

export MINIKUBE_HOME=/goinfre/$USER/

# Start the cluster and install addons
echo "${YELLOW}Starting Minikube...${SET}"
minikube start --vm-driver=virtualbox --disk-size=5000MB
eval $(minikube docker-env)
echo "${GREEN}✅ Minikube started${SET}"
echo "${YELLOW}Activating addons...${SET}"
sleep 3
minikube addons enable metrics-server
minikube addons enable logviewer
minikube addons enable metrics-server
echo "${GREEN}✅ Addons activated${SET}"

# Install Metallb and secret key
echo "${YELLOW}Installing MetalLB...${SET}"
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
kubectl apply -f srcs/config/metallb.yaml > /dev/null
kubectl apply -f srcs/config/secret_key.yaml > /dev/null
echo "${GREEN}✅ MetalLB installed${SET}"

# Docker build
LIST_SERVICES='ftps grafana nginx mysql wordpress phpmyadmin influxdb telegraf'

echo "${BLUE}Building Docker images...${SET}"
for SERVICE in $LIST_SERVICES
do
	echo "${YELLOW}🐳 Building ${SERVICE}_container..."
	docker build -t "$SERVICE"_container srcs/$SERVICE > /dev/null
	echo "${GREEN}✅ $SERVICE built${SET}"
done

# kubernetes build
echo "${YELLOW}Building kubernetes...${SET}"
for SERVICE in $LIST_SERVICES
do
	kubectl apply -f srcs/kubernetes/$SERVICE.yaml > /dev/null
	echo "${GREEN}✅ $SERVICE built${SET}"
done

echo "Minikube Ip :"
export MINIKUBE_IP=$(minikube ip)

echo ${MINIKUBE_IP}

sleep 2
minikube dashboard
sleep 2
minikube dashboard
