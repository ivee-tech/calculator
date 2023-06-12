# create helm chart
helm create calculator

$password = '***' # 'P@ssword123!@#'
$connectionString = "Data source=calculator-db-cip;Initial Catalog=CalculatorDB;User ID=sa;Password=$($password)"

$passwordB64 = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($password))
$passwordB64

$connectionStringB64 = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($connectionString))
$connectionStringB64

$secret = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($base64))
$secret

# make required changes in templates and values

# install helm chart
kubectl config current-context
helm install calculator .\calculator --set db.password=$passwordB64 --set api.connectionString=$connectionStringB64

# uninstall
helm uninstall calculator


