#!/bin/sh

/usr/bin/mysqld_safe --datadir='/data' --port=3306 --skip_networking=OFF &

sleep 2

# Setup the Azorium database
cat <<EOF | mysql
CREATE USER 'azuriom'@'127.0.0.1' IDENTIFIED BY 'password';
CREATE DATABASE azuriom;
GRANT ALL PRIVILEGES ON azuriom.* TO 'azuriom'@'127.0.0.1' WITH GRANT OPTION;
EOF

# Setup nginx configuration
echo "Configuring NGINX"
cat <<EOF > /etc/nginx/http.d/default.conf
server {
    listen 80;
    #server_name example.com;
    root /home/container/azuriom/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";
    add_header Referrer-Policy "strict-origin-when-cross-origin";

    index index.html index.htm index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF

# Start PHP fpm engine
php-fpm81

# Start nginx in foreground
nginx -g 'daemon off;'
