# Day 34 – Docker Compose: Real-World Multi-Container Apps

## Why This Day Matters

Day 33 covered Docker Compose basics.

Day 34 focuses on production-like deployments:

- Real applications with database + cache
- Healthchecks (wait until services are actually ready)
- Restart policies (automatic recovery from crashes)
- Named networks (better security and isolation)
- Building custom images from Dockerfiles
- Scaling services

---

# Verify Environment Variables

## Check Final Resolved Compose Configuration

```bash
docker compose config
```

Shows the final `docker-compose.yml` after all variables from `.env` have been substituted.

### Example Use

```bash
docker compose config
```

Useful for debugging environment variable issues.

---

## Check Environment Variables Inside a Running Container

```bash
docker compose exec wordpress env | grep WORDPRESS
```

Displays all WordPress-related environment variables currently available inside the container.

---

# Project Structure

```text
my-app/
├── docker-compose.yml
├── .env
└── app/
    ├── Dockerfile
    ├── app.py
    └── requirements.txt
```

---

# Task 1 – Build a Real Application

## requirements.txt

**app/requirements.txt**

```txt
flask
psycopg2-binary
redis
```

---

## Flask Application

**app/app.py**

```python
from flask import Flask
import psycopg2
import redis
import os

app = Flask(__name__)

# Redis service name = cache
r = redis.Redis(host='cache', port=6379)

@app.route('/')
def index():

    # Increment page hit counter
    r.incr('hits')

    conn = psycopg2.connect(
        host=os.getenv('DB_HOST'),
        database=os.getenv('DB_NAME'),
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASS')
    )

    return f"Hello! Page hits: {r.get('hits').decode()}"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

---

## Dockerfile

**app/Dockerfile**

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .

CMD ["python", "app.py"]
```

---

# Task 2 – depends_on with Healthchecks

## The Problem

Without healthchecks:

```text
1. PostgreSQL container starts
2. Database needs ~5 seconds to initialize
3. Web container starts immediately
4. Web tries to connect
5. Connection fails
```

Container started ≠ service ready.

---

## Solution: Healthchecks

### PostgreSQL Healthcheck

```yaml
services:

  db:
    image: postgres:15

    restart: always

    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASS}

    volumes:
      - pg_data:/var/lib/postgresql/data

    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]

      interval: 10s
      timeout: 5s
      retries: 5
```

### What is `pg_isready`?

PostgreSQL's built-in readiness checker.

Returns success only when PostgreSQL accepts connections.

---

## Redis Healthcheck

```yaml
cache:
  image: redis:7-alpine

  restart: always

  healthcheck:
    test: ["CMD", "redis-cli", "ping"]

    interval: 10s
    timeout: 3s
    retries: 5
```

### What Happens?

```bash
redis-cli ping
```

Healthy response:

```text
PONG
```

---

## Wait for Healthy Services

```yaml
web:
  build: ./app

  depends_on:

    db:
      condition: service_healthy

    cache:
      condition: service_healthy
```

### Startup Flow

```text
db starts
     ↓
db becomes healthy
     ↓
cache starts
     ↓
cache becomes healthy
     ↓
web starts
```

---

## Full Compose Example

```yaml
services:

  db:
    image: postgres:15

    restart: always

    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASS}

    volumes:
      - pg_data:/var/lib/postgresql/data

    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
      interval: 10s
      timeout: 5s
      retries: 5

  cache:
    image: redis:7-alpine

    restart: always

    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5

  web:
    build: ./app

    ports:
      - "5000:5000"

    environment:
      DB_HOST: db
      DB_NAME: ${DB_NAME}
      DB_USER: ${DB_USER}
      DB_PASS: ${DB_PASS}

    depends_on:
      db:
        condition: service_healthy
      cache:
        condition: service_healthy

    restart: on-failure

volumes:
  pg_data:
```

---

## Start Application

```bash
docker compose up -d
```

Monitor health status:

```bash
watch docker compose ps
```

Example status progression:

```text
starting
   ↓
healthy
   ↓
web starts
```

---

# Task 3 – Restart Policies

## Restart Policy Comparison

| Policy | Behavior | Best Use Case |
|----------|----------|----------|
| always | Restart regardless of reason | Databases, Redis |
| on-failure | Restart only after crash | Web applications |
| unless-stopped | Restart except when manually stopped | Development |
| no | Never restart | One-time jobs |

---

## Example

### Database

```yaml
restart: always
```

### Application

```yaml
restart: on-failure
```

---

## Test Restart Policy

Kill PostgreSQL manually:

```bash
docker kill $(docker ps -qf "name=db")
```

Check status:

```bash
docker compose ps
```

Result:

```text
db automatically restarts
```

because:

```yaml
restart: always
```

---

# Task 4 – Build Images from Dockerfile

## Build Everything

```bash
docker compose up -d --build
```

Builds images and starts containers.

---

## Rebuild Only Web Service

```bash
docker compose up -d --build web
```

Useful after editing:

```text
app.py
requirements.txt
Dockerfile
```

---

## Force Rebuild Without Cache

```bash
docker compose build --no-cache web
```

Then start:

```bash
docker compose up -d
```

---

# Task 5 – Named Networks for Better Security

## Why Named Networks?

Default Compose behavior:

```text
All services on one network
```

Result:

```text
Every service can reach every other service
```

Not ideal for security.

---

## Better Approach

Create separate networks:

```text
frontend
backend
```

---

## Compose Example

```yaml
services:

  db:
    image: postgres:15

    networks:
      - backend

    labels:
      app: myapp
      tier: database

  cache:
    image: redis:7-alpine

    networks:
      - backend

    labels:
      app: myapp
      tier: cache

  web:
    build: ./app

    ports:
      - "5000:5000"

    networks:
      - frontend
      - backend

    labels:
      app: myapp
      tier: web

networks:

  frontend:
    # public

  backend:
    # private
```

---

## Network Architecture

```text
                Host
                 |
                 |
           Frontend Network
                 |
                 |
             +-------+
             |  Web  |
             +-------+
                 |
          Backend Network
         /                \
        /                  \
+-------------+     +-------------+
| PostgreSQL  |     |    Redis    |
+-------------+     +-------------+
```

Result:

✅ Host can access Web

✅ Web can access PostgreSQL

✅ Web can access Redis

❌ Host cannot access PostgreSQL directly

❌ Host cannot access Redis directly

---

## Inspect Networks

List networks:

```bash
docker network ls
```

Inspect backend network:

```bash
docker network inspect myapp_backend
```

---

# Task 6 – Scaling (Bonus)

## Attempt Scaling

```bash
docker compose up --scale web=3 -d
```

Error:

```text
port 5000 already allocated
```

Why?

All three containers try to bind:

```text
Host Port 5000
```

which is impossible.

---

## Fix

Remove fixed host port:

```yaml
web:
  ports:
    - "5000"
```

Docker automatically assigns ports.

---

## Scale Again

```bash
docker compose up --scale web=3 -d
```

Check:

```bash
docker compose ps
```

Example output:

```text
web_1 -> 0.0.0.0:32768->5000/tcp
web_2 -> 0.0.0.0:32769->5000/tcp
web_3 -> 0.0.0.0:32770->5000/tcp
```

---

## Limitation of Simple Compose Scaling

Compose can create multiple containers but:

❌ No load balancing

❌ No traffic distribution

❌ No automatic service discovery

For real horizontal scaling use:

- Nginx
- Traefik
- Docker Swarm
- Kubernetes

---

# Key Concepts Summary

| Concept | Purpose |
|----------|----------|
| healthcheck | Verify service readiness |
| service_healthy | Wait for healthy service before starting dependent service |
| restart: always | Restart continuously |
| restart: on-failure | Restart only after crashes |
| build: | Build image from Dockerfile |
| networks | Control communication paths |
| labels | Metadata for containers |
| volumes | Persistent data storage |
| scale | Run multiple instances of a service |

---

# Quick Reference

```bash
docker compose config

docker compose up -d
docker compose up -d --build

docker compose up -d --build web

docker compose build --no-cache web

docker compose ps

docker compose logs -f

watch docker compose ps

docker network ls
docker network inspect myapp_backend

docker compose up --scale web=3 -d

docker compose exec wordpress env | grep WORDPRESS
```

---

## Final Takeaway

Day 34 introduces production-style Docker Compose setups by combining:

- Flask application
- PostgreSQL database
- Redis cache
- Healthchecks
- Restart policies
- Named networks
- Custom image builds
- Service scaling

These concepts form the foundation for deploying real-world containerized applications before moving to Docker Swarm or Kubernetes.
