Pterodactyl egg and docker image for future pterodactly egg to support Azorium

# How to build ?
```shell
docker build -t azorium-egg .
```

# How to build and run locally ?
```shell
sudo rm -rf ./container && \
    mkdir -p ./container && \
    docker build -t azorium-egg . && \
    docker run -p 2000:2000 --env SERVER_IP=0.0.0.0 --env SERVER_PORT=2000 --env EMBEDDED_MYSQL_PASSWORD=password --read-only -v $PWD/container:/home/container -it azorium-egg
```

# How to install and use the egg ?
1) Simply import the egg file [egg-azorium.json](./egg-azorium.json) into one of your Pterodactyl nest
2) Create your server and bind it to an allocation that will handle the web traffic. If you have a database host available, create a database for your Azorium server. Otherwise, define a value for `EMBEDDED_MYSQL_PASSWORD` and an embedded database will be created for you.