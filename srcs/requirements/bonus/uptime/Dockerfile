FROM alpine:3.23.4

RUN apk add --no-cache \
    nodejs \
    npm \
    git \
    python3 \
    make \
    g++ \
    sqlite

WORKDIR /app

RUN git clone --depth 1 --branch 1.23.16 https://github.com/louislam/uptime-kuma.git /app \
    && npm run setup \
    && npm cache clean --force

ENV UPTIME_KUMA_HOST=0.0.0.0
ENV UPTIME_KUMA_PORT=3001
ENV DATA_DIR=/app/data

EXPOSE 3001

CMD ["node", "server/server.js"]