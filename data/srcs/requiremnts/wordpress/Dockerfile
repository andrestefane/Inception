FROM alphine:3.23.4

RUN apk update && apk add --no-cache \
		php83 \
		php83-fpm \
		php83-mysqli \
		php83-json \
		php83-curl \
		php83-dom \
		php83-mbstring \
		php83-openssl \
		php83-xml \
		php83-phar \
		php83-session \
		wget \
	&& rm -rf /var/cache/apk/*

RUN wget -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x /usr/local/bin/wp

RUN mkdir -p /var/www/wordpress && chown -R nobody:nobody /var/www/wordpress

COPY conf/www.conf /etc/php83/php83/php-fpm.d/www.conf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]