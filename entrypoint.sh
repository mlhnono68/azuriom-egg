#!/bin/sh

# Create the directories where variable nginx and php data will be stored as root is readonly
mkdir -p /home/container/lib-nginx
mkdir -p /home/container/log-nginx
mkdir -p /home/container/run-nginx
mkdir -p /home/container/log-php
mkdir -p /home/container/tmp
TMPDIR=/home/container/tmp

# Only start mysql if EMBEDDED_MYSQL_PASSWORD is defined
if [ ! -z "$EMBEDDED_MYSQL_PASSWORD" ]
then
    # Only initialize the system database if not already done
    if [ ! -d /home/container/mysql ]
    then
        echo "Initializing mySQL embedded database for Azorium..."
        mkdir -p /home/container/mysql/data
        mysql_install_db --tmpdir=/home/container/tmp --datadir=/home/container/mysql/data
    fi

    # Start mysqld in the background
    echo "Starting mySQL embedded database for Azorium..."
    /usr/bin/mysqld_safe --datadir='/home/container/mysql/data' --port=3306 --skip_networking=OFF --tmpdir=/home/container/tmp &
    sleep 2

    # Setup the Azorium database
    echo "Preparing azuriom database and user for the mySQL embedded database..."
    cat <<EOF | mysql -S /home/container/mysqld.sock
    CREATE USER IF NOT EXISTS 'azuriom'@'127.0.0.1' IDENTIFIED BY '$EMBEDDED_MYSQL_PASSWORD';
    CREATE DATABASE IF NOT EXISTS azuriom;
    GRANT ALL PRIVILEGES ON azuriom.* TO 'azuriom'@'127.0.0.1' WITH GRANT OPTION;
    ALTER USER 'azuriom'@'127.0.0.1' IDENTIFIED BY '$EMBEDDED_MYSQL_PASSWORD';
EOF
else
    echo "INFO: No embedded MariaDB database because no EMBEDDED_MYSQL_PASSWORD has been set"
fi

# Unzip Azuriom if not already done
if [ ! -d /home/container/azuriom ]
then
    echo "Unzipping vanilla Azuriom..."
    mkdir -p /home/container/azuriom
    ( cd /home/container/azuriom && unzip /AzuriomInstaller.zip && chmod -R 755 /home/container/azuriom )
fi

# Start PHP fpm engine
echo "Starting PHP..."
php-fpm81 -F -O &

# Start nginx in foreground
echo "Preparing nginx.conf..."
cp /etc/nginx/nginx.conf /home/container/nginx.conf
if [ ! -z "$SERVER_PORT" ]
then
    echo Listening to $SERVER_IP:$SERVER_PORT
    sed -i'' "s/listen .*;/listen $SERVER_IP:$SERVER_PORT;/" /home/container/nginx.conf
else
    >&2 echo "Error: SERVER_IP and SERVER_PORT should be defined by Pterodactyl allocation"
    exit 1
fi

# Start nginx in the foreground
echo "Starting nginx..."
nginx -g 'daemon off;' -c /home/container/nginx.conf -e /home/container/log-nginx/nginx-error.log