FROM alpine:3.16.2

EXPOSE 80
EXPOSE 3306

RUN apk update
RUN apk add nginx mariadb mariadb-common mariadb-client curl zip php81 php81-fpm php81-pgsql php81-mysqli php81-sqlite3 php81-bcmath php81-mbstring php81-xml php81-curl php81-zip php81-gd
RUN apk add php81-pdo php81-tokenizer php81-fileinfo php81-xmlwriter php81-ctype
RUN apk add php81-session php81-pdo_mysql
RUN apk add bash

# Create the container user for Pterodactly
RUN adduser --disabled-password --home /home/container container

# Setup mysql with the container user
RUN echo setup
RUN mysql_install_db --user=container --datadir=/data
RUN echo "socket = /tmp/mysqld.sock" >> /etc/my.cnf
RUN mkdir -p /tmp/log-php && chown container:container /tmp/log-php
RUN rmdir /var/log/php81 && ln -s /tmp/log-php /var/log/php81

# Setup nginx config and do the symbolic links to allow running readonly
COPY nginx.conf /home/container/nginx.conf
RUN mkdir -p /tmp/lib-nginx && chown container:container /tmp/lib-nginx
RUN mkdir -p /tmp/log-nginx && chown container:container /tmp/log-nginx
RUN mkdir -p /tmp/run-nginx && chown container:container /tmp/run-nginx
RUN chown -R container:container /var/lib/nginx
RUN chown -R container:container /run/nginx
RUN ln -s /tmp/lib-nginx /var/lib/nginx/tmp
RUN ln -s /tmp/log-nginx /var/log/nginx
RUN ln -s /tmp/run-nginx /run/nginx
RUN chown -R container:container /var/log/nginx

# Ensure container user owns everything in home directory
RUN chown -R container:container /home/container

# Switch to the container user
USER container
ENV  USER=container HOME=/home/container
WORKDIR /home/container

# Download Azorium
RUN curl -Lo /home/container/AzuriomInstaller.zip https://github.com/Azuriom/AzuriomInstaller/releases/download/v1.1.0/AzuriomInstaller.zip
RUN mkdir -p /home/container/azuriom && cd /home/container/azuriom && unzip /home/container/AzuriomInstaller.zip && rm /home/container/AzuriomInstaller.zip && chmod -R 755 /home/container/azuriom

# Define the entrypoint for Pterodactyl
COPY entrypoint.sh /entrypoint.sh
CMD ["/bin/sh", "/entrypoint.sh"]