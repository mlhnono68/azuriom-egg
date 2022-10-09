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
#RUN mkdir /run/mysqld && chown container /run/mysqld

# Setup mysql with the container user
RUN echo setup
RUN mysql_install_db --user=container --datadir=/data
#RUN sed -i'' 's/\/run\/mysqld/\/home\/container/' /etc/mysql/my.cnf
RUN echo "socket = /home/container/mysqld.sock" >> /etc/my.cnf

#RUN chown -R container:container /var/www/azuriom
RUN chown -R container:container /etc/nginx
RUN chown -R container:container /var/lib/nginx
RUN chown -R container:container /var/log/nginx
RUN chown -R container:container /run/nginx

# RUN chown -R container:container /var/log/php81
RUN touch /home/container/php-error.log && chown container:container /home/container/php-error.log
RUN ln -s /home/container/php-error.log /var/log/php81/error.log

RUN mkdir -p /var/lib/nginx/tmp /var/log/nginx \
 #   && chown -R container:container /var/lib/nginx /var/log/nginx \
    && chmod -R 755 /var/lib/nginx /var/log/nginx

COPY nginx.conf /home/container/nginx.conf
RUN chown -R container:container /home/container

# Switch to the container user
USER container
ENV  USER=container HOME=/home/container
WORKDIR /home/container

# Download Azorium
RUN curl -Lo /home/container/AzuriomInstaller.zip https://github.com/Azuriom/AzuriomInstaller/releases/download/v1.1.0/AzuriomInstaller.zip
RUN mkdir -p /home/container/azuriom && cd /home/container/azuriom && unzip /home/container/AzuriomInstaller.zip && rm /home/container/AzuriomInstaller.zip && chmod -R 755 /home/container/azuriom


COPY entrypoint.sh /entrypoint.sh
CMD ["/bin/sh", "/entrypoint.sh"]