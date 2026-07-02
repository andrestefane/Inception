# comprobar que mariadb se haya creado perfectamente
docker exec -it mariadb mariadb -u root -p -e "SELECT user, host FROM mysql.user;"