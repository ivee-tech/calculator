$expression = "1+2"
$baseUrl = 'https://zz-calculator-api-dev-dr.azurewebsites.net' # cloud
$baseUrl = 'http://localhost:8080' # container
$baseUrl = 'https://localhost:7057' # VS
$url = "$($baseUrl)/api/Operation/execute"
$data = @{ expression = $expression }
$contentType = 'application/json'
$method = 'POST'
$body = $data | ConvertTo-Json
$result = Invoke-WebRequest -Uri $url -Body $body -Method $method -ContentType $contentType
$result

# container
# from api sol folder
$tag='0.0.1-local'
docker build -t calculator-api:$($tag) --build-arg USE_ENV_VAR=true --build-arg CALL_TYPE=Direct -f .\Calculator.Web.Api\Dockerfile .
$tag='0.0.1-localk8s-direct'
docker build -t calculator-api:$($tag) --build-arg USE_ENV_VAR=true --build-arg CALL_TYPE=Direct -f .\Calculator.Web.Api\Dockerfile .
$tag='0.0.1-localk8s-callapi'
docker build -t calculator-api:$($tag) --build-arg USE_ENV_VAR=true --build-arg CALL_TYPE=CallApi -f .\Calculator.Web.Api\Dockerfile .
$tag='0.0.1-localk8s-pubsub'
docker build -t calculator-api:$($tag) --build-arg USE_ENV_VAR=true --build-arg CALL_TYPE=PubSub -f .\Calculator.Web.Api\Dockerfile .

# inspect calc-net network and capture calc-db IP address
docker network inspect calc-net

# container connection string
$dbPassword = 'AAAbbb12345!@#$%'
# docker container
$IP = '172.25.0.2' # get the IP from calc-db container, using docker network inspect calc-net
$connectionString = "Data source=$($IP);Initial Catalog=CalculatorDB;User ID=sa;Password='$($dbPassword)'"
# local dev
$connectionString = "Data source=.;Initial Catalog=Calculator;Integrated Security=SSPI;"

$env:CALC_DB_CONNECTIONSTRING = $connectionString
[Environment]::SetEnvironmentVariable("CALC_DB_CONNECTIONSTRING", $env:CALC_DB_CONNECTIONSTRING, [System.EnvironmentVariableTarget]::User)

# run container
docker run --name calc-api -p 8080:80 -d -e "CALC_DB_CONNECTIONSTRING=$($env:CALC_DB_CONNECTIONSTRING)" --network calc-net calculator-api:$($tag)
docker logs calc-api -f
docker rm calc-api -f

# Alternatively, use docker compose
docker compose up
docker compose down


# push to docker hub
$tag='0.0.1-local' # '0.0.1-local' # '0.0.1-localk8s-direct' # '0.0.1-localk8s-callapi' # '0.0.1-localk8s-pubsub'
$image='calculator-api'
$registry='docker.io'
$img="${image}:${tag}"
$ns='daradu' # namespace
docker tag ${img} ${registry}/${ns}/${img}
# requires docker login
docker push ${registry}/${ns}/${img}
