Docker image for future pterodactly egg to support Azorium

# How to build ?
```shell
echo $PAT | docker login ghcr.io --username mlhnono68 --password-stdin
docker build -t azorium-egg .
```

# How to publish ?
```shell
docker tag azorium-egg ghcr.io/mlhnono68/azorium-egg:0.0.1
docker push ghcr.io/mlhnono68/azorium-egg:0.0.1
```

# How to build and run locally ?
```shell
sudo rm -rf $HOME/Downloads/container/* && docker build -t azorium-egg . && docker run -p 2000:2000 --env SERVER_IP=0.0.0.0 --env SERVER_PORT=2000 --env EMBEDDED_MYSQL_PASSWORD=password --read-only -v $HOME/Downloads/container:/home/container -it azorium-egg
```