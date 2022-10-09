Docker image for future pterodactly egg to support Azorium

# How to build ?
```shell
echo $PAT | docker login ghcr.io --username mlhnono68 --password-stdin
docker build -t azorium-egg .
docker tag azorium-egg ghcr.io/mlhnono68/azorium-egg:0.0.1
docker push ghcr.io/mlhnono68/azorium-egg:0.0.1

docker pull ghcr.io/mlhnono68/azorium-egg:0.0.1
```