#!/bin/sh

mkdir -p /home/container/lib-nginx
mkdir -p /home/container/log-nginx
mkdir -p /home/container/run-nginx
mkdir -p /home/container/log-php

mkdir -p /home/container/tmp
TMPDIR=/home/container/tmp

if [ ! -d /home/container/mysql ]
then
    mkdir -p /home/container/mysql/data
    mysql_install_db --tmpdir=/home/container/tmp --datadir=/home/container/mysql/data

fi
#echo "socket=/home/container/mysqld.sock" >> /etc/my.cnf

/usr/bin/mysqld_safe --datadir='/home/container/mysql/data' --port=3306 --skip_networking=OFF --tmpdir=/home/container/tmp &

sleep 2

# Unzip Azuriom
if [ ! -d /home/container/azuriom ]
then
    mkdir -p /home/container/azuriom
    ( cd /home/container/azuriom && unzip /AzuriomInstaller.zip && chmod -R 755 /home/container/azuriom )
fi

# Setup the Azorium database
cat <<EOF | mysql -S /home/container/mysqld.sock
CREATE USER 'azuriom'@'127.0.0.1' IDENTIFIED BY 'password';
CREATE DATABASE azuriom;
GRANT ALL PRIVILEGES ON azuriom.* TO 'azuriom'@'127.0.0.1' WITH GRANT OPTION;
EOF

# Start PHP fpm engine
set
php-fpm81 -F -O &

# Start nginx in foreground
# bash
cp /etc/nginx/nginx.conf /home/container/nginx.conf
if [ ! -z "$SERVER_PORT" ]
then
    echo Listening to $SERVER_PORT
    sed -i'' "s/listen .*;/listen $SERVER_PORT;/" /home/container/nginx.conf
    cat /home/container/nginx.conf | grep listen
fi

nginx -g 'daemon off;' -c /home/container/nginx.conf -e /home/container/log-nginx/nginx-error.log &
bash
