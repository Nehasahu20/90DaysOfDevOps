# Day 38 – Complete Docker Cheat Sheet

## Docker System & Disk Usage

```bash
# Summary: images, containers, volumes, cache
docker system df

# Detailed breakdown
docker system df -v
```

---

# Container Commands

## Run Containers

```bash
docker run nginx
# Run container in foreground

docker run -d nginx
# Run detached (background)

docker run -it ubuntu bash
# Interactive shell

docker run -d -p 8080:80 --name web nginx
# Named container + port mapping

docker run -d -v mydata:/data nginx
# Named volume

docker run -d -v $(pwd)/html:/usr/share/nginx/html nginx
# Bind mount

docker run --rm ubuntu echo "hello"
# Auto-remove container after exit

docker run -e ENV_VAR=value nginx
# Set environment variable
```

---

## Manage Containers

```bash
docker ps
# Running containers

docker ps -a
# All containers (including stopped)

docker stop web
# Graceful stop (SIGTERM → SIGKILL)

docker kill web
# Immediate stop (SIGKILL)

docker start web
# Start stopped container

docker restart web
# Restart container

docker rm web
# Remove stopped container

docker rm -f web
# Force remove running container

docker rm $(docker ps -aq)
# Remove all containers
```

---

## Interact with Containers

```bash
docker exec -it web bash
# Open bash shell

docker exec -it web sh
# Use sh if bash unavailable (Alpine)

docker exec web cat /etc/nginx/nginx.conf
# Run single command
```

---

## Container Logs

```bash
docker logs web
# Show all logs

docker logs -f web
# Follow logs

docker logs --tail 50 web
# Last 50 lines

docker logs --since 5m web
# Logs from last 5 minutes
```

---

## Inspect Containers

```bash
docker inspect web
# Full JSON details

docker stats
# Live CPU / Memory / Network usage

docker top web
# Running processes

docker port web
# Port mappings

docker diff web
# Filesystem changes from image
```

---

## Copy Files

```bash
docker cp web:/etc/nginx/nginx.conf .
# Copy file OUT of container

docker cp index.html web:/usr/share/nginx/html/
# Copy file INTO container
```

---

# Image Commands

## Pull Images

```bash
docker pull nginx
# Latest tag

docker pull nginx:1.25-alpine
# Specific version (recommended)
```

---

## Build Images

```bash
docker build -t myapp:v1 .
# Build using Dockerfile

docker build -t myapp:v1 -f Dockerfile.prod .
# Custom Dockerfile

docker build --no-cache -t myapp:v1 .
# Ignore cache

docker build --build-arg VERSION=2.0 .
# Pass build argument
```

---

## Manage Images

```bash
docker images
# List images

docker images | grep myapp
# Filter images

docker rmi myapp:v1
# Remove image

docker rmi $(docker images -q)
# Remove all images

docker image prune
# Remove dangling images
```

---

## Tag & Push

```bash
docker tag myapp:v1 user/myapp:v1
# Tag image

docker login
# Login to Docker Hub

docker push user/myapp:v1
# Push image

docker pull user/myapp:v1
# Pull image
```

---

## Inspect Images

```bash
docker history myapp:v1
# Image layers

docker inspect myapp:v1
# Image metadata
```

---

# Volume Commands

## Manage Volumes

```bash
docker volume create mydata
# Create volume

docker volume ls
# List volumes

docker volume inspect mydata
# Inspect volume

docker volume rm mydata
# Remove volume

docker volume prune
# Remove unused volumes
```

---

## Mount Types

### Named Volume

```bash
docker run -v mydata:/var/lib/mysql mysql
```

Docker manages storage location.

---

### Bind Mount

```bash
docker run -v /home/user/app:/app nginx

docker run -v $(pwd):/app nginx
```

You control the host path.

---

### Read-Only Mount

```bash
docker run -v mydata:/data:ro nginx
```

Container cannot modify mounted data.

---

# Network Commands

## Manage Networks

```bash
docker network create mynet
# Create bridge network

docker network create --driver host mynet
# Host network

docker network ls
# List networks

docker network inspect mynet
# Network details

docker network rm mynet
# Remove network

docker network prune
# Remove unused networks
```

---

## Connect Containers

```bash
docker run -d --network mynet --name db postgres

docker run -d --network mynet --name web nginx
```

Test communication:

```bash
docker exec web ping db
```

DNS resolution works automatically.

---

## Connect Running Containers

```bash
docker network connect mynet web

docker network disconnect mynet web
```

---

# Dockerfile Instructions Reference

## Base Image

```dockerfile
FROM python:3.11-slim
```

Required first instruction.

---

## Working Directory

```dockerfile
WORKDIR /app
```

Creates directory if needed.

---

## Copy Files

```dockerfile
COPY requirements.txt .

COPY . .
```

---

## Add Files

```dockerfile
ADD archive.tar.gz /app
```

Can auto-extract tar archives.

---

## Run Commands During Build

```dockerfile
RUN pip install flask
```

Creates a new image layer.

---

## Expose Port

```dockerfile
EXPOSE 5000
```

Documentation only.

Does NOT publish port.

---

## Environment Variables

```dockerfile
ENV APP_ENV=production
```

Available inside container.

---

## Build Arguments

```dockerfile
ARG VERSION=1.0
```

Available only during build.

---

## Volumes

```dockerfile
VOLUME ["/data"]
```

Declares mount point.

---

## User

```dockerfile
USER appuser
```

Run container as non-root.

---

## Labels

```dockerfile
LABEL version="1.0"
```

Image metadata.

---

## Healthchecks

```dockerfile
HEALTHCHECK --interval=30s \
CMD curl -f http://localhost/ || exit 1
```

Defines container health.

---

# CMD vs ENTRYPOINT

## CMD Only

```dockerfile
CMD ["python", "app.py"]
```

Run:

```bash
docker run myapp
```

Result:

```text
python app.py
```

Override:

```bash
docker run myapp bash
```

Result:

```text
bash
```

CMD completely replaced.

---

## ENTRYPOINT + CMD

```dockerfile
ENTRYPOINT ["python"]

CMD ["app.py"]
```

Run:

```bash
docker run myapp
```

Result:

```text
python app.py
```

Override CMD:

```bash
docker run myapp other.py
```

Result:

```text
python other.py
```

Override ENTRYPOINT:

```bash
docker run --entrypoint bash myapp
```

---

# Docker Compose Commands

## Start Services

```bash
docker compose up
# Foreground

docker compose up -d
# Detached

docker compose up -d --build
# Rebuild + start

docker compose up --scale web=3 -d
# Scale service
```

---

## Stop & Remove

```bash
docker compose down
# Remove containers + networks

docker compose down -v
# Remove containers + networks + volumes
# WARNING: DATA LOSS
```

---

## Stop / Start Only

```bash
docker compose stop
# Stop services

docker compose start
# Start stopped services
```

---

## Service Status

```bash
docker compose ps
# Service status + ports
```

---

## Logs

```bash
docker compose logs
# All logs

docker compose logs -f
# Follow logs

docker compose logs -f web
# Specific service

docker compose logs --tail 100 web
# Last 100 lines
```

---

## Build Operations

```bash
docker compose build
# Build all services

docker compose build --no-cache web
# Rebuild without cache
```

---

## Pull Images

```bash
docker compose pull
# Pull latest images
```

---

## Execute Commands

```bash
docker compose exec web bash
# Shell into running service

docker compose run --rm web pytest
# One-off command
```

---

## Validate Compose File

```bash
docker compose config
# Validate and render final config
```

---

## Restart Service

```bash
docker compose restart web
```

---

# Cleanup Commands

## Full Cleanup

```bash
docker system prune
# Remove:
# - Stopped containers
# - Unused networks
# - Dangling images

docker system prune -a
# Also removes unused images

docker system prune -a --volumes
# EVERYTHING including volumes
# WARNING: DATA LOSS
```

---

## Individual Cleanup

```bash
docker container prune
# Remove stopped containers

docker image prune
# Remove dangling images

docker image prune -a
# Remove unused images

docker volume prune
# Remove unused volumes

docker network prune
# Remove unused networks
```

---

# Docker Learning Summary

| Day | Topic |
|------|--------|
| Day 29 | Docker Fundamentals |
| Day 30 | Images & Containers |
| Day 31 | Volumes & Persistence |
| Day 32 | Networking |
| Day 33 | Docker Compose Basics |
| Day 34 | Production Compose |
| Day 35 | Multi-Stage Builds & Docker Hub |
| Day 36 | Full Dockerized Application |
| Day 37 | Revision & Cheat Sheet |
| Day 38 | YAML Basics |

---

# Final Takeaway

By this point you should be comfortable with:

✅ Images & Containers

✅ Dockerfiles

✅ Volumes

✅ Networks

✅ Docker Compose

✅ Multi-Stage Builds

✅ Healthchecks

✅ Docker Hub

✅ Production Best Practices

✅ YAML Fundamentals

Next steps:

```text
Docker
   ↓
YAML
   ↓
GitHub Actions
   ↓
Kubernetes
   ↓
Helm
   ↓
CI/CD Pipelines
   ↓
Cloud Deployments
```
