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

# probar redis
docker exec -it redis redis-cli ping

# ============================================================
# NGINX
# ============================================================

# comprobar que nginx responde por TLS en el puerto 443
curl -vk https://astefane.42.fr

# comprobar que no acepta conexiones sin TLS (puerto 80 no deberia responder en nginx)
curl -k http://astefane.42.fr 2>&1 | head -5

# verificar el certificado SSL generado
docker exec nginx cat /etc/nginx/ssl/nginx.crt | openssl x509 -noout -subject -dates

# comprobar que solo se usa TLSv1.2 o TLSv1.3
docker exec nginx openssl s_client -connect localhost:443 -tls1_2 < /dev/null 2>&1 | grep Protocol
docker exec nginx openssl s_client -connect localhost:443 -tls1_3 < /dev/null 2>&1 | grep Protocol

# comprobar la configuracion de nginx
docker exec nginx cat /etc/nginx/nginx.conf

# comprobar logs de nginx
docker compose -f data/srcs/docker-compose.yml logs -f nginx

# ============================================================
# WORDPRESS
# ============================================================

# comprobar que wordpress esta respondiendo a traves de nginx
curl -vk https://astefane.42.fr | head -20

# comprobar que php-fpm esta funcionando
docker exec wordpress ps aux | grep php-fpm

# comprobar que los archivos de wordpress existen en el volumen
docker exec wordpress ls -la /var/www/wordpress/

# listar los usuarios de wordpress
docker exec wordpress wp user list --path=/var/www/wordpress --allow-root

# comprobar el wp-config.php (no debe contener passwords en texto plano)
docker exec wordpress cat /var/www/wordpress/wp-config.php | grep -i "DB_PASSWORD\|DB_USER\|DB_NAME"

# comprobar logs de wordpress
docker compose -f data/srcs/docker-compose.yml logs -f wordpress

# ============================================================
# MARIADB
# ============================================================

# comprobar que mariadb esta corriendo
docker exec mariadb mariadb -u root -p -e "SELECT VERSION();"

# listar los usuarios de la base de datos
docker exec mariadb mariadb -u root -p -e "SELECT user, host FROM mysql.user;"

# comprobar que existe la base de datos de wordpress
docker exec mariadb mariadb -u root -p -e "SHOW DATABASES;"

# comprobar que las tablas de wordpress se crearon
docker exec mariadb mariadb -u root -p wordpress -e "SHOW TABLES;"

# comprobar que el usuario de wordpress tiene permisos
docker exec mariadb mariadb -u root -p -e "SHOW GRANTS FOR 'wp_user'@'%';"

# comprobar logs de mariadb
docker compose -f data/srcs/docker-compose.yml logs -f mariadb

# ============================================================
# ADMINER
# ============================================================

# comprobar que adminer responde
curl -s http://localhost:8080 | head -5

# comprobar logs de adminer
docker compose -f data/srcs/docker-compose.yml logs -f adminer

# ============================================================
# STATIC SITE (sitio estatico)
# ============================================================

# comprobar que el sitio estatico responde
curl -s http://localhost:80

# comprobar logs de static
docker compose -f data/srcs/docker-compose.yml logs -f static

# ============================================================
# FTP SERVER
# ============================================================

# comprobar que el servidor FTP esta corriendo
docker exec ftp ps aux | grep vsftpd

# probar conexion FTP (usar tu usuario y password)
ftp astefane.42.fr

# comprobar logs de ftp
docker compose -f data/srcs/docker-compose.yml logs -f ftp

# ============================================================
# REDIS
# ============================================================

# comprobar que redis responde
docker exec -it redis redis-cli ping
# debe responder PONG

# comprobar la configuracion de redis
docker exec redis cat /etc/redis/redis.conf

# comprobar logs de redis
docker compose -f data/srcs/docker-compose.yml logs -f redis

# ============================================================
# UPTIME KUMA
# ============================================================

# comprobar que uptime kuma responde
curl -s http://localhost:3001 | head -5

# comprobar logs de uptime kuma
docker compose -f data/srcs/docker-compose.yml logs -f uptime

# ============================================================
# VOLUMENES
# ============================================================

# listar todos los volumenes
docker volume ls

# inspeccionar un volumen especifico
docker volume inspect inception_mariadb_data

# comprobar que los datos persisten en el host
ls -la /home/astefane/data/mariadb/
ls -la /home/astefane/data/wordpress/
ls -la /home/astefane/data/uptime/

# ============================================================
# RED
# ============================================================

# listar redes
docker network ls

# inspeccionar la red inception
docker network inspect inception

# comprobar que los contenedores estan conectados a la red inception
docker network inspect inception | grep -A 2 "Name"

# ============================================================
# SECRETS
# ============================================================

# comprobar que los secrets existen dentro del contenedor
docker exec wordpress ls /run/secrets/
docker exec mariadb ls /run/secrets/

# comprobar que el password NO aparece en docker inspect
docker inspect wordpress | grep -i password
# no debe devolver nada

# ============================================================
# DEBUGGING GENERAL
# ============================================================

# ver logs de todos los servicios
docker compose -f data/srcs/docker-compose.yml logs

# ver el estado de todos los contenedores
docker ps -a

# entrar a un contenedor para debuggear
docker exec -it nginx /bin/sh
docker exec -it wordpress /bin/sh
docker exec -it mariadb /bin/sh

# comprobar que no hay procesos zombie o infinite loops
docker stats --no-stream
