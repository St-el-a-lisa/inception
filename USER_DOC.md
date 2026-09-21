# Inception - User Documentation

## Overview

This project provides a WordPress website running inside a Docker infrastructure.

The infrastructure contains three services:

- **NGINX**: provides secure HTTPS access to the website.
- **WordPress**: provides the website and its administration interface.
- **MariaDB**: stores the WordPress database.

NGINX is the only service accessible directly from outside the Docker network and uses HTTPS on port 443.

The website is available at:

`https://ecid.42.fr`

## Starting the project

The project must be started from the root of the repository.

Run:

```bash
make