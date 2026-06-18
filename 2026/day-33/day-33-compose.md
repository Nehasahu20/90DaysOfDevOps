# Day 33 – Docker Compose: Multi-Container Applications

## Basics

### What is Docker Compose?

Docker Compose lets you define and run multi-container Docker applications using a single YAML file called:

```yaml
docker-compose.yml
```

### Problem Without Compose

```bash
docker network create mynet

docker run -d --network mynet --name db \
  -e MYSQL_ROOT_PASSWORD=pass mysql

docker run -d --network mynet --name wp \
  -p 8080:80 wordpress

docker run -d --network mynet --name redis redis
```

❌ Requires multiple commands every time.

❌ Easy to forget flags and network settings.

### With Compose

```bash
docker compose up
```

✅ Networks, volumes, and containers are created automatically from one file.

---

# Task 1 – Install & Verify Docker Compose

Docker Compose v2 comes bundled with Docker Engine.

### Check Version

```bash
docker compose version
```

### If Docker Is Not Installed (Amazon Linux 2023)

```bash
sudo dnf install -y docker

sudo systemctl start docker
sudo systemctl enable docker

sudo usermod -aG docker ec2-user
```

Logout and login again for group changes to take effect.

Verify:

```bash
docker compose version
```

---

# Task 2 – Your First Compose File (Single Nginx)

## Create Project

```bash
mkdir compose-basics
cd compose-basics
```

## Create `docker-compose.yml`

```yaml
services:
  web:
    image: nginx
    ports:
      - "8080:80"
```

### Explanation

| Line | Purpose |
|--------|---------|
| services | Defines all containers in the application |
| web | Service/container name |
| image: nginx | Pulls official Nginx image |
| ports | Maps host port to container port |

```yaml
ports:
  - "8080:80"
```

Host Port → Container Port

```
8080 → 80
```

### Start Container

Foreground mode:

```bash
docker compose up
```

Detached mode:

```bash
docker compose up -d
```

### Test

```bash
curl http://localhost:8080
```

### Stop & Remove

```bash
docker compose down
```

---

# Task 3 – Two-Container Setup (WordPress + MySQL)

## Why Two Containers?

- WordPress = Web application
- MySQL = Database
- Both need to communicate

Docker Compose automatically creates a network.

### Service Name = DNS Hostname

WordPress connects to MySQL using:

```text
db
```

instead of an IP address.

---

## Create Project

```bash
mkdir wordpress-app
cd wordpress-app
```

## Create `docker-compose.yml`

```yaml
services:

  db:
    image: mysql:8.0
    restart: always

    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: wppass

    volumes:
      - db_data:/var/lib/mysql

  wordpress:
    image: wordpress:latest
    restart: always

    ports:
      - "8080:80"

    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: wppass

    depends_on:
      - db

volumes:
  db_data:
```

---

## Why `depends_on`?

```yaml
depends_on:
  - db
```

Ensures:

1. Database container starts first.
2. WordPress starts after database.

Without it:

- WordPress may attempt connection before MySQL is ready.
- Application startup can fail.

---

## Start Application

```bash
docker compose up -d
```

Open:

```text
http://localhost:8080
```

---

## Test Data Persistence

Stop everything:

```bash
docker compose down
```

Start again:

```bash
docker compose up -d
```

WordPress data remains because it is stored inside the named volume:

```yaml
db_data
```

---

# Task 4 – The 7 Most Important Compose Commands

## 1. Start Containers

```bash
docker compose up -d
```

Use on servers because it runs in the background.

---

## 2. View Running Services

```bash
docker compose ps
```

Shows:

- Container Name
- Command
- Status
- Ports

---

## 3. View Logs (All Services)

```bash
docker compose logs -f
```

`-f` = Follow logs continuously.

Stop viewing:

```text
Ctrl + C
```

---

## 4. View Logs (Specific Service)

WordPress:

```bash
docker compose logs -f wordpress
```

MySQL:

```bash
docker compose logs -f db
```

Useful for debugging individual containers.

---

## 5. Stop Services Only

```bash
docker compose stop
```

Effects:

- Containers stopped
- Containers preserved
- Networks preserved
- Volumes preserved

Restart later:

```bash
docker compose start
```

---

## 6. Remove Containers & Networks

```bash
docker compose down
```

Removes:

- Containers
- Networks

Does NOT remove named volumes.

---

## 7. Rebuild Images

```bash
docker compose up -d --build
```

Use when:

- Dockerfile changed
- Application code changed
- New dependencies added

---

# Task 5 – Environment Variables with `.env`

## Why Use `.env`?

Benefits:

- Avoid hardcoding passwords
- Different configs for dev/staging/prod
- Easier maintenance

⚠️ Never commit `.env` to Git.

Add to:

```gitignore
.env
```

---

## Create `.env`

```env
MYSQL_ROOT_PASSWORD=rootpass
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=wppass

WP_PORT=8080
```

---

## Update `docker-compose.yml`

```yaml
services:

  db:
    image: mysql:8.0

    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}

  wordpress:
    image: wordpress:latest

    ports:
      - "${WP_PORT}:80"

    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_NAME: ${MYSQL_DATABASE}
      WORDPRESS_DB_USER: ${MYSQL_USER}
      WORDPRESS_DB_PASSWORD: ${MYSQL_PASSWORD}

    depends_on:
      - db
```

---

# Key Concepts Summary

| Concept | Purpose |
|----------|----------|
| services | Defines containers in the application |
| image | Docker image to run |
| ports | Maps host port to container port |
| volumes | Persistent storage |
| depends_on | Controls startup order |
| environment | Sets environment variables |
| restart | Defines restart policy |
| Service Name | Acts as DNS hostname |
| Default Network | Auto-created by Compose |

---

# Quick Reference

```bash
docker compose version

docker compose up
docker compose up -d

docker compose ps

docker compose logs -f
docker compose logs -f wordpress
docker compose logs -f db

docker compose stop
docker compose start

docker compose down

docker compose up -d --build
```

---

## Architecture Diagram

```text
+--------------------+
|     WordPress      |
|  Port 8080 -> 80   |
+---------+----------+
          |
          |
          v
+--------------------+
|      MySQL DB      |
|   db (hostname)    |
+--------------------+

Named Volume:
db_data
```

**Key Takeaway:** Docker Compose allows you to manage an entire multi-container application using a single `docker-compose.yml` file and a few simple commands.
