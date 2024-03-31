# initialize dapr for K8S
dapr init -k
# check status 
dapr status -k
# OR
kubectl get pods -n dapr-system

# create namespace redis, if required
# kubectl create ns redis

$ns = 'redis' # 'calculator' # 'redis'

# create Redis store
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install redis bitnami/redis --set image.tag=6.2 -n $ns

#  uninstall redis
helm uninstall redis -n $ns

# check results
# endpoints
# redis-master.$ns.svc.cluster.local for read/write operations (port 6379)
# redis-replicas.$ns.svc.cluster.local for read-only operations (port 6379)

# get your password run:
# bash
export REDIS_PASSWORD=$(kubectl get secret --namespace $ns redis -o jsonpath="{.data.redis-password}" | base64 -d)
# PS
. ..\..\.scripts\base64.ps1
$REDIS_PASSWORD=$(kubectl get secret --namespace $ns redis -o jsonpath="{.data.redis-password}" | base64 -d)

# connect to Redis
# 1. Run a Redis pod that you can use as a client:
kubectl run --namespace $ns redis-client --restart='Never'  --env REDIS_PASSWORD=$REDIS_PASSWORD  --image docker.io/bitnami/redis:6.2 --command -- sleep infinity
kubectl exec --tty -i redis-client --namespace $ns -- bash

# 2. connect using Redis CLI:
REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli -h redis-master
REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli -h redis-replicas

# connect to your database from outside the cluster:
kubectl port-forward --namespace $ns svc/redis-master 6379:6379
    & REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli -h 127.0.0.1 -p 6379


# install store & pubsub components
kubectl apply -f .\redis-state.yaml
kubectl apply -f .\redis-pubsub.yaml
kubectl delete -f .\redis-state.yaml
kubectl delete -f .\redis-pubsub.yaml

# store url
$daprPort = 3500
$stateStoreName = "statestore"
$stateUrl = "http://localhost:$daprPort/v1.0/state/$stateStoreName"
$stateUrl

# test with node app
kubectl apply -f .\node.yaml -n $ns
kubectl delete -f .\node.yaml -n $ns
# port-forward app
kubectl port-forward service/nodeapp 8085:80 -n $ns
# check svc
kubectl get svc nodeapp -n $ns
# check port
curl http://localhost:8085/ports
# submit an order to the app
curl --request POST --data "@sample.json" --header Content-Type:application/json http://localhost:8085/neworder
# check order
curl http://localhost:8085/order
# observe messages
kubectl logs --selector=app=node -c node --tail=-1 -n $ns

# dapr dahsboard
helm repo add dapr https://dapr.github.io/helm-charts/
helm repo update
helm install dapr-dashboard dapr/dapr-dashboard
# run dashboard
dapr dashboard -k -p 9999
