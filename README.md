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

Each Docker image is built from a custom Dockerfile based on Debian Bookworm. No pre-built NGINX, WordPress or MariaDB Docker image is used.

The infrastructure is managed with Docker Compose and a Makefile.

## Technical choices

### Virtual Machines vs Docker

A virtual machine emulates a complete computer and runs its own operating system and kernel. It provides strong isolation but requires more resources.

Docker containers share the host system's kernel and isolate applications and their dependencies. They are lighter and faster to create than virtual machines.

For this project, Docker runs inside a Debian virtual machine. The virtual machine provides the environment required by the project, while Docker separates NGINX, WordPress and MariaDB into independent services.

### Secrets vs Environment Variables

Environment variables are useful for non-sensitive configuration such as the domain name, database name or WordPress site title.

Docker secrets are more appropriate for sensitive information such as passwords because they can be provided to containers as files instead of being written directly into Dockerfiles or the Compose configuration.

In this project, non-sensitive configuration is stored in `srcs/.env`, while passwords and WordPress credentials are stored in files under `secrets/`. These files are excluded from Git.

### Docker Network vs Host Network

A Docker bridge network provides an isolated network where containers can communicate with each other using their service names.

Host networking removes this network isolation by making a container use the host's network directly.

This project uses a dedicated bridge network named `inception`. WordPress connects to MariaDB using the `mariadb` service name, and NGINX communicates with WordPress through port 9000 inside the Docker network. Only NGINX exposes port 443 to the host.

### Docker Volumes vs Bind Mounts

Docker volumes are managed by Docker and provide persistent storage independently of the lifecycle of a container.

Bind mounts directly map a specific host directory into a container.

This project uses two named Docker volumes: one for the MariaDB database and one for the WordPress files. This allows the data to remain available when containers are stopped or recreated.