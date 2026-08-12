#!/bin/sh

set -e

echo "Préparation de WordPress..."

DB_PASSWORD=$(cat /run/secrets/db_password)
. /run/secrets/credentials

until mariadb \
    -h mariadb \
    -u "${MYSQL_USER}" \
    -p"${DB_PASSWORD}" \
    -e "SELECT 1;" \
    "${MYSQL_DATABASE}" > /dev/null 2>&1
do
    echo "Attente de MariaDB..."
    sleep 1
done

echo "MariaDB est prête."

if [ ! -f "/var/www/html/wp-config.php" ]; then
    wp core download --allow-root

    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="mariadb" \
        --allow-root
fi

if ! wp core is-installed --allow-root; then
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author \
        --allow-root
fi

echo "Démarrage de PHP-FPM..."

exec php-fpm8.2 -F