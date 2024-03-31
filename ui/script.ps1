
$tag = '0.0.1-local' # '0.0.1-local' # '0.0.1-localk8s'
$tag = '0.0.1'
docker rm $(docker ps -aq) -f
cat Dockerfile
docker build -t calculator-ui:$($tag) .
docker run -d -p 8081:80 --name calc-ui calculator-ui:$($tag)
docker logs calc-ui -f
docker rm calc-ui -f
docker rmi calculator-ui:$($tag) -f


# push to docker hub
$tag='0.0.1-localk8s' # '0.0.1-local' # '0.0.1-localk8s'
$tag = '0.0.1'
$image='calculator-ui'
$registry='docker.io'
$img="${image}:${tag}"
$rns='daradu' # namespace
docker tag ${img} ${registry}/${rns}/${img}
# requires docker login
docker push ${registry}/${rns}/${img}
