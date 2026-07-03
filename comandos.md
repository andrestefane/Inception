# comprobar que mariadb se haya creado perfectamente.
docker exec -it mariadb mariadb -u root -p -e "SELECT user, host FROM mysql.user;"
# eliminar la imagen y el volumen.
docker compose -f data/srcs/docker-compose.yml down --rmi all -v
