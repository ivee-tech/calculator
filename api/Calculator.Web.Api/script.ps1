$expression = "1%2B2"
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
$tag='0.0.1-localk8s' # '0.0.1-local' # '0.0.1-localk8s'
docker build -t calculator-api:$($tag) -f .\Calculator.Web.Api\Dockerfile .
docker run --name calc-api -p 8080:80 -d -e "CALC_DB_CONNECTIONSTRING=$($env:CALC_DB_CONNECTIONSTRING)" calculator-api:$($tag)
docker logs calc-api -f
docker rm calculator-api -f

# container connection string
$dbPassword = 'P@ssword123!@#'
# docker container
$connectionString = "Data source=host.docker.internal,1434;Initial Catalog=CalculatorDB;User ID=sa;Password='$($dbPassword)'"
# local dev
$connectionString = "Data source=.;Initial Catalog=Calculator;Integrated Security=SSPI;"
$env:CALC_DB_CONNECTIONSTRING = $connectionString
[Environment]::SetEnvironmentVariable("CALC_DB_CONNECTIONSTRING", $env:CALC_DB_CONNECTIONSTRING, [System.EnvironmentVariableTarget]::User)


# push to docker hub
$tag='0.0.1-localk8s' # '0.0.1-local' # '0.0.1-localk8s'
$image='calculator-api'
$registry='docker.io'
$img="${image}:${tag}"
$ns='daradu' # namespace
docker tag ${img} ${registry}/${ns}/${img}
# requires docker login
docker push ${registry}/${ns}/${img}
