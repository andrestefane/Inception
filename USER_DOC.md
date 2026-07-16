# User Documentation — Inception

## What is this project?

Inception is a Docker-based infrastructure that runs a complete WordPress website with additional services. Everything runs inside containers managed by Docker Compose.

## Services provided

### Core services

| Service | Description | URL |
|---------|-------------|-----|
| **Nginx** | Web server with SSL/TLS encryption | `https://astefane.42.fr` |
| **WordPress** | Blog/CMS with PHP-FPM | Served via Nginx on port 443 |
| **MariaDB** | Database for WordPress | Internal (port 3306) |

### Bonus services

| Service | Description | URL |
|---------|-------------|-----|
| **Adminer** | Database management web interface | `http://astefane.42.fr:8080` |
| **FTP Server** | File transfer access to WordPress files | `astefane.42.fr:21` |
| **Redis** | Cache system for WordPress | Internal (port 6379) |
| **Static Site** | Simple HTML showcase page | `http://astefane.42.fr:80` |
| **Uptime Kuma** | Service monitoring dashboard | `http://astefane.42.fr:3001` |

## How to start the project

Make sure Docker and Docker Compose are installed on your machine, then run:

```bash
make up
```

This will build all Docker images and start every container.

## How to stop the project

```bash
make down
```

## How to access the services

1. **WordPress**: Open your browser and go to `https://astefane.42.fr`. You may need to add the self-signed certificate exception.
2. **Adminer**: Go to `http://astefane.42.fr:8080` to manage the MariaDB database from a web interface.
3. **Static site**: Go to `http://astefane.42.fr:80` to see the simple showcase page.
4. **Uptime Kuma**: Go to `http://astefane.42.fr:3001` to set up and view service monitoring.
5. **FTP**: Connect via any FTP client to `astefane.42.fr` on port 21 using the configured FTP user.

## Credentials

All credentials are stored locally in the `secrets/` directory as text files:

| File | Contains |
|------|----------|
| `secrets/db_password.txt` | Password for the WordPress database user |
| `secrets/db_root_password.txt` | Root password for MariaDB |
| `secrets/credentials.txt` | Additional credentials |

Environment variables are defined in `srcs/.env` and include the domain name, MySQL user, WordPress admin user, etc.

**Important**: These files are excluded from Git via `.gitignore`. Never commit credentials to the repository.

## Check that services are running

To verify all containers are up and healthy:

```bash
docker compose -f data/srcs/docker-compose.yml ps
```

You should see all containers in "Up" or "running" state. You can also check individual logs:

```bash
docker compose -f data/srcs/docker-compose.yml logs -f <service_name>
```

Replace `<service_name>` with `nginx`, `wordpress`, `mariadb`, `adminer`, `ftp`, `redis`, `static`, or `uptime`.

## Troubleshooting

- If WordPress doesn't load, make sure `astefane.42.fr` points to your local IP in `/etc/hosts`.
- If a container keeps restarting, check its logs with the command above.
- To fully reset everything (containers, images, volumes, and data):

```bash
make fclean
```

Then rebuild with `make up`.
