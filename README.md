*This project has been created as part of the 42 curriculum by ecid.*

# Inception

## Description

Inception is a system administration project based on Docker.

The goal of the project is to build a small infrastructure composed of several services running in separate Docker containers inside a virtual machine.

The infrastructure contains:

- NGINX as the only entry point, using HTTPS on port 443 with TLS 1.2 and TLS 1.3.
- WordPress running with PHP-FPM.
- MariaDB as the database.
- A dedicated Docker network allowing the containers to communicate.
- Two Docker named volumes to persist the WordPress files and the MariaDB database.

Each service runs in its own container and each Docker image is built from a custom Dockerfile based on Debian Bookworm.

No pre-built NGINX, WordPress or MariaDB Docker image is used. The infrastructure is managed with Docker Compose and a Makefile.

The domain name used by the project is:

`ecid.42.fr`

NGINX is the only service exposed to the host. WordPress and MariaDB communicate only through the internal Docker network.

## Project architecture

The infrastructure follows this communication flow:

Browser
   |
   | HTTPS / port 443
   v
NGINX
   |
   | FastCGI / port 9000
   v
WordPress + PHP-FPM
   |
   | MariaDB connection
   v
MariaDB

NGINX receives HTTPS requests and forwards PHP requests to the WordPress container.

WordPress communicates with MariaDB through the Docker network using the MariaDB service name.

The WordPress files and database are stored persistently so that they are not lost when containers are stopped or recreated.

## Technical choices

### Virtual Machines vs Docker

A virtual machine emulates a complete computer and runs its own operating system and kernel. It provides strong isolation but requires more resources.

Docker containers share the host system's kernel and isolate applications and their dependencies. They are lighter and faster to create than virtual machines.

For this project, Docker runs inside a Debian virtual machine. The virtual machine provides the environment required by the project, while Docker separates NGINX, WordPress and MariaDB into independent services.

### Secrets vs Environment Variables

Environment variables are useful for non-sensitive configuration such as the domain name, database name, database user or WordPress site title.

Secrets are used for sensitive information such as database and WordPress passwords.

In this project, non-sensitive configuration is stored in:

`srcs/.env`

Sensitive information is stored locally in:

`secrets/`

The secret files are mounted inside the appropriate containers under `/run/secrets/`.

The `.env` file and the contents of the `secrets` directory are excluded from Git to prevent credentials from being published in the repository.

### Docker Network vs Host Network

A Docker bridge network provides an isolated network where containers can communicate with each other using their service names.

Host networking would make a container directly use the host network and would remove part of this isolation.

This project uses a dedicated Docker bridge network named `inception`.

WordPress connects to the database using the `mariadb` service name and NGINX communicates with WordPress through PHP-FPM on port 9000.

Only NGINX publishes a port to the host:

`443`

The use of `network: host` and Docker links is therefore unnecessary.

### Docker Volumes vs Bind Mounts

Docker volumes provide persistent storage independently from the lifecycle of containers. A container can therefore be deleted and recreated without losing the stored data.

A bind mount directly maps a specific directory from the host filesystem into a container.

This project defines two Docker named volumes:

- `mariadb_data` for the WordPress database.
- `wordpress_data` for the WordPress website files.

The volumes are configured so that their persistent data is stored under:

`/home/ecid/data/mariadb`

and:

`/home/ecid/data/wordpress`

This makes the persistent data available from the virtual machine while keeping the storage managed through Docker Compose.

## Project structure

The main project structure is:

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

Each service has its own Dockerfile and configuration files.

## Instructions

### Prerequisites

The project must be executed inside a virtual machine.

The following tools are required:

- Docker
- Docker Compose
- Make

The repository must also contain the local configuration files required by the project.

### Environment configuration

The environment variables are stored in:

`srcs/.env`

This file is excluded from Git and must be created locally before starting the project.

Example of the non-sensitive configuration used by the project:

DOMAIN_NAME=ecid.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user

WP_TITLE=Inception
WP_ADMIN_USER=elisacms
WP_ADMIN_EMAIL=ecid@student.42.fr

WP_USER=visitor
WP_USER_EMAIL=<user-email>

DATA_PATH=/home/ecid/data

Passwords must not be stored in this file.

### Secrets

The following local files are required inside the `secrets` directory:

secrets/
├── credentials.txt
├── db_password.txt
└── db_root_password.txt

They contain the credentials required by WordPress and MariaDB.

These files must remain local and must never be committed to the Git repository.

### Domain name

The domain:

`ecid.42.fr`

must resolve to the IP address of the virtual machine.

This can be configured in the host machine's `/etc/hosts` file when necessary.

For example:

`<VM_IP> ecid.42.fr`

### Build and start

From the root of the repository, run:

`make`

The Makefile creates the required data directories and uses Docker Compose to build and start the infrastructure.

The three main containers should then be running:

- `nginx`
- `wordpress`
- `mariadb`

The website can be accessed at:

`https://ecid.42.fr`

Because the project uses a self-signed TLS certificate, the browser may display a security warning.

### Stop the project

To stop the containers:

`make down`

### Rebuild the project

To stop and rebuild the infrastructure:

`make re`

### Check the containers

The running containers can be checked with:

`docker ps`

Only NGINX should expose port 443 to the host.

The Docker volumes can be checked with:

`docker volume ls`

## Data persistence

The project uses persistent storage for both WordPress and MariaDB.

The data is stored inside:

`/home/ecid/data/wordpress`

and:

`/home/ecid/data/mariadb`

Stopping or recreating the containers does not remove the WordPress website or its database.

This means that posts, users and other WordPress data remain available after the infrastructure is restarted.

## Security

Several rules are applied to avoid exposing sensitive information:

- Passwords are not hardcoded in the Dockerfiles.
- Credentials are stored in local secret files.
- Secret files and `.env` are ignored by Git.
- MariaDB and WordPress do not expose ports directly to the host.
- NGINX is the only entry point to the infrastructure.
- HTTPS is used on port 443.
- NGINX accepts TLS 1.2 and TLS 1.3.
- The WordPress administrator username does not contain `admin` or `administrator`.

## Resources

The following official documentation was used while working on the project:

- Docker Documentation: https://docs.docker.com/
- Docker Compose Documentation: https://docs.docker.com/compose/
- Debian Documentation: https://www.debian.org/doc/
- NGINX Documentation: https://nginx.org/en/docs/
- MariaDB Server Documentation: https://mariadb.com/docs/server/
- WordPress Developer Documentation: https://developer.wordpress.org/
- WP-CLI Handbook: https://make.wordpress.org/cli/handbook/
- OpenSSL Documentation: https://docs.openssl.org/

These resources were used to understand Docker images and containers, Docker networking and volumes, NGINX TLS configuration, MariaDB initialization, WordPress installation with WP-CLI and PHP-FPM configuration.

## Use of AI

AI tools were used as a learning and debugging assistant during the project, mainly to clarify Docker concepts, understand configuration and error messages, and help with testing and reviewing the infrastructure against the project requirements.

AI-generated suggestions were reviewed and tested before being used in the project.