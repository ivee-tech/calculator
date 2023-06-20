cd .\db\sqlserver-container\

# Build container image
$tag = '2017-latest' # '2022-latest'
docker rm $(docker ps -aq) -f
cat Dockerfile
docker build -t calculator-sqlserver:$($tag) --build-arg tag=$tag .

# Create network
docker network create calc-net
docker inspect calc-net

# Run the container instance in detached mode
$dbPassword = 'AAAbbb12345!@#$%'
docker run -e ACCEPT_EULA=Y -e MSSQL_SA_PASSWORD=$dbPassword -d -p 1434:1433 --name calc-db --network calc-net calculator-sqlserver:$($tag)

# Check logs
docker logs calc-db -f
docker rm calc-db -f
docker rmi calculator-sqlserver:$($tag) -f

# Connect using docker
docker exec -it calc-db /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $dbPassword
SELECT name FROM master.dbo.sysdatabases
GO
USE CalculatorDB
SELECT * FROM OperationLogs
GO
exit

# connect using SSMS, tcp:localhost,1434

# running with docker compose
docker compose up
docker compose down

# push to docker hub
$tag='2017-latest' # '2022-latest'
$image='calculator-sqlserver'
$registry='docker.io'
$img="${image}:${tag}"
$ns='daradu' # namespace
docker tag ${img} ${registry}/${ns}/${img}
# requires docker login
docker push ${registry}/${ns}/${img}
