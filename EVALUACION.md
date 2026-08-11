# Guía de Preparación para la Evaluación — Inception

Documento de preparación para la defensa basado en la hoja de evaluación (scale) del proyecto. Incluye la estructura de la evaluación, los comandos que usará el evaluador, las preguntas de teoría con respuestas y un checklist final.

---

## 1. Estructura de la evaluación

| Sección | Qué evalúa |
|---------|-----------|
| Preliminaries | Clone del repo, ausencia de credenciales en git, defensa en persona |
| General instructions | Estructura (`srcs/` en raíz, Makefile), docker-compose, Dockerfiles, loops infinitos |
| Mandatory part | Nginx+SSL/TLS, WordPress+volumen, MariaDB+volumen, persistencia, modificación de configuración |
| Bonus | Redis, FTP, static, Adminer, servicio libre (Uptime Kuma) |

Regla general: si un check falla donde la hoja dice *"the evaluation ends now"*, la evaluación se detiene. Hay que llegar con todo funcionando y dominando la teoría.

---

## 2. Comandos que usará el evaluador

### 2.1 Preparación (borra TODO el entorno docker)
```bash
docker stop $(docker ps -qa); docker rm $(docker ps -qa)
docker rmi -f $(docker images -qa)
docker volume rm $(docker volume ls -q)
docker network rm $(docker network ls -q) 2>/dev/null
```

### 2.2 Arranque
```bash
make            # o make up  →  docker compose up -d --build
```

### 2.3 Verificaciones

| Check | Comando |
|-------|---------|
| Contenedores arriba | `docker compose -f <srcs>/docker-compose.yml ps` |
| Red visible | `docker network ls` |
| Volumen WordPress | `docker volume ls` → `docker volume inspect <vol>` |
| Volumen MariaDB | `docker volume inspect <vol>` |
| SSL/TLS 1.2 y 1.3 | `docker exec nginx openssl s_client -connect localhost:443 -tls1_2 < /dev/null \| grep Protocol` (y `-tls1_3`) |
| https responde | `curl -vk https://<login>.42.fr` |
| DB con datos | `docker compose -f <srcs>/docker-compose.yml exec mariadb mariadb -u root -p wordpress -e "SHOW TABLES;"` |
| Secrets montados | `docker exec wordpress ls /run/secrets/` |
| Passwords ocultos | `docker inspect wordpress \| grep -i password` → debe devolver nada |

---

## 3. Preguntas de teoría para la defensa

### 3.1 ¿Cómo funcionan Docker y Docker Compose?
- **Docker**: los contenedores son procesos aislados mediante **namespaces** (PID, red, mount, UID...) y limitados en recursos con **cgroups** (CPU, memoria, I/O). Comparten el kernel del host.
- **Imagen**: sistema de archivos de solo lectura en capas + configuración. **Contenedor**: instancia en ejecución con capa de escritura efímera.
- **Docker Compose**: define el stack multi-contenedor en un YAML (servicios, redes, volúmenes, secrets, dependencias) y lo orquesta con un solo comando.

### 3.2 Imagen usada con docker compose vs sin docker compose
- Sin compose: `docker build` y `docker run` con flags largos, gestión manual contenedor a contenedor.
- Con compose: `docker compose up -d --build`; declaras todo en un fichero, los servicios se resuelven por nombre de servicio dentro de su red y las dependencias (`depends_on`) se gestionan automáticamente.

### 3.3 ¿Por qué Docker frente a VMs?
| VM | Docker |
|----|--------|
| Hipervisor + SO completo por VM | Procesos sobre el kernel del host |
| Tamaño en GBs, arranque en minutos | Tamaño en MBs, arranque en segundos |
| Sobrecarga del hipervisor | Rendimiento casi nativo |
| Aislamiento total (kernel propio) | Aislamiento a nivel de procesos (namespaces/cgroups) |

### 3.4 Pertinencia de la estructura del directorio
- `srcs/` centraliza toda la configuración del proyecto en un solo lugar (obligatorio por el sujeto).
- `requirements/` con un Dockerfile por servicio: cada servicio tiene su imagen propia y reproducible.
- `data/` separada de `srcs/`: configuración versionable vs datos persistentes que no se versionan.

### 3.5 ¿Qué es docker-network?
- Red **bridge**: cada contenedor tiene su propio namespace de red; los puertos se publican explícitamente con `-p`; los contenedores de la misma red se comunican por nombre de servicio.
- Aislamiento con el host: a diferencia de `network: host`, no comparten el stack de red de la máquina.
- En el proyecto: una sola red bridge `inception` para todos los servicios.

### 3.6 Volúmenes y persistencia
- Volúmenes nombrados con bind-mount (`driver_opts: type=none, o=bind, device=/home/<login>/data/...`) → los datos viven en el host.
- Sobreviven a `docker compose down` y a reinicios de la VM (check "Persistence!").
- Solo se borran con `docker compose down -v` o `make fclean`.

### 3.7 Secrets
- Docker secrets montan ficheros en `/run/secrets/<nombre>` dentro del contenedor.
- No aparecen en `docker inspect` ni en el entorno del proceso.
- Se crean en la máquina durante la evaluación, no se commitean al repo.

### 3.8 SSL/TLS
- Certificado autogenerado (self-signed) en la build de nginx (`openssl req -x509`).
- Solo TLS v1.2 y TLS v1.3 configurado (`ssl_protocols`).
- El warning del navegador es aceptable según la hoja (no hace falta CA reconocida).

### 3.9 Usuarios de WordPress
- Admin: `crack` — no contiene "admin" (cumple la restricción de la hoja).
- Usuario normal: `astefane` (role author) para probar comentarios.

### 3.10 Bonus: Uptime Kuma (servicio libre)
- Monitor de servicios open-source con dashboard web (healthchecks HTTP/TCP).
- Justificación: permite ver de un vistazo que toda la infraestructura responde.
- Monta `/var/run/docker.sock` para monitorizar contenedores → prepárate para explicar este punto (acceso al daemon, riesgo de seguridad).

---

## 4. Check de cada parte de la hoja

### 4.1 Preliminaries
- [ ] Repo clonado en directorio vacío con `git clone`.
- [ ] Sin credenciales/passwords en el repositorio (solo `.env` o secrets creados durante la evaluación).
- [ ] Defensa presencial.

### 4.2 General instructions
- [ ] `srcs/` en la raíz del repo con toda la configuración.
- [ ] Makefile en la raíz.
- [ ] `docker-compose.yml` sin `network: host` ni `links:`.
- [ ] `docker-compose.yml` con `networks:` definidas.
- [ ] Sin `--link` en Makefile ni scripts.
- [ ] Dockerfiles sin `tail -f` ni comandos en background en la sección ENTRYPOINT; sin `bash`/`sh` sueltos (solo para scripts).
- [ ] Imágenes base: penúltima estable de Alpine o Debian.
- [ ] Sin loops infinitos en scripts (`sleep infinity`, `tail -f /dev/null`, ...).
- [ ] `make` funciona sin crashes.

### 4.3 Mandatory part
- [ ] Explicar Docker, compose, imágenes, VMs y estructura (teoría sección 3).
- [ ] README.md en raíz: primera línea *"This project has been created as part of the 42 curriculum by <login>."* (italicizada) + secciones Description, Instructions, Resources (uso de IA).
- [ ] USER_DOC.md y DEV_DOC.md presentes y completos.
- [ ] Nginx accesible solo por 443, con certificado TLS, WordPress instalado (no la página de instalación), http bloqueado.
- [ ] Un Dockerfile por servicio, no vacíos, propios (no imágenes ready-made de DockerHub), nombre de imagen = nombre de servicio, construidos con docker compose sin crashes.
- [ ] Red docker-network visible en `docker network ls`.
- [ ] Nginx: contenedor arriba, http no conecta, https muestra WordPress, TLS 1.2/1.3 demostrable.
- [ ] WordPress: Dockerfile sin nginx, contenedor arriba, volumen con ruta `/home/<login>/data/`, poder añadir comentario con el usuario normal, admin sin "admin" en el nombre, editar página y verla actualizada.
- [ ] MariaDB: Dockerfile sin nginx, contenedor arriba, volumen con ruta `/home/<login>/data/`, saber explicar cómo entrar a la DB, DB no vacía.
- [ ] Persistencia: reiniciar la VM, `docker compose up` de nuevo y comprobar que WordPress y MariaDB siguen configurados con los cambios previos.
- [ ] Modificación de configuración: cambiar un puerto de un servicio, rebuild, restart y que siga funcional.

### 4.4 Bonus (solo si la parte obligatoria está perfecta)
- [ ] **Redis cache**: configurado como cache de WordPress (plugin `redis-cache`, `WP_REDIS_HOST`).
- [ ] **FTP**: servidor vsftpd apuntando al volumen de WordPress.
- [ ] **Static**: sitio web estático en un lenguaje distinto de PHP.
- [ ] **Adminer**: interfaz de gestión de la DB.
- [ ] **Servicio libre**: Uptime Kuma, con justificación de su utilidad.

---

## 5. Checklist final pre-defensa

- [ ] `make` desde un clone limpio: todo arriba sin crashes.
- [ ] `https://<login>.42.fr` muestra WordPress instalado.
- [ ] `http://<login>.42.fr` no da acceso al sitio.
- [ ] Comentario como usuario normal y edición de página como admin.
- [ ] Volúmenes inspeccionados con la ruta `/home/<login>/data/`.
- [ ] DB con tablas, acceso explicable.
- [ ] Redis responde (`redis-cli ping` → PONG).
- [ ] FTP conecta y ve los ficheros de WordPress.
- [ ] Static carga en el navegador.
- [ ] Adminer permite entrar a la DB.
- [ ] Uptime Kuma muestra el dashboard.
- [ ] Repasada la teoría de la sección 3.
