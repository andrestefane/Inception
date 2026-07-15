# montar un contenedor
docker compose build wordpress

# bajar un contenedor
docker compose -f data/srcs/docker-compose.yml down

# comprobar los contenedores con sus servicios iniciados
docker compose -f data/srcs/docker-compose.yml ps

# montar docker mariadb
docker compose -f data/srcs/docker-compose.yml up --build mariadb

# comprobar que mariadb se haya creado perfectamente.
docker exec -it mariadb mariadb -u root -p -e "SELECT user, host FROM mysql.user;"


# eliminar el volumen.
docker compose -f data/srcs/docker-compose.yml down -v
# tambien las imagines
docker compose -f data/srcs/docker-compose.yml down -v --rmi all



# verificar que todo se haya borrado
docker ps -a
docker volume ls
docker network ls    

# montar todo
docker compose -f data/srcs/docker-compose.yml up -d --build

# verificar los estados
docker compose -f data/srcs/docker-compose.yml ps
docker volume ls

# verificar logs de mariadb
docker compose -f data/srcs/docker-compose.yml logs -f mariadb

# para listar directamente sin entrar en wordpress
docker exec wordpress wp user list --path=/var/www/wordpress --allow-root

# probar ftp server
ftp astefane.42.fr

# probar redir
docker exec -it redis redis-cli ping
