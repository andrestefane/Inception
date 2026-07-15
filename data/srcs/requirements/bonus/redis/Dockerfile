FROM alpine:3.23.4

RUN apk update && apk add --no-cache \
		redis \
	&& rm -rf /var/cache/apk/*

COPY conf/redis.conf /etc/redis/redis.conf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 6379
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]