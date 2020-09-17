BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
SET='\033[0m'

export MINIKUBE_HOME=/goinfre/$USER/

# Delete services
if [ $1 = 'delete' ]
then
	echo "${YELLOW}${BOLD}Deleting services...${SET}"
	kubectl delete -k srcs
	echo "${GREEN}${BOLD}🗑️ All services deleted${SET}"
	exit
fi

# Start the cluster
if [ $(minikube status | grep -c "Running") == 0 ]
then
	echo "${YELLOW}${BOLD}Starting Minikube...${SET}"
	minikube start --vm-driver=virtualbox
	minikube addons enable dashboard
	echo "${GREEN}${BOLD}✅ Minikube started${SET}"
fi
LIST_SERVICES='wordpress'

# Point to Minikube's docker-daemon
eval $(minikube -p minikube docker-env)

echo "${BLUE}${BOLD}Building Docker images...${SET}"
for SERVICE in $LIST_SERVICES
do
	echo "🐳 Building $SERVICE..."
	docker build -t $SERVICE srcs/$SERVICE
	echo "${GREEN}✅ $SERVICE built${SET}"
done
echo

echo "${YELLOW}${BOLD}Deploying services...${SET}"
kubectl apply -k srcs
echo "${GREEN}${BOLD}✅ All services deployed${SET}"
echo

export MINIKUBE_IP=$(minikube ip)
