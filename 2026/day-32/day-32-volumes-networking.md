
## Day 32 — Docker Volumes & Networking

### Named Volumes

```bash
# Create volume
docker volume create mysql-data
docker volume ls
docker volume inspect mysql-data

# Run MySQL with volume
docker run -d --name mysql-vol -e MYSQL_ROOT_PASSWORD=root123 -e MYSQL_DATABASE=testdb -v mysql-data:/var/lib/mysql mysql:8
sleep 15

# Add data
docker exec -it mysql-vol mysql -uroot -proot123 -e "USE testdb; CREATE TABLE users (id INT, name VARCHAR(50)); INSERT INTO users VALUES (1,'Neha');"

# Remove container
docker stop mysql-vol && docker rm mysql-vol

# New container — data still there!
docker run -d --name mysql-vol2 -e MYSQL_ROOT_PASSWORD=root123 -e MYSQL_DATABASE=testdb -v mysql-data:/var/lib/mysql mysql:8
sleep 15
docker exec -it mysql-vol2 mysql -uroot -proot123 -e "USE testdb; SELECT * FROM users;"
# +----+------+
# | 1  | Neha |  ← persisted!
```

### Bind Mounts

```bash
mkdir -p ~/mysite
echo "<h1>Hello from Bind Mount!</h1>" > ~/mysite/index.html

docker run -d --name bind-nginx -p 8080:80 -v ~/mysite:/usr/share/nginx/html nginx
# Edit on host — browser updates instantly!
echo "<h1>Updated Live!</h1>" > ~/mysite/index.html
```

| | Named Volume | Bind Mount |
|--|---|---|
| Location | Docker managed | Your host path |
| Best for | Databases | Live dev |

### Networking

```bash
# List networks
docker network ls

# Default bridge — IP only, no DNS
docker run -d --name c1 nginx
docker run -d --name c2 nginx
docker inspect c1 | grep IPAddress
docker exec c2 ping -c3 172.17.0.2   # works by IP
docker exec c2 ping -c3 c1           # FAILS — no DNS!

# Custom network — DNS enabled
docker network create my-app-net
docker run -d --name app1 --network my-app-net nginx
docker run -d --name app2 --network my-app-net nginx
docker exec app2 ping -c3 app1       # works by NAME!
```

| Network | Ping by IP | Ping by Name |
|---|---|---|
| Default bridge | Yes | No |
| Custom bridge | Yes | Yes |

### Full Stack Example

```bash
docker network create prod-net
docker volume create prod-db

docker run -d --name prod-mysql --network prod-net -e MYSQL_ROOT_PASSWORD=root123 -e MYSQL_DATABASE=appdb -v prod-db:/var/lib/mysql mysql:8

docker run -it --name prod-app --network prod-net ubuntu bash
# Inside:
apt-get update && apt-get install -y iputils-ping
ping -c3 prod-mysql   # works by name!
```

---

## Master Flag Reference

| Flag | Purpose | Example |
|---|---|---|
| `-d` | Background | `docker run -d nginx` |
| `-it` | Interactive terminal | `docker run -it ubuntu bash` |
| `-p` | Port mapping | `-p 8080:80` |
| `-v` | Volume/bind mount | `-v mydata:/var/lib/mysql` |
| `--name` | Custom name | `--name my-container` |
| `--network` | Attach to network | `--network my-net` |
| `-e` | Environment variable | `-e MYSQL_ROOT_PASSWORD=root` |

---

## Debugging Guide

| Problem | Solution |
|---|---|
| Container exits immediately | Add `-it` flag for shell containers |
| Exit code 0 | Normal — no error |
| Exit code 127 | Command not found inside container |
| Exit code 137 | Force killed |
| Logs empty | Container started and exited too fast |
| Can't ping by name | Use custom network, not default bridge |
| Data lost after rm | Use named volumes |
