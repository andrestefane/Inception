*This project has been created as part of the 42 curriculum by astefane.*

# Inception

## Description

Inception is a system administration project that involves setting up a small Docker-based infrastructure composed of multiple services. The goal is to deploy a fully functional WordPress website along with supporting services, all running in isolated Docker containers orchestrated by Docker Compose.

The project covers key concepts in containerization, networking, volume management, secrets handling, and web server configuration. It includes a mandatory part (Nginx, WordPress, MariaDB) and a bonus part (Redis cache, FTP server, Adminer, static site, Uptime Kuma).

### Design choices

- **Alpine Linux** is used as the base image for all containers (penultimate stable version) for minimal image size and performance.
- **Docker Compose** orchestrates all services, networks, volumes, and secrets from a single YAML file.
- **Docker named volumes** are used for persistent storage (MariaDB data, WordPress files, Uptime Kuma data), with data stored on the host at `/home/astefane/data/`.
- **Docker secrets** are used to store all credentials (database passwords, root password, etc.) instead of exposing them in environment variables or Dockerfiles.
- **Environment variables** are stored in a `.env` file for non-sensitive configuration (domain name, usernames, database name).
- All containers are connected through a single **bridge network** called `inception`.
- Nginx is the only entrypoint to the infrastructure, serving traffic on port 443 with TLSv1.2/TLSv1.3 only.

### Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker |
|--------|-----------------|--------|
| **Isolation** | Full OS isolation via hypervisor | Process-level isolation via namespaces and cgroups |
| **Size** | GBs per VM (full OS) | MBs per container (shared kernel) |
| **Startup** | Minutes | Seconds |
| **Performance** | Overhead from hypervisor | Near-native performance |
| **Resource usage** | High (each VM runs its own OS) | Low (containers share the host kernel) |
| **Portability** | Tied to hypervisor platform | Runs anywhere Docker is installed |

Docker was chosen for this project because it allows lightweight, fast, and reproducible deployments without the overhead of full virtual machines.

### Secrets vs Environment Variables

| Aspect | Secrets | Environment Variables |
|--------|---------|----------------------|
| **Storage** | Dedicated Docker mechanism, stored in `/run/secrets/` inside containers | Passed as key-value pairs in the container environment |
| **Security** | Encrypted in transit, not visible in `docker inspect` | Visible in `docker inspect` and process listings |
| **Use case** | Passwords, API keys, tokens | Configuration values (domain, usernames, database names) |
| **Git safety** | Files kept outside the repo via `.gitignore` | `.env` file also kept outside the repo |

In this project, secrets are stored in `secrets/` as `.txt` files referenced by Docker Compose, while non-sensitive variables live in `srcs/.env`.

### Docker Network vs Host Network

| Aspect | Docker Network (bridge) | Host Network |
|--------|------------------------|--------------|
| **Isolation** | Each container gets its own network namespace | Container shares the host's network stack |
| **Port mapping** | Requires explicit `-p` port mappings | All container ports are directly on the host |
| **Security** | Containers are isolated from each other and the host | No network isolation between container and host |
| **Portability** | Consistent behavior across hosts | Behavior depends on host port availability |

Host network mode is forbidden by the subject. The project uses a custom bridge network (`inception`) that provides proper isolation while allowing containers to communicate by service name.

### Docker Volumes vs Bind Mounts

| Aspect | Docker Named Volumes | Bind Mounts |
|--------|---------------------|-------------|
| **Management** | Managed by Docker | Direct host path mapping |
| **Persistence** | Data survives container removal | Data tied to host path |
| **Performance** | Optimized by Docker driver | Depends on host filesystem |
| **Portability** | Volume data moves with Docker | Tied to specific host paths |
| **Backup** | Requires Docker commands | Direct file access on host |

Named volumes are used for the mandatory persistent storages (MariaDB and WordPress data). The volumes are configured with bind-mount backing (`type: none, o: bind`) to store data at a known host path (`/home/astefane/data/`), combining the management benefits of named volumes with direct host access.

## Instructions

### Prerequisites

- Docker Engine with `docker compose` plugin
- Make
- `sudo` access (for data cleanup)

### Domain configuration

Add the following line to your `/etc/hosts` file:

```
127.0.0.1    astefane.42.fr
```

### Secrets setup

Create the `secrets/` directory at the project root:

```bash
mkdir -p secrets
echo "your_db_password" > secrets/db_password.txt
echo "your_root_password" > secrets/db_root_password.txt
echo "your_credentials" > secrets/credentials.txt
```

### Build and run

```bash
make up
```

### Stop services

```bash
make down
```

### Full cleanup (containers, images, volumes, data)

```bash
make fclean
```

### Rebuild from scratch

```bash
make re
```

### Access the services

| Service | URL |
|---------|-----|
| WordPress | `https://astefane.42.fr` |
| Adminer | `http://astefane.42.fr:8080` |
| Static site | `http://astefane.42.fr:80` |
| Uptime Kuma | `http://astefane.42.fr:3001` |
| FTP | `astefane.42.fr:21` |

## Resources

### Documentation

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [Nginx documentation](https://nginx.org/en/docs/)
- [WordPress documentation](https://developer.wordpress.org/)
- [MariaDB documentation](https://mariadb.com/kb/en/)
- [Alpine Linux packages](https://pkgs.alpinelinux.org/)
- [Uptime Kuma](https://github.com/louislam/uptime-kuma)
- [Adminer](https://www.adminer.org/)

### How AI was used

AI (ChatGPT / opencode) was used during this project for:
- **Writing documentation**: Generating the README.md, USER_DOC.md, and DEV_DOC.md based on the project structure and subject requirements.
- **Debugging**: Assistance with Docker Compose configuration, Nginx setup, and troubleshooting container issues.
- **Code review**: Reviewing Dockerfiles and entrypoint scripts for best practices.
