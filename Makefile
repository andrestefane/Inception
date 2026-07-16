COMPOSE_FILE = data/srcs/docker-compose.yml
DATA_DIR = /home/astefane/Inception/data

all: up

up:
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress
	@mkdir -p $(DATA_DIR)/uptime
	docker compose -f $(COMPOSE_FILE) up -d --build

down:
	docker compose -f $(COMPOSE_FILE) down

clean: down
	docker compose -f $(COMPOSE_FILE) down --rmi all

fclean: clean
	docker compose -f $(COMPOSE_FILE) down -v
	sudo rm -rf $(DATA_DIR)/mariadb/*
	sudo rm -rf $(DATA_DIR)/wordpress/*
	sudo rm -rf $(DATA_DIR)/uptime/*

re: fclean all

.PHONY: all up down clean fclean re