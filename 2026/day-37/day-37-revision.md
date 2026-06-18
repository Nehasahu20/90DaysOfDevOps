# Day 37 – Docker Revision & Complete Cheat Sheet

## Purpose of This Day

Day 37 is a complete revision day.

No new concepts.

Goals:

- Consolidate everything from Days 29–36
- Build muscle memory
- Fill knowledge gaps
- Prepare for real-world Docker usage
- Create a quick-reference guide

---

# Quick-Fire Questions (Full Answers)

---

## Q1: What Is the Difference Between an Image and a Container?

### Docker Image

A Docker image is:

- Read-only
- Stored on disk
- A blueprint/template
- Not running

Think of it like a class in OOP.

```text
Class
  ↓
Docker Image
```

---

### Docker Container

A container is:

- Running instance of an image
- Has processes
- Has networking
- Has storage

Think of it like an object in OOP.

```text
Object
  ↓
Docker Container
```

---

### Example

One image can create many containers:

```text
nginx image
    │
    ├── container 1
    ├── container 2
    └── container 3
```

---

### Useful Commands

List images:

```bash
docker images
```

List running containers:

```bash
docker ps
```

List all containers:

```bash
docker ps -a
```

---

## Q2: What Happens to Data When a Container Is Removed?

Container filesystems are:

```text
Ephemeral
```

Meaning:

```bash
docker rm container_name
```

removes:

- Container
- Container filesystem
- All data stored inside it

---

### Example

```bash
docker run -it ubuntu
```

Create a file:

```bash
echo hello > test.txt
```

Remove container:

```bash
docker rm container_name
```

Result:

```text
test.txt is gone forever
```

---

## Solution: Volumes

Store data outside the container.

```bash
docker run -v mydata:/data nginx
```

Now data survives:

- Container restart
- Container deletion
- New container creation

---

## Q3: How Do Containers Communicate on the Same Network?

Through DNS-based service discovery.

Docker automatically creates DNS records.

---

### Example

```text
web
db
redis
```

If all are on the same custom network:

```text
web → db
web → redis
```

can use:

```text
db
redis
```

as hostnames.

---

### Example Connection String

```python
host="db"
```

instead of:

```python
host="172.18.0.3"
```

---

### Docker Compose Example

```yaml
services:

  web:

  db:

  redis:
```

Compose automatically provides:

```text
web
db
redis
```

DNS names.

---

### Important

Works on:

```text
✓ User-defined bridge networks
✓ Docker Compose networks
```

Not reliable on:

```text
✗ Default bridge network
```

---

## Q4: What Does `docker compose down -v` Do?

### Normal Down

```bash
docker compose down
```

Removes:

```text
✓ Containers
✓ Networks
```

Keeps:

```text
✓ Named Volumes
```

---

### Down with Volumes

```bash
docker compose down -v
```

Removes:

```text
✓ Containers
✓ Networks
✓ Named Volumes
```

---

### Example

PostgreSQL volume:

```yaml
volumes:
  pg_data:
```

Running:

```bash
docker compose down -v
```

deletes:

```text
ALL DATABASE DATA
```

---

### Rule

Use:

```bash
docker compose down
```

for normal shutdown.

Use:

```bash
docker compose down -v
```

only when starting completely fresh.

---

## Q5: Why Are Multi-Stage Builds Useful?

### Single-Stage Build

Contains:

```text
✓ Source code
✓ SDK
✓ Compiler
✓ Build tools
✓ Application
```

Result:

```text
Huge image
```

---

### Multi-Stage Build

Stage 1:

```text
Build application
```

Stage 2:

```text
Copy compiled output only
```

Everything else discarded.

---

### Result

Benefits:

- 90%+ smaller image
- Faster deployments
- Lower storage costs
- Smaller attack surface
- Better security

---

### Flow

```text
Source Code
      ↓
Builder Stage
      ↓
Compile Binary
      ↓
Copy Binary
      ↓
Runtime Stage
```

---

## Q6: COPY vs ADD

| Feature | COPY | ADD |
|----------|----------|----------|
| Copy local files | ✅ | ✅ |
| Extract tar archives | ❌ | ✅ |
| Download URLs | ❌ | ✅ |
| Predictable behavior | ✅ | ❌ |
| Recommended by Docker | ✅ | ❌ |

---

### Use COPY By Default

```dockerfile
COPY app.py .
```

---

### Use ADD Only When Needed

```dockerfile
ADD archive.tar.gz .
```

Docker automatically extracts:

```text
archive.tar.gz
```

---

### Best Practice

```text
COPY 99% of the time

ADD only for:
- tar extraction
- URL download
```

---

## Q7: What Does `-p 8080:80` Mean?

Format:

```text
HOST_PORT:CONTAINER_PORT
```

Example:

```bash
docker run -p 8080:80 nginx
```

Meaning:

```text
Host Port 8080
       ↓
Container Port 80
```

---

### Traffic Flow

```text
Browser
   ↓
localhost:8080
   ↓
Docker
   ↓
nginx:80
```

---

### Multiple Containers

Allowed:

```text
Container A → Port 80
Container B → Port 80
Container C → Port 80
```

Not allowed:

```text
Host 8080 → A
Host 8080 → B
```

Host ports must be unique.

---

### Example

```bash
docker run -d -p 8080:80 nginx

docker run -d -p 8081:80 nginx

docker run -d -p 8082:80 nginx
```

---

## Q8: How Do You Check Docker Disk Usage?

### Summary

```bash
docker system df
```

Shows:

```text
Images
Containers
Volumes
Build Cache
```

---

### Detailed View

```bash
docker system df -v
```

Shows:

```text
Every image
Every container
Every volume
Build cache usage
```

---

### Cleanup

Remove unused resources:

```bash
docker system prune
```

Remove everything unused:

```bash
docker system prune -a
```

---

# Complete Docker Cheat Sheet

---

# Container Commands

## Run Container

```bash
docker run nginx
```

---

## Run Detached

```bash
docker run -d nginx
```

---

## Run With Port Mapping

```bash
docker run -p 8080:80 nginx
```

---

## Run With Name

```bash
docker run --name web nginx
```

---

## Interactive Shell

```bash
docker run -it ubuntu bash
```

---

## List Running Containers

```bash
docker ps
```

---

## List All Containers

```bash
docker ps -a
```

---

## Stop Container

```bash
docker stop container_name
```

---

## Start Container

```bash
docker start container_name
```

---

## Restart Container

```bash
docker restart container_name
```

---

## Remove Container

```bash
docker rm container_name
```

---

## Remove Running Container

```bash
docker rm -f container_name
```

---

# Image Commands

## Pull Image

```bash
docker pull nginx
```

---

## Build Image

```bash
docker build -t myapp:v1 .
```

---

## List Images

```bash
docker images
```

---

## Remove Image

```bash
docker rmi image_name
```

---

## Image History

```bash
docker history image_name
```

---

# Logs & Debugging

## View Logs

```bash
docker logs container_name
```

---

## Follow Logs

```bash
docker logs -f container_name
```

---

## Execute Command

```bash
docker exec -it container_name bash
```

---

## Inspect Container

```bash
docker inspect container_name
```

---

# Volume Commands

## Create Volume

```bash
docker volume create mydata
```

---

## List Volumes

```bash
docker volume ls
```

---

## Inspect Volume

```bash
docker volume inspect mydata
```

---

## Remove Volume

```bash
docker volume rm mydata
```

---

# Network Commands

## List Networks

```bash
docker network ls
```

---

## Create Network

```bash
docker network create mynet
```

---

## Inspect Network

```bash
docker network inspect mynet
```

---

## Connect Container

```bash
docker network connect mynet web
```

---

# Docker Compose Commands

## Start Services

```bash
docker compose up
```

---

## Start Detached

```bash
docker compose up -d
```

---

## Rebuild and Start

```bash
docker compose up -d --build
```

---

## View Running Services

```bash
docker compose ps
```

---

## View Logs

```bash
docker compose logs -f
```

---

## Stop Services

```bash
docker compose stop
```

---

## Start Stopped Services

```bash
docker compose start
```

---

## Remove Services

```bash
docker compose down
```

---

## Remove Services + Volumes

```bash
docker compose down -v
```

---

# Docker Hub Commands

## Login

```bash
docker login
```

---

## Tag Image

```bash
docker tag myapp:v1 username/myapp:v1
```

---

## Push Image

```bash
docker push username/myapp:v1
```

---

## Pull Image

```bash
docker pull username/myapp:v1
```

---

# Cleanup Commands

## Remove Stopped Containers

```bash
docker container prune
```

---

## Remove Unused Images

```bash
docker image prune
```

---

## Remove Unused Volumes

```bash
docker volume prune
```

---

## Remove Unused Networks

```bash
docker network prune
```

---

## Full Cleanup

```bash
docker system prune -a
```

---

# Docker Learning Summary (Days 29–36)

| Day | Topic |
|------|--------|
| Day 29 | Docker Fundamentals |
| Day 30 | Docker Images & Containers |
| Day 31 | Volumes & Persistence |
| Day 32 | Networks |
| Day 33 | Docker Compose Basics |
| Day 34 | Healthchecks & Production Compose |
| Day 35 | Multi-Stage Builds & Docker Hub |
| Day 36 | Full Production Project |
| Day 37 | Revision & Cheat Sheet |

---

# Final Takeaway

By the end of Day 37 you should be comfortable with:

✅ Building Docker images

✅ Running containers

✅ Managing volumes

✅ Creating networks

✅ Writing Dockerfiles

✅ Using Docker Compose

✅ Multi-stage builds

✅ Healthchecks

✅ Docker Hub

✅ Production-ready containerized applications

These skills form the foundation for the next major step in the DevOps journey:

```text
Docker
   ↓
Kubernetes
   ↓
CI/CD Pipelines
   ↓
Cloud Deployments
```
