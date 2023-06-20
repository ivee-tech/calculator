# Calculator application
Sample DevOps app - calculator application with Sql DB, .NET Web Api, and Vue UI


### Execute locally

Pre-requisites:
- SQL Server
- .NET 6.0
- VUE CLI


**Task - Install Calculator DB**

Navigate to *db\Calculator* folder

``` PS
cd .\db\Calculator\
```

Find *MSBuild.exe*

``` PS
$r1 = cmd /c "WHERE /R ""C:\Program Files"" MSBuild.exe"
if(0 -eq $r1.Length) {
    Write-Host "MSBuild.exe cannot be found."
    # exit
}
$msbuild = $r1[0]
# C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe
```

Find *SqlPackage.exe*

``` PS
$r2 = cmd /c "WHERE /R ""C:\Program Files"" SqlPackage.exe"
if(0 -eq $r2.Length) {
    Write-Host "SqlPackage.exe cannot be found."
    # exit
}
$sqlpackage = $r2[0]
# C:\Program Files\Microsoft SQL Server\160\DAC\bin\SqlPackage.exe
```

Build DB

``` PS
$cmd = """$msbuild"" ""Calculator.sqlproj"" /t:Build /p:Configuration=Release /p:Platform=""Any CPU"""
cmd /c $cmd
```

Publish DACPAC

``` PS
$dacpac = ".\bin\Release\Calculator.dacpac"
$destSvrName = '.'
$destDbName = 'Calculator'
$destConnection = "Server=$destSvrName;Initial Catalog=$destDbName;Integrated Security=SSPI;"
$cmd = """$sqlpackage"" /a:Publish /sf:""$dacpac"" /tcs:""$destConnection"""
cmd /c $cmd
```

**Task - Build & Run Web Api**

Navigate to *api* folder and open *Calculator.Web.Api.sln* in VS 2022.

Ensure the connection string point sto your local DB:

``` json
  "ConnectionStrings": {
    "Default": "Data source=.;Initial Catalog=Calculator;Integrated Security=SSPI;"
  },
```

Run the Web Api project and ensure the browser is opening on `https://localhost:7057` (optionally Swagger UI is available):

![Web Api Swagger](./docs/images/01-web-api-swagger.png)

Optionally, test the `Execute` endpoint:

![Test Execute](./docs/images/02-web-api-test-execute.png)

**Task - Run Calculator UI**

Navigate to *ui*

Install dependencies

``` PS
npm install
```

Ensure the API endpoint in *public/assets/config/config.dev.json* file is configured properly

``` json
{
    "apiBaseUrl": "https://localhost:7057/api",
...
}
```

Run the app

``` PS
npm run serve
``` 

Open a browser window and navigate to `http://localhost:8080`

![UI Run](./docs/images/03-ui-run.png)


## Execute locally using containers

This approach uses docker compose to run the API and UI services.

The database is running as a container within the same network as the other services.

Pre-requisites
- Docker Desktop

**Task - Build DB container**

Navigate to *db/sqlserver-container* folder.

Build container image

``` PS
$tag = '2017-latest' # '2022-latest'
# docker rm $(docker ps -aq) -f # force remove existing containers
# cat Dockerfile # display Dockerfile content
docker build -t calculator-sqlserver:$($tag) --build-arg tag=$tag .
```

Create network and inspect

``` PS
docker network create calc-net
docker inspect calc-net
```

Run the container instance in detached mode

``` PS
$dbPassword = 'AAAbbb12345!@#$%'
docker run -e ACCEPT_EULA=Y -e MSSQL_SA_PASSWORD=$dbPassword -d -p 1434:1433 --name calc-db --network calc-net calculator-sqlserver:$($tag)
```

Check logs

``` PS
docker logs calc-db -f
```

Connect using docker

``` PS
docker exec -it calc-db /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $dbPassword
```

``` SQL
SELECT name FROM master.dbo.sysdatabases
GO
USE CalculatorDB
SELECT * FROM OperationLogs
GO
exit
```

Connect using SSMS, `tcp:localhost,1434`

![COntainer DB](./docs/images/04-container-db.png)

Running with docker compose

``` PS
docker compose up
```

``` ps
docker compose down
```

**Task - Run Web Api container**

Navigate to *api* folder

Build Web Api container image

``` PS
$tag='0.0.1-local'
docker build -t calculator-api:$($tag) --build-arg USE_ENV_VAR=true --build-arg CALL_TYPE=Direct -f .\Calculator.Web.Api\Dockerfile .
```

Inspect `calc-net` network and capture `calc-db` IP address

``` PS
docker network inspect calc-net
```

Set connection string as environment variable. We will use this env var to pass it it to the running container.
``` PS
$dbPassword = 'AAAbbb12345!@#$%'
# docker container
$IP = '<IP>' # get the IP address rom calc-db container, using docker network inspect calc-net
$connectionString = "Data source=localhost,1434;Initial Catalog=CalculatorDB;User ID=sa;Password='$($dbPassword)'"
$env:CALC_DB_CONNECTIONSTRING = $connectionString
```

Run the Web Api container

``` PS
docker run --name calc-api -p 8080:80 -d -e "CALC_DB_CONNECTIONSTRING=$($env:CALC_DB_CONNECTIONSTRING)" --network calc-net calculator-api:$($tag)
```

Check logs

``` PS
docker logs calc-api -f
```

Test Web Api

``` PS
$expression = "1+2"
$baseUrl = 'http://localhost:8080' # container
$url = "$($baseUrl)/api/Operation/execute"
$data = @{ expression = $expression }
$contentType = 'application/json'
$method = 'POST'
$body = $data | ConvertTo-Json
$result = Invoke-WebRequest -Uri $url -Body $body -Method $method -ContentType $contentType
$result

```

**Task - Run UI**

Navigate to *ui* folder

Build container image

``` PS
$tag = '0.0.1-local'
docker build -t calculator-ui:$($tag) .
```

Run UI container

Ensure the `apiBaseUrl` ise set to the correct Web Api Url (`http://localhost:8080/api`)

``` json
{
    "apiBaseUrl": "http://localhost:8080/api",
...
}


```

``` PS
docker run -d -p 8081:80 --name calc-ui calculator-ui:$($tag)
```

Open a browser window and go to `http://localhost:8081`

**Task - Alternativaley, use docker docker compose**

Remove the previous containers, if running

```PS
docker rm calc-api -f
docker rm calc-ui -f
```

Capture the calc-db container IP address

``` PS
docker network inspect calc-net
```

You should see something like below:

``` json
...
        "Containers": {
            "2ecf312e6fa7aa58302ee06830beb687af52ab9968225ce4ce433639993427fd": {
                "Name": "calc-db",
                "EndpointID": "f5563479e48ae8e2cfe6519f4134872544fea60c0d4ed603161ebe20935fb1f0",
                "MacAddress": "02:42:ac:19:00:02",
                "IPv4Address": "172.25.0.2/16",
                "IPv6Address": ""
            }
        },
...
```

Navigate to *api* folder.
Check *docker-compose.yml* file and inspect the `calc-api` and `calc-ui` services.
Update `<IP>` value in the `CALC_DB_CONNECTIONSTRING` env var with the value captured earlier. 

``` yaml
version: '3.4'

services:
  calc-api:
    image: ${DOCKER_REGISTRY-}calculator-api:0.0.1-local
    container_name: calc-api
    #build:
    #  context: .
    #  dockerfile: Calculator.Web.Api/Dockerfile
    ports:
    - "8080:80"
    environment:
    - CALC_DB_CONNECTIONSTRING=Data Source=<IP>;Initial Catalog=CalculatorDB;User ID=sa;Password=AAAbbb12345!@#$%
    networks:
    - calc-net
  calc-ui:
    image: ${DOCKER_REGISTRY-}calculator-ui:0.0.1-local
    container_name: calc-ui
    #build:
    #  context: .
    #  dockerfile: ../ui/Dockerfile
    ports:
    - "8081:80"
    networks:
    - calc-net

networks:
  calc-net:
    driver: bridge
    name: calc-net
```

Spin up services

``` PS
docker compose up
```

Navigate to `http://localhost:8081`, perform some calculations and check the DB.

Tear down services

``` PS
docker compose down
```


## Deployment in K8S

Deployment in K8S is done via a helm chart created with templates for various K8S resources for the calculator app: deployments, services, config maps, secrets, DAPR components, etc.

The helm chart has been created using a simple command:

``` PS
helm create calculator
```

The chart is available under *.k8s/helm/calculator* folder.

The templates have been modified manually to use runtime values provided in the *values.[...].yaml* files.

Sensitive parameters such as passwords and connection strings are passed at runtime.
As this information is stored as Kubernetes secrets, they require to be BASE64 encoded.

The following templates are used:

- *calculator-api-dep.yaml* - Web Api `Deployment`
- *calculator-api-svc.yaml* - Web Api `Service`
- *calculator-cm.yaml* - `ConfigMap`
- *calculator-db-dep.yaml* - DB `Deployment`
- *calculator-db-svc.yaml* - DB `Service`
- *calculator-execute-api-dep.yaml* - Execute Web Api `Deployment`
- *calculator-execute-api-svc.yaml* - Execute Web Api `Service`
- *calculator-log-api-dep.yaml* - Log Web Api `Deployment`
- *calculator-log-api-svc.yaml* - Log Web Api `Service`
- *calculator-lr.yaml* - `LimitRange`, ignored for local Kubernetes
- *calculator-ns.yaml* - `calculator` namespace
- *calculator-secret.yaml* - `Secret`, containing DB password and connection string
- *calculator-ui-dep.yaml* - UI `Deployment`
- *calculator-ui-ing.yaml* - Ingress, ignored for local Kubernetes
- *calculator-ui-svc.yaml* - UI `Service`
- *dapr/redis-state.yaml* - DAPR Redis state store `Component`
- *dapr/redis-pubsub.yaml* - DAPR Redis PubSub `Component`

The *values.[...].yaml* files contain parameter values populated when the chart is released into the K8S cluster.

For local K8S deployments, as Ingress and Load Balancer resources are not available, we use NodePort service type to connect to the pods.

An alternative is to use port-forwarding to connect directly to the pods.

The main chart file is located at *.k8s/helm/calculator/Chart.yaml*

``` yaml
apiVersion: v2
name: calculator
description: A Helm chart for Calculator application deployed to Kubernetes

# A chart can be either an 'application' or a 'library' chart.
#
# Application charts are a collection of templates that can be packaged into versioned archives
# to be deployed.
#
# Library charts provide useful utilities or functions for the chart developer. They're included as
# a dependency of application charts to inject those utilities and functions into the rendering
# pipeline. Library charts do not define any templates and therefore cannot be deployed.
type: application

# This is the chart version. This version number should be incremented each time you make changes
# to the chart and its templates, including the app version.
# Versions are expected to follow Semantic Versioning (https://semver.org/)
version: 0.0.1

# This is the version number of the application being deployed. This version number should be
# incremented each time you make changes to the application. Versions are not expected to
# follow Semantic Versioning. They should reflect the version the application is using.
# It is recommended to use it with quotes.
appVersion: "0.0.1"
```

The chart is using images published to Docker Hub.

If using a private registry, ensure the Kubernetes cluster has pull permissions.

Below are examples on how to publish images to Docker Hub:

- Publish Sql Server image

``` PS
$tag='2017-latest'
$image='calculator-sqlserver'
$registry='docker.io'
$img="${image}:${tag}"
$ns='daradu' # namespace
docker tag ${img} ${registry}/${ns}/${img}
# requires docker login
docker push ${registry}/${ns}/${img}
```

- Publish Web Api

``` PS
$tag='0.0.1-localk8s-direct'
$image='calculator-api'
$registry='docker.io'
$img="${image}:${tag}"
$ns='daradu' # namespace
docker tag ${img} ${registry}/${ns}/${img}
# requires docker login
docker push ${registry}/${ns}/${img}
```

- Publish UI

``` PS
$tag='0.0.1-localk8s' # '0.0.1-local' # '0.0.1-localk8s'
$image='calculator-ui'
$registry='docker.io'
$img="${image}:${tag}"
$ns='daradu' # namespace
docker tag ${img} ${registry}/${ns}/${img}
# requires docker login
docker push ${registry}/${ns}/${img}
```

To uninstall the chart release, run the following command:

``` PS
helm uninstall calculator
```

## Execute in K8S (local) - Direct

`Direct` approach allows direct operation execution and log to the database. This approach has the disadvantage that if, for example, the DB is not available, the response takes long and the user experience is not great. 

Navigate to *.k8s/helm*

**Task - inspect values.yaml**

Check the file *calculator/values.yaml*.
The sensitive parameters are not set and they need to be passed when installing the release.

``` yaml
repo: daradu
namespace: calculator
db:
  password: '***' # set at runtime, min 8 chars
  tag: 2017-latest # 2022-latest
  serviceType: NodePort
  servicePort: 1435
  nodePort: 30333
api:
  tag: 0.0.1-localk8s-direct
  serviceType: NodePort
  servicePort: 9090
  nodePort: 30334
  connectionString: '***' # set at runtime 
ui:
  tag: 0.0.1-localk8s
  serviceType: NodePort
  servicePort: 9091
  nodePort: 30335
```

**Task - install the calculator chart**

Generate BASE64 for DB password and connection string

``` PS
$password = 'AAAbbb12345!@#$%'
$connectionString = "Data Source=calculator-db-cip;Initial Catalog=CalculatorDB;User ID=sa;Password=$($password)"

. ..\..\.scripts\base64.ps1
$passwordB64 = base64 -data $password
$passwordB64

$connectionStringB64 = base64 -data $connectionString
$connectionStringB64
```

Install or upgrade chart

``` PS
helm install calculator .\calculator --set db.password=$passwordB64 --set api.connectionString=$connectionStringB64
```

or

``` PS
helm upgrade --install calculator .\calculator --set db.password=$passwordB64 --set api.connectionString=$connectionStringB64
```

**Task - Verify the deployments**

Check pods

``` PS
kubectl get pods -n calculator
```

Check services

``` PS
kubectl get svc -n calculator
```

## Execute in K8S (local) - CallApi

`CallApi` is a slightly improved version with work offloaded to dedicated services for execution and database logging. The main Web Api performs async calls to both services. If the DB log service is not available, the user experience is still not great.

This approach also prvides an alternative to use DAPR state store to store the operation execution logs.

## Execute in K8S (local) - PubSub

`PubSub` is a solid approach where the communication between services is done via messages handled by a DAPR PubSub component.

The main Web Api receives requests from the UI and instead of calling the DB log service directly, it publishes a message using the DAPR PubSub component.
The DB Log Api is registered as subscriber and consumes those messages, sending them to the Sql DB.

Execution Api is still called asynchronously.




