#!/bin/sh

/usr/bin/mysqld_safe --datadir='/data' --port=3306 --skip_networking=OFF &

sleep 2

# Setup the Azorium database
cat <<EOF | mysql -S /tmp/mysqld.sock
CREATE USER 'azuriom'@'127.0.0.1' IDENTIFIED BY 'password';
CREATE DATABASE azuriom;
GRANT ALL PRIVILEGES ON azuriom.* TO 'azuriom'@'127.0.0.1' WITH GRANT OPTION;
EOF

# Start PHP fpm engine
set
php-fpm81 -F -O &

# Start nginx in foreground
nginx -c /home/container/nginx.conf -g 'daemon off;'
