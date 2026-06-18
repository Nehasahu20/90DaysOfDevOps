
## Day 31 — Dockerfile: Build Custom Images

### Dockerfile Instructions

| Instruction | Purpose |
|---|---|
| FROM | Base image |
| RUN | Run command during build |
| COPY | Copy files from host |
| WORKDIR | Set working directory |
| EXPOSE | Document port |
| CMD | Default command (replaceable) |
| ENTRYPOINT | Fixed executable (not replaceable) |

### First Dockerfile

```bash
mkdir ~/my-first-image && cd ~/my-first-image

cat > Dockerfile << 'EOF'
FROM ubuntu
RUN apt-get update && apt-get install -y curl
CMD ["echo", "Hello from my custom image!"]
EOF

docker build -t my-ubuntu:v1 .
docker run my-ubuntu:v1
# Output: Hello from my custom image!
```

### Nginx Website Image

```bash
mkdir ~/my-website && cd ~/my-website

cat > index.html << 'EOF'
<h1>Day 31 - My Custom Docker Image!</h1>
EOF

cat > Dockerfile << 'EOF'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EOF

docker build -t my-website:v1 .
docker run -d --name mysite -p 8080:80 my-website:v1
# Access: http://YOUR_IP:8080
```

### CMD vs ENTRYPOINT

```bash
# CMD — fully replaced at runtime
docker run cmd-test              # prints: hello
docker run cmd-test echo world   # prints: world (CMD replaced!)

# ENTRYPOINT — args appended
docker run entry-test hello      # prints: hello
docker run entry-test DevOps     # prints: DevOps
```

### Layer Optimization

```bash
# GOOD order — stable layers first
FROM ubuntu
RUN apt-get install -y curl    # rarely changes → cached
COPY . .                       # changes often → only this re-runs
```

### .dockerignore

```
node_modules
.git
*.md
.env
```

---
