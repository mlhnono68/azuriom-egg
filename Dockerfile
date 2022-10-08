FROM alpine:3.16.2

EXPOSE 80
EXPOSE 3306

RUN apk update
RUN apk add nginx mariadb mariadb-common mariadb-client curl zip php81 php81-fpm php81-pgsql php81-mysqli php81-sqlite3 php81-bcmath php81-mbstring php81-xml php81-curl php81-zip php81-gd
RUN apk add php81-pdo php81-tokenizer php81-fileinfo php81-xmlwriter php81-ctype
RUN apk add php81-session php81-pdo_mysql
RUN apk add bash
# RUN apk add openrc
# RUN /etc/init.d/mariadb setup
# RUN  mysql_install_db --user=mysql
# RUN mysqld_safe

# Create the container user for Pterodactly
RUN adduser --disabled-password --home /home/container container
RUN mkdir /run/mysqld && chown container /run/mysqld

# Setup mysql with the container user
RUN echo setup
RUN mysql_install_db --user=container --datadir=/data

# Download Azorium
RUN curl -Lo /AzuriomInstaller.zip https://github.com/Azuriom/AzuriomInstaller/releases/download/v1.1.0/AzuriomInstaller.zip
RUN mkdir -p /var/www/azuriom && cd /var/www/azuriom && unzip /AzuriomInstaller.zip && rm /AzuriomInstaller.zip && chmod -R 755 /var/www/azuriom
RUN chown -R container:container /var/www/azuriom
RUN chown -R container:container /etc/nginx
RUN chown -R container:container /var/lib/nginx
RUN chown -R container:container /var/log/nginx
RUN chown -R container:container /run/nginx

RUN chown -R container:container /var/log/php81
#RUN mkdir -p /var/run/php && chown container:container /var/run/php

# Switch to the container user
USER container
ENV  USER=container HOME=/home/container
WORKDIR /home/container

COPY entrypoint.sh /entrypoint.sh
CMD ["/bin/sh", "/entrypoint.sh"]