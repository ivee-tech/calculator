# create helm chart
helm create calculator

$password = '***'
$connectionString = "Data Source=calculator-db-cip;Initial Catalog=CalculatorDB;User ID=sa;Password=$($password)"

. ..\..\.scripts\base64.ps1
$passwordB64 = base64 -data $password
$passwordB64

$connectionStringB64 = base64 -data $connectionString
$connectionStringB64

$redisPasswordB64=$(kubectl get secret --namespace redis redis -o jsonpath="{.data.redis-password}")
$redisPasswordB64

$secret = base64 -data $base64 -d
$secret



# make required changes in templates and values

# install helm chart
kubectl config current-context
# Direct (default)
helm install calculator .\calculator --set db.password=$passwordB64 --set api.connectionString=$connectionStringB64
# CallApi
helm upgrade --install calculator -f .\calculator\values.CallApi.yaml .\calculator `
    --set db.password=$passwordB64 --set api.connectionString=$connectionStringB64 --set redis.password=$redisPasswordB64
# PubSub
helm upgrade --install calculator -f .\calculator\values.PubSub.yaml .\calculator `
    --set db.password=$passwordB64 --set api.connectionString=$connectionStringB64 --set redis.password=$redisPasswordB64

# uninstall
helm uninstall calculator


