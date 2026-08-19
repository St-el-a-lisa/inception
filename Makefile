COMPOSE = docker compose -f srcs/docker-compose.yml

DATA_PATH = /home/ecid/data

all: folders
	DATA_PATH=$(DATA_PATH) $(COMPOSE) up -d --build

folders:
	mkdir -p $(DATA_PATH)/mariadb
	mkdir -p $(DATA_PATH)/wordpress

down:
	DATA_PATH=$(DATA_PATH) $(COMPOSE) down

re: down all

.PHONY: all folders down re