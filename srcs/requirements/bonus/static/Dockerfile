FROM alpine:3.23.4

RUN apk update && apk add --no-cache \
		nginx \
	&& rm -rf /var/cache/apk/*

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/index.html /var/www/static/index.html

RUN chmod -R 755 /var/www/static

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]