FROM alpine:3.23.4

RUN apk update && apk add --no-cache \
        php83 \
        php83-fpm \
        php83-mysqli \
        php83-session \
        nginx \
        wget \
    && rm -rf /var/cache/apk/*

RUN mkdir -p /var/www/adminer \
    && wget -O /var/www/adminer/index.php https://www.adminer.org/latest.php \
    && chmod -R 755 /var/www/adminer \
    && chown -R nobody:nobody /var/www/adminer

COPY conf/www.conf /etc/php83/php-fpm.d/www.conf
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]