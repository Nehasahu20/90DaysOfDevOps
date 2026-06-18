# Day 36 – Docker Project: Dockerize a Full Application

## What This Day Is About

Day 36 is the capstone project that combines everything learned so far:

- Docker Compose
- Multi-stage Docker builds
- PostgreSQL
- Gunicorn
- Docker Hub
- Volumes
- Networks
- Healthchecks
- Security best practices

Goal:

> Take a real application, Dockerize it, run it, test it, and publish it.

---

# Project Overview

We will build a production-style application:

```text
Flask Web Application
        +
PostgreSQL Database
```

### Technologies Used

| Component | Purpose |
|------------|------------|
| Flask | Python Web Framework |
| PostgreSQL | Production Database |
| Gunicorn | Production WSGI Server |
| Docker Compose | Multi-container orchestration |
| Docker Hub | Image registry |
| Named Volumes | Data persistence |
| Healthchecks | Service readiness |
| Multi-stage Build | Small secure image |

---

# Project Structure

```text
my-flask-app/
│
├── app/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
│
├── docker-compose.yml
├── .env
├── .dockerignore
├── init.sql
└── README.md
```

### File Breakdown

| File | Purpose |
|---------|---------|
| app.py | Flask application |
| requirements.txt | Python dependencies |
| Dockerfile | Build instructions |
| docker-compose.yml | Run all services |
| .env | Secrets/configuration |
| .dockerignore | Exclude unnecessary files |
| init.sql | Seed database |
| README.md | Project documentation |

---

# Task 1 – Build the Flask Application

## app/app.py

### Features

- `/` → Application status
- `/health` → Database health check
- `/users` → Fetch users from PostgreSQL

```python
from flask import Flask, jsonify
import psycopg2
import os

app = Flask(__name__)

def get_db():
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "db"),
        database=os.getenv("DB_NAME", "myapp"),
        user=os.getenv("DB_USER", "myuser"),
        password=os.getenv("DB_PASS", "mypass")
    )

@app.route("/")
def home():
    return jsonify({
        "message": "App is running!",
        "status": "ok"
    })

@app.route("/health")
def health():

    try:
        conn = get_db()
        conn.close()

        return jsonify({
            "db": "connected"
        }), 200

    except Exception as e:
        return jsonify({
            "db": "error",
            "detail": str(e)
        }), 500

@app.route("/users")
def users():

    conn = get_db()

    cur = conn.cursor()

    cur.execute(
        "SELECT id, name FROM users;"
    )

    rows = cur.fetchall()

    cur.close()
    conn.close()

    return jsonify([
        {
            "id": r[0],
            "name": r[1]
        }
        for r in rows
    ])

if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5000
    )
```

---

# Task 2 – Define Dependencies

## app/requirements.txt

```txt
flask==3.0.0
psycopg2-binary==2.9.9
gunicorn==21.2.0
```

---

# Task 3 – Production Dockerfile

## Multi-Stage Dockerfile

### Stage 1 – Install Dependencies

```dockerfile
FROM python:3.11-slim AS builder

WORKDIR /app

COPY requirements.txt .

RUN pip install \
    --no-cache-dir \
    --prefix=/install \
    -r requirements.txt
```

---

### Stage 2 – Production Image

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY --from=builder /install /usr/local

COPY app.py .

RUN addgroup --system appgroup && \
    adduser --system \
    --ingroup appgroup \
    appuser

USER appuser

EXPOSE 5000

CMD [
  "gunicorn",
  "--bind",
  "0.0.0.0:5000",
  "--workers",
  "2",
  "app:app"
]
```

---

## Why Use Gunicorn?

### Bad

```bash
python app.py
```

Flask development server:

- Single threaded
- Slow
- Not production ready
- Can expose debug information

---

### Good

```bash
gunicorn app:app
```

Benefits:

- Multiple workers
- Better performance
- Production-grade server
- Handles concurrent requests

---

# Task 4 – Create .dockerignore

## .dockerignore

```gitignore
__pycache__/
*.pyc
*.pyo

.env

.git
.gitignore

*.md

tests/

.venv/
```

---

## Why .dockerignore Matters

Benefits:

### Faster Builds

Less build context sent to Docker.

### Better Security

```text
.env
```

never gets copied into image.

### Smaller Images

Unnecessary files excluded.

---

# Task 5 – Configure Environment Variables

## .env

```env
DB_NAME=myapp

DB_USER=myuser

DB_PASS=securepass123

DB_HOST=db
```

⚠️ Never commit this file to GitHub.

---

# Task 6 – Seed PostgreSQL Database

## init.sql

```sql
CREATE TABLE IF NOT EXISTS users (

    id SERIAL PRIMARY KEY,

    name VARCHAR(100) NOT NULL
);

INSERT INTO users (name)
VALUES
('Alice'),
('Bob'),
('Charlie');
```

---

## How It Works

Mounted to:

```text
/docker-entrypoint-initdb.d/
```

PostgreSQL automatically executes all SQL files in this folder during first startup.

---

# Task 7 – Production docker-compose.yml

## Full Configuration

```yaml
services:

  db:
    image: postgres:15-alpine

    restart: always

    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASS}

    volumes:
      - pg_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql

    networks:
      - backend

    healthcheck:
      test:
        [
          "CMD-SHELL",
          "pg_isready -U ${DB_USER} -d ${DB_NAME}"
        ]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 10s

    labels:
      app: flask-project
      tier: database

  web:
    build:
      context: ./app
      dockerfile: Dockerfile

    image: flask-app:v1

    restart: on-failure

    ports:
      - "5000:5000"

    environment:
      DB_HOST: ${DB_HOST}
      DB_NAME: ${DB_NAME}
      DB_USER: ${DB_USER}
      DB_PASS: ${DB_PASS}

    depends_on:
      db:
        condition: service_healthy

    networks:
      - backend
      - frontend

    labels:
      app: flask-project
      tier: web

networks:

  backend:

  frontend:

volumes:

  pg_data:
```

---

# Architecture Diagram

```text
                     Host
                       |
                       |
                Frontend Network
                       |
                       |
                +-------------+
                | Flask App   |
                | Gunicorn    |
                +------+------+
                       |
                Backend Network
                       |
                       |
                +------+------+
                | PostgreSQL  |
                +-------------+

Named Volume:
pg_data
```

---

# Why Use Separate Networks?

## Backend Network

```text
Flask ↔ PostgreSQL
```

Internal communication only.

---

## Frontend Network

```text
Host ↔ Flask
```

Public access.

---

## Security Benefit

```text
Host
  ↓
Flask
  ↓
Database
```

Database is not exposed directly.

---

# Task 8 – Run the Project

## Build + Start

```bash
docker compose up -d --build
```

---

## Watch Startup

```bash
docker compose logs -f
```

Expected sequence:

```text
db starting
     ↓
db healthy
     ↓
web starting
```

---

# Task 9 – Test All Endpoints

## Home Endpoint

```bash
curl http://localhost:5000/
```

Response:

```json
{
  "message": "App is running!",
  "status": "ok"
}
```

---

## Health Endpoint

```bash
curl http://localhost:5000/health
```

Response:

```json
{
  "db": "connected"
}
```

---

## Users Endpoint

```bash
curl http://localhost:5000/users
```

Response:

```json
[
  {
    "id": 1,
    "name": "Alice"
  },
  {
    "id": 2,
    "name": "Bob"
  },
  {
    "id": 3,
    "name": "Charlie"
  }
]
```

---

# Task 10 – Test Data Persistence

Stop containers:

```bash
docker compose down
```

Start again:

```bash
docker compose up -d
```

Verify:

```bash
curl http://localhost:5000/users
```

Result:

```text
✓ Data still exists
```

Why?

```yaml
volumes:
  pg_data:
```

Named volume preserved database files.

---

# Task 11 – Push to Docker Hub

## Login

```bash
docker login
```

---

## Tag Image

```bash
docker tag flask-app:v1 \
yourusername/flask-app:v1

docker tag flask-app:v1 \
yourusername/flask-app:latest
```

---

## Push Image

```bash
docker push yourusername/flask-app:v1

docker push yourusername/flask-app:latest
```

---

# Task 12 – Fresh Pull Test (Most Important)

This proves your image works on any machine.

---

## Remove Everything

```bash
docker compose down -v
```

Remove images:

```bash
docker rmi \
flask-app:v1 \
yourusername/flask-app:v1
```

---

## Replace Build Section

Before:

```yaml
web:
  build:
    context: ./app
```

After:

```yaml
web:
  image: yourusername/flask-app:v1
```

---

## Start Again

```bash
docker compose up -d
```

Docker automatically pulls from Docker Hub.

---

## Verify

```bash
curl http://localhost:5000/health
```

Expected:

```json
{
  "db": "connected"
}
```

Success means:

```text
✓ Image is portable
✓ Image is reproducible
✓ Works on any machine
```

---

# What You Combined in Day 36

| Day | Concept | Used Here |
|------|----------|----------|
| Day 33 | Docker Compose Basics | Services, Volumes, Depends On |
| Day 34 | Healthchecks & Networks | service_healthy, backend/frontend |
| Day 35 | Multi-Stage Builds & Docker Hub | Optimized Dockerfile, Image Registry |
| Day 36 | Full Production Project | End-to-End Deployment |

---

# Best Practices Used

✅ Multi-stage Docker build

✅ Gunicorn production server

✅ Non-root user

✅ Healthchecks

✅ Named networks

✅ Named volumes

✅ Environment variables

✅ .dockerignore

✅ Docker Hub publishing

✅ Data persistence testing

✅ Production-ready Compose setup

---

# Final Takeaway

Day 36 combines everything learned across Docker fundamentals into a complete production-style deployment.

You built:

```text
Flask API
     +
PostgreSQL Database
     +
Docker Compose
     +
Multi-Stage Dockerfile
     +
Healthchecks
     +
Volumes
     +
Networks
     +
Docker Hub
```

This is the first fully containerized application that follows real-world DevOps and containerization best practices and serves as a strong foundation before moving into Kubernetes, CI/CD pipelines, and cloud deployments.
