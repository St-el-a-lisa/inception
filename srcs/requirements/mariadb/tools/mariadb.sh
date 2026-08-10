#!/bin/sh

set -e

echo "Préparation de MariaDB..."

DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initialisation de MariaDB..."

    mariadb-install-db \
        --user=mysql \
        --datadir=/var/lib/mysql \
        --skip-test-db

    mariadbd \
        --user=mysql \
        --datadir=/var/lib/mysql \
        --skip-networking \
        --socket=/run/mysqld/mysqld.sock &

    pid="$!"

    until mariadb-admin --socket=/run/mysqld/mysqld.sock ping --silent; do
        sleep 1
    done

    mariadb --socket=/run/mysqld/mysqld.sock <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

    mariadb-admin \
        --socket=/run/mysqld/mysqld.sock \
        -uroot \
        -p"${DB_ROOT_PASSWORD}" \
        shutdown

    wait "$pid"
fi

echo "Démarrage de MariaDB..."

exec mariadbd \
    --user=mysql \
    --datadir=/var/lib/mysql \
    --bind-address=0.0.0.0