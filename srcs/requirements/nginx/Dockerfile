FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes \
    -out /etc/nginx/ssl/ecid.42.fr.crt \
    -keyout /etc/nginx/ssl/ecid.42.fr.key \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=ecid.42.fr"

COPY ./conf/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]