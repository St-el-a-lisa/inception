# Inception - Developer Documentation

## Overview

This document explains how to set up, build and manage the Inception infrastructure from a development point of view.

The project contains three Docker services:

- **NGINX**: HTTPS entry point for the infrastructure.
- **WordPress + PHP-FPM**: web application.
- **MariaDB**: WordPress database.

Each service is built from its own Dockerfile based on Debian Bookworm and runs in a dedicated container.

Docker Compose manages the services, network and volumes, while the Makefile provides commands to build and manage the infrastructure.

## Prerequisites

The project must run inside a virtual machine.

The following tools must be installed:

- Docker
- Docker Compose
- Make
- Git

The user running the project must have permission to use Docker.

The project data is stored under:

```text
/home/ecid/data/
```

## Project structure

The main project structure is:

```text
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   └── tools/
        │       └── mariadb.sh
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        │       └── nginx.conf
        └── wordpress/
            ├── Dockerfile
            ├── conf/
            │   └── www.conf
            └── tools/
                └── wordpress.sh
```

## Environment configuration

The project uses an environment file located at:

```text
srcs/.env
```

This file is excluded from Git and must be created locally.

Example:

```env
DOMAIN_NAME=ecid.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user

WP_TITLE=Inception
WP_ADMIN_USER=elisacms
WP_ADMIN_EMAIL=ecid@student.42.fr

WP_USER=visitor
WP_USER_EMAIL=<user-email>

DATA_PATH=/home/ecid/data
```

The `.env` file contains configuration values but must not contain passwords.

## Secrets configuration

Sensitive credentials are stored locally inside:

```text
secrets/
```

The following files are required:

```text
secrets/
├── credentials.txt
├── db_password.txt
└── db_root_password.txt
```

`db_password.txt` contains the MariaDB password used by WordPress.

`db_root_password.txt` contains the MariaDB root password.

`credentials.txt` contains the WordPress user passwords required during the WordPress installation.

The secret files are excluded from Git and must never be committed to the repository.

Docker Compose makes the required secret files available inside the containers under `/run/secrets/`.

## Persistent data directories

Before starting the infrastructure, the following directories are required:

```text
/home/ecid/data/mariadb
/home/ecid/data/wordpress
```

The Makefile automatically creates them when the project is started.

They are used to persist:

- MariaDB database files.
- WordPress website files.

## Build and launch

From the root of the repository, run:

```bash
make
```

The Makefile:

1. Creates the required data directories.
2. Builds the Docker images using Docker Compose.
3. Starts the containers in detached mode.

The equivalent Docker Compose operation is based on:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

After the build, check the containers with:

```bash
docker ps
```

The following containers should be running:

```text
nginx
wordpress
mariadb
```

## Docker images

Each service has its own Dockerfile and image:

```text
nginx      -> nginx
wordpress  -> wordpress
mariadb    -> mariadb
```

The images are built locally from the project's Dockerfiles.

No pre-built NGINX, WordPress or MariaDB application image is used.

## Docker network

The project defines a dedicated Docker bridge network named `inception`.

The services communicate using their Docker Compose service names.

The communication flow is:

```text
Client
  |
  | HTTPS :443
  v
NGINX
  |
  | FastCGI :9000
  v
WordPress / PHP-FPM
  |
  | MariaDB
  v
MariaDB
```

Only NGINX publishes a port to the host.

WordPress and MariaDB remain accessible only through the internal Docker network.

The Docker networks can be checked with:

```bash
docker network ls
```

## Docker volumes

The project defines two named volumes:

- `wordpress_data`
- `mariadb_data`

They can be listed with:

```bash
docker volume ls
```

More information about a volume can be displayed with:

```bash
docker volume inspect srcs_wordpress_data
```

or:

```bash
docker volume inspect srcs_mariadb_data
```

The persistent data is stored under:

```text
/home/ecid/data/wordpress
/home/ecid/data/mariadb
```

This allows the containers to be stopped or recreated without losing the WordPress website or database.

## Managing the infrastructure

### Start and build

```bash
make
```

### Stop

```bash
make down
```

This stops and removes the containers and the Docker Compose network.

Persistent data remains available.

### Rebuild

```bash
make re
```

This stops the current infrastructure and rebuilds the services.

### Display running containers

```bash
docker ps
```

### Display Docker images

```bash
docker images
```

### Display volumes

```bash
docker volume ls
```

### Display networks

```bash
docker network ls
```

### Display container logs

For example:

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

These commands can be useful when debugging a service.

## Service initialization

### MariaDB

The MariaDB entrypoint script:

```text
srcs/requirements/mariadb/tools/mariadb.sh
```

initializes the database when necessary.

It creates the WordPress database and database user using the environment variables and secret files.

MariaDB then runs as the main process of its container.

### WordPress

The WordPress entrypoint script:

```text
srcs/requirements/wordpress/tools/wordpress.sh
```

waits for MariaDB to become available.

If WordPress is not already configured, it uses WP-CLI to:

- Download WordPress.
- Create `wp-config.php`.
- Install WordPress.
- Create the administrator account.
- Create the additional WordPress user.

PHP-FPM then runs as the main process of the container.

### NGINX

NGINX is configured to listen on port `443` using HTTPS.

The configuration allows only TLS 1.2 and TLS 1.3.

NGINX forwards PHP requests to the WordPress container using FastCGI on port `9000`.

The TLS certificate used by the project is self-signed.

## Data persistence

Container storage is normally temporary: data stored only inside a container can disappear when that container is removed.

For this reason, WordPress and MariaDB use persistent volumes.

The WordPress files remain under:

```text
/home/ecid/data/wordpress
```

The database remains under:

```text
/home/ecid/data/mariadb
```

After stopping and rebuilding the infrastructure, the existing website, users, posts and database should still be available.

## Development checks

After modifying a Dockerfile, configuration file or script, rebuild the infrastructure:

```bash
make re
```

Then verify:

```bash
docker ps
```

The website can also be tested from the virtual machine with:

```bash
curl -k -I https://localhost
```

A working NGINX/WordPress connection should return a successful HTTP response.

To verify that HTTP port 80 is not exposed:

```bash
curl -I http://localhost
```

The connection should fail because NGINX is exposed through HTTPS port 443 only.