# container
# from api sol folder
$tag='0.0.1-localk8s' # '0.0.1-local' # '0.0.1-localk8s'
docker build -t calculator-log-api:$($tag) --build-arg USE_ENV_VAR=true -f .\Calculator.Log.Api\Dockerfile .


# push to docker hub
$tag='0.0.1-localk8s' # '0.0.1-local' # '0.0.1-localk8s'
$image='calculator-log-api'
$registry='docker.io'
$img="${image}:${tag}"
$ns='daradu' # namespace
docker tag ${img} ${registry}/${ns}/${img}
# requires docker login
docker push ${registry}/${ns}/${img}
