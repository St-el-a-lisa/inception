FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

COPY ./tools/mariadb.sh /usr/local/bin/mariadb.sh

RUN chmod +x /usr/local/bin/mariadb.sh

ENTRYPOINT ["/usr/local/bin/mariadb.sh"]