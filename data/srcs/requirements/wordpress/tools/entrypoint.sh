#!/bin/sh
set -e

MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/credentials)

until mariadb-admin ping -h mariadb -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent 2>/dev/null; do
    echo "Waiting for MariaDB..."
    sleep 2
done

if [ ! -f "/var/www/wordpress/wp-config.php" ]; then
    wp core download --path=/var/www/wordpress --allow-root

    wp config create \
        --path=/var/www/wordpress \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost=mariadb \
        --allow-root

    wp core install \
        --path=/var/www/wordpress \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root

    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${MYSQL_PASSWORD}" \
        --path=/var/www/wordpress \
        --allow-root
fi

until nc -z redis 6379; do
    echo "Waiting for Redis..."
    sleep 2
done

if ! wp plugin is-installed redis-cache --path=/var/www/wordpress --allow-root; then
    wp plugin install redis-cache \
        --path=/var/www/wordpress \
        --allow-root
fi

wp plugin activate redis-cache \
    --path=/var/www/wordpress \
    --allow-root

wp config set WP_REDIS_HOST redis \
    --path=/var/www/wordpress \
    --allow-root

wp config set WP_REDIS_PORT 6379 --raw \
    --path=/var/www/wordpress \
    --allow-root

wp redis enable \
    --path=/var/www/wordpress \
    --allow-root || true

exec php-fpm83 -F