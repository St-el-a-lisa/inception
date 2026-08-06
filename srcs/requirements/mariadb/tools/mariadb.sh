#!/bin/sh

set -e

echo "Préparation de MariaDB..."

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initialisation de la base MariaDB..."
    mariadb-install-db \
        --user=mysql \
        --datadir=/var/lib/mysql
fi

echo "Démarrage de MariaDB..."
exec mariadbd \
    --user=mysql \
    --datadir=/var/lib/mysql \
    --bind-address=0.0.0.0

