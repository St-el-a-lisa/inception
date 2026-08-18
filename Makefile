COMPOSE = docker compose -f srcs/docker-compose.yml

DATA_DIR = /home/ecid/data

all:
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

re: down
	$(COMPOSE) up -d --build

.PHONY: all done re