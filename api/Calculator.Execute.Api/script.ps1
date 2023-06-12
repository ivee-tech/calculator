# container
# from api sol folder
$tag='0.0.1-local' # '0.0.1-local' # '0.0.1-localk8s'
docker build -t calculator-execute-api:$($tag) -f .\Calculator.Execute.Api\Dockerfile .


# push to docker hub
$tag='0.0.1-local' # '0.0.1-local' # '0.0.1-localk8s'
$image='calculator-execute-api'
$registry='docker.io'
$img="${image}:${tag}"
$ns='daradu' # namespace
docker tag ${img} ${registry}/${ns}/${img}
# requires docker login
docker push ${registry}/${ns}/${img}
