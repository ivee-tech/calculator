# create helm chart
helm create calculator

$password = 'AAAbbb12345!@#$%' # 'P@ssword123!@#'
$connectionString = "Data source=calculator-db-cip;Initial Catalog=CalculatorDB;User ID=sa;Password=$($password)"

$passwordB64 = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($password))
$passwordB64

$connectionStringB64 = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($connectionString))
$connectionStringB64

$redisPasswordB64=$(kubectl get secret --namespace redis redis -o jsonpath="{.data.redis-password}")
$redisPasswordB64

. ..\..\.scripts\base64.ps1
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


