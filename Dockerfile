FROM alpine:3.16.2

EXPOSE 80
EXPOSE 3306

# Install the dependencies
RUN apk update && \
    apk add nginx mariadb mariadb-common mariadb-client curl zip php81 php81-fpm php81-pgsql php81-mysqli php81-sqlite3 php81-bcmath php81-mbstring php81-xml php81-curl php81-zip php81-gd php81-pdo php81-tokenizer php81-fileinfo php81-xmlwriter php81-ctype php81-session php81-pdo_mysql php81-dom

# Create the container user for Pterodactly
RUN adduser -u 998 --disabled-password --home /home/container container

# Setup mysql with the container user
COPY my.cnf /etc/my.cnf
RUN rmdir /var/log/php81 && ln -s /home/container/log-php /var/log/php81 && \
    chown -R container:container /usr/lib/mariadb/plugin/auth_pam_tool_dir

# Setup nginx config and do the symbolic links to allow running readonly
COPY nginx.conf /etc/nginx/nginx.conf
RUN chown -R container:container /var/lib/nginx && \
    chown -R container:container /run/nginx && \
    ln -s /home/container/lib-nginx /var/lib/nginx/tmp && \
    ln -s /home/container/log-nginx /var/log/nginx && \
    ln -s /home/container/run-nginx /run/nginx && \
    chown -R container:container /var/log/nginx && \
    sed -i'' 's/.* = nobody//' /etc/php81/php-fpm.d/www.conf

# Ensure container user owns everything in home directory
RUN chown -R container:container /home/container

# Download Azuriom
RUN curl -Lo /AzuriomInstaller.zip https://github.com/Azuriom/AzuriomInstaller/releases/download/v1.1.0/AzuriomInstaller.zip

# Switch to the container user
USER container
ENV  USER=container HOME=/home/container
WORKDIR /home/container

# Define the entrypoint for Pterodactyl
COPY entrypoint.sh /entrypoint.sh
CMD ["/bin/sh", "/entrypoint.sh"]