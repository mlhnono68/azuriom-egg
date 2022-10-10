#!/bin/sh

mkdir -p /home/container/lib-nginx
mkdir -p /home/container/log-nginx
mkdir -p /home/container/run-nginx
mkdir -p /home/container/log-php

mkdir -p /home/container/tmp
TMPDIR=/home/container/tmp

# Show env. variables for debug reasons
set

# Only start mysql if EMBEDDED_MYSQL_PASSWORD is defined
if [ ! -z "$EMBEDDED_MYSQL_PASSWORD" ]
then
    # Only initialize the system database if not already done
    if [ ! -d /home/container/mysql ]
    then
        mkdir -p /home/container/mysql/data
        mysql_install_db --tmpdir=/home/container/tmp --datadir=/home/container/mysql/data
    fi

    # Start mysqld in the background
    /usr/bin/mysqld_safe --datadir='/home/container/mysql/data' --port=3306 --skip_networking=OFF --tmpdir=/home/container/tmp &
    sleep 2

    # Setup the Azorium database
    cat <<EOF | mysql -S /home/container/mysqld.sock
    CREATE USER 'azuriom'@'127.0.0.1' IDENTIFIED BY '$EMBEDDED_MYSQL_PASSWORD';
    CREATE DATABASE azuriom;
    GRANT ALL PRIVILEGES ON azuriom.* TO 'azuriom'@'127.0.0.1' WITH GRANT OPTION;
EOF
fi

# Unzip Azuriom if not already done
if [ ! -d /home/container/azuriom ]
then
    mkdir -p /home/container/azuriom
    ( cd /home/container/azuriom && unzip /AzuriomInstaller.zip && chmod -R 755 /home/container/azuriom )
fi

# Start PHP fpm engine
php-fpm81 -F -O &

# Start nginx in foreground
# bash
cp /etc/nginx/nginx.conf /home/container/nginx.conf
if [ ! -z "$SERVER_PORT" ]
then
    echo Listening to $SERVER_IP:$SERVER_PORT
    sed -i'' "s/listen .*;/listen $SERVER_IP:$SERVER_PORT;/" /home/container/nginx.conf
    cat /home/container/nginx.conf | grep listen
fi

# Start nginx in the foreground
nginx -g 'daemon off;' -c /home/container/nginx.conf -e /home/container/log-nginx/nginx-error.log &
bash
