# Developer Documentation — Inception

## Prerequisites

- Docker Engine (with `docker compose` plugin)
- Make
- `sudo` access (for cleaning volume data directories)
- A Linux host machine (or VM)

## Project structure

```
Inception/
├── Makefile
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
├── data/
│   ├── mariadb/          # MariaDB persistent data
│   ├── wordpress/        # WordPress persistent data
│   ├── uptime/           # Uptime Kuma persistent data
│   └── srcs/
│       ├── docker-compose.yml
│       ├── .env
│       └── requirements/
│           ├── nginx/
│           │   ├── Dockerfile
│           │   ├── conf/nginx.conf
│           │   └── tools/entrypoint.sh
│           ├── wordpress/
│           │   ├── Dockerfile
│           │   ├── conf/
│           │   └── tools/
│           ├── mariadb/
│           │   ├── Dockerfile
│           │   ├── conf/
│           │   └── tools/
│           └── bonus/
│               ├── adminer/
│               ├── ftp/
│               ├── redis/
│               ├── static/
│               └── uptime/
```

## Setting up from scratch

### 1. Configure your domain

Add the following line to `/etc/hosts`:

```
127.0.0.1    astefane.42.fr
```

### 2. Create secrets

Create the `secrets/` directory at the project root and add the required files:

```bash
mkdir -p secrets
echo "your_db_password" > secrets/db_password.txt
echo "your_root_password" > secrets/db_root_password.txt
echo "your_credentials" > secrets/credentials.txt
```

### 3. Review environment variables

Edit `data/srcs/.env` to configure domain, database, and user settings:

```
DOMAIN_NAME=astefane.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_ADMIN_USER=boss_user
WP_ADMIN_USER=crack
WP_ADMIN_EMAIL=crack@gmail.com
WP_USER=astefane
WP_USER_EMAIL=astefane@gmail.com
FTP_USER=astefane
```

## Building and launching

Build all images and start all containers:

```bash
make up
```

This runs `docker compose up -d --build` against `data/srcs/docker-compose.yml`.

## Managing containers

| Command | Description |
|---------|-------------|
| `make up` | Build and start all containers |
| `make down` | Stop all containers |
| `make clean` | Stop containers and remove all images |
| `make fclean` | Clean everything including volumes and data directories |
| `make re` | Full rebuild from scratch |

### Manual Docker Compose commands

```bash
# Check container status
docker compose -f data/srcs/docker-compose.yml ps

# View logs for a specific service
docker compose -f data/srcs/docker-compose.yml logs -f nginx

# Restart a single service
docker compose -f data/srcs/docker-compose.yml restart wordpress

# Rebuild a single service
docker compose -f data/srcs/docker-compose.yml up -d --build nginx
```

## Managing volumes

### Named volumes

| Volume | Host path | Container path | Purpose |
|--------|-----------|----------------|---------|
| `mariadb_data` | `/home/astefane/data/mariadb` | `/var/lib/mysql` | MariaDB data |
| `wordpress_data` | `/home/astefane/data/wordpress` | `/var/www/wordpress` | WordPress files |
| `uptime_data` | `/home/astefane/data/uptime` | `/app/data` | Uptime Kuma data |

### Volume commands

```bash
# List all volumes
docker volume ls

# Inspect a specific volume
docker volume inspect inception_mariadb_data

# Remove all volumes
docker compose -f data/srcs/docker-compose.yml down -v
```

### Data persistence

Data persists on the host machine inside `/home/astefane/data/` through Docker named volumes with bind-mount backing. Even if all containers are stopped, the data remains. Only `make fclean` or manually deleting the data directories will remove it.

## Network

All services communicate through a single bridge network called `inception`. Containers resolve each other by service name (e.g., `wordpress`, `mariadb`, `redis`).

```bash
# List networks
docker network ls

# Inspect the inception network
docker network inspect inception
```

## Secrets

Secrets are managed via Docker secrets (not environment variables). The files are located at `secrets/` and referenced in `docker-compose.yml`:

```yaml
secrets:
  db_password:
    file: ../../secrets/db_password.txt
  db_root_password:
    file: ../../secrets/db_root_password.txt
  credentials:
    file: ../../secrets/credentials.txt
```

Inside containers, secrets are accessible at `/run/secrets/<secret_name>`.

**Warning**: The `secrets/` directory and `.env` are excluded from Git. Never commit them.
