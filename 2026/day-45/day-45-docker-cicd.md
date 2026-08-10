# 🚀 Day 45 — Docker CI/CD: Build & Push with GitHub Actions

## 📌 Why Docker in CI/CD?

Docker packages your application into a container image that:

- Runs identically everywhere — development, staging, and production
- Includes all application dependencies
- Can be deployed to Kubernetes, ECS, Cloud Run, etc.

### 🔄 Typical Docker CI/CD Pipeline

    Code Push
        ↓
    Build Docker Image
        ↓
    Run Tests
        ↓
    Push to Registry
        ↓
    Deploy

---

## 🐳 Docker Registry Options

| Registry | URL | Notes |
|---|---|---|
| Docker Hub | `docker.io` | Most popular, free for public images |
| GitHub Container Registry | `ghcr.io` | Built into GitHub |
| AWS ECR | `*.amazonaws.com` | Best for AWS deployments |
| Google GCR | `gcr.io` | Used for GCP deployments |

---

# 🔐 Docker Hub Setup

## 1. Create Docker Hub Account

Go to:

https://hub.docker.com

Click **Sign Up** and create your account.

---

## 2. Create Docker Hub Access Token

> ⚠️ Do NOT use your Docker Hub password in GitHub Actions.

Go to:

    Docker Hub
    → Account Settings
    → Security
    → New Access Token

Example:

    Name: github-actions
    Permissions: Read, Write, Delete

Copy the generated token and keep it secure.

---

## 3. Add Docker Credentials to GitHub

Go to:

    GitHub Repository
    → Settings
    → Secrets and variables
    → Actions
    → New repository secret

Add the following secrets:

    DOCKERHUB_USERNAME = your_dockerhub_username
    DOCKERHUB_TOKEN    = your_dockerhub_access_token

These secrets can then be used inside GitHub Actions:

    ${{ secrets.DOCKERHUB_USERNAME }}
    ${{ secrets.DOCKERHUB_TOKEN }}

---

# ⚙️ Docker Build & Push Workflow

Create the workflow file:

    .github/workflows/docker-publish.yml

Basic workflow:

    name: Docker Build and Push

    on:
      push:
        branches: [ main ]

    jobs:
      docker:
        runs-on: ubuntu-latest

        steps:
          - name: Checkout code
            uses: actions/checkout@v4

          - name: Log in to Docker Hub
            uses: docker/login-action@v3
            with:
              username: ${{ secrets.DOCKERHUB_USERNAME }}
              password: ${{ secrets.DOCKERHUB_TOKEN }}

          - name: Build and push
            uses: docker/build-push-action@v5
            with:
              context: .
              push: true
              tags: ${{ secrets.DOCKERHUB_USERNAME }}/my-app:latest

### 🔄 What Happens?

    GitHub Push
        ↓
    GitHub Actions Starts
        ↓
    Checkout Repository
        ↓
    Login to Docker Hub
        ↓
    Build Docker Image
        ↓
    Push Image to Docker Hub

---

# 🏷️ Advanced Docker Build Options

## Multiple Image Tags

Instead of using only `latest`, we can create multiple tags:

    - name: Build and push
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: |
          myuser/my-app:latest
          myuser/my-app:${{ github.sha }}
          myuser/my-app:v1.0.0

### Why Multiple Tags?

| Tag | Purpose |
|---|---|
| `latest` | Points to the latest build |
| `${{ github.sha }}` | Unique identifier for the exact commit |
| `v1.0.0` | Human-readable application version |

Using `${{ github.sha }}` is especially useful for traceability and rollback.

---

# 🔍 Build Only on Pull Request

For Pull Requests, we usually want to build and test the image but **NOT push it**.

    - name: Build and push
      uses: docker/build-push-action@v5
      with:
        context: .
        push: ${{ github.event_name != 'pull_request' }}
        tags: myuser/my-app:latest

### Pull Request Flow

    Pull Request
        ↓
    Build Image
        ↓
    push: false
        ↓
    Image NOT pushed

After merging to `main`:

    Push to main
        ↓
    Build Image
        ↓
    push: true
        ↓
    Image pushed to Docker Hub

---

# 🏗️ Build for Multiple Architectures

Docker images can be built for different CPU architectures:

    AMD64
    ARM64

## Setup QEMU

    - name: Set up QEMU
      uses: docker/setup-qemu-action@v3

## Setup Docker Buildx

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3

## Build for AMD64 + ARM64

    - name: Build and push multi-arch
      uses: docker/build-push-action@v5
      with:
        platforms: linux/amd64,linux/arm64
        push: true
        tags: myuser/my-app:latest

### Why Multi-Architecture Images?

    Intel / AMD Servers
            +
    ARM Servers
            +
    ARM-based Cloud / Devices

The same image can be used across different CPU architectures.

---

# ⚡ Docker Layer Caching in CI

Building Docker images can be slow because Docker layers may need to be downloaded and rebuilt on every GitHub Actions run.

Docker layer caching can significantly speed up repeated builds.

## Setup Buildx

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3

## Build with GitHub Actions Cache

    - name: Build and push with cache
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: myuser/my-app:latest
        cache-from: type=gha
        cache-to: type=gha,mode=max

### 🔄 Cache Flow

    First Build
        ↓
    Build Docker Layers
        ↓
    Save Layers to GitHub Actions Cache

    Next Build
        ↓
    Restore Cached Layers
        ↓
    Reuse Existing Layers
        ↓
    Build Only Changed Layers
        ↓
    Faster Build

---

# 🔥 Full Pipeline: Build → Test → Push

A better CI/CD pipeline should run tests before pushing the Docker image.

    name: Full Docker Pipeline

    on:
      push:
        branches: [ main ]

      pull_request:
        branches: [ main ]

    jobs:

      test:
        runs-on: ubuntu-latest

        steps:
          - uses: actions/checkout@v4

          - name: Run tests
            run: bash scripts/test.sh

      docker:
        needs: test
        runs-on: ubuntu-latest

        steps:
          - uses: actions/checkout@v4

          - name: Login to Docker Hub
            if: github.event_name != 'pull_request'
            uses: docker/login-action@v3
            with:
              username: ${{ secrets.DOCKERHUB_USERNAME }}
              password: ${{ secrets.DOCKERHUB_TOKEN }}

          - name: Build and push
            uses: docker/build-push-action@v5
            with:
              context: .
              push: ${{ github.event_name != 'pull_request' }}
              tags: ${{ secrets.DOCKERHUB_USERNAME }}/my-app:${{ github.sha }}

## 🔑 Important: `needs: test`

    needs: test

means the Docker job will run **only after the test job succeeds**.

### Successful Tests

    Test Job
        ↓
    Tests Pass ✅
        ↓
    Docker Job Starts
        ↓
    Build Image
        ↓
    Push Image

### Failed Tests

    Test Job
        ↓
    Tests Fail ❌
        ↓
    Docker Job Does NOT Run
        ↓
    No Image Push

---

# 🧪 Practice Project

## 📁 Project Structure

    github-actions-practice/
    │
    ├── app.py
    ├── Dockerfile
    ├── requirements.txt
    │
    └── .github/
        └── workflows/
            └── docker-publish.yml

---

# 🐍 app.py — Simple Python Web Server

    #!/usr/bin/env python3

    from http.server import HTTPServer, BaseHTTPRequestHandler
    import json


    class Handler(BaseHTTPRequestHandler):

        def do_GET(self):

            if self.path == '/health':
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.end_headers()

                self.wfile.write(
                    json.dumps({"status": "healthy"}).encode()
                )

            else:
                self.send_response(200)
                self.send_header('Content-type', 'text/plain')
                self.end_headers()

                self.wfile.write(b"Hello from CI/CD!")

        def log_message(self, *args):
            pass


    if __name__ == '__main__':
        server = HTTPServer(('0.0.0.0', 8080), Handler)

        print("Server running on port 8080")

        server.serve_forever()

> **Important:** The correct Python entry-point condition is:
>
> `if __name__ == '__main__':`
>
> Not:
>
> `if name == 'main':`

---

# 🐳 Dockerfile

    FROM python:3.11-slim

    WORKDIR /app

    COPY requirements.txt .

    RUN pip install --no-cache-dir -r requirements.txt

    COPY . .

    EXPOSE 8080

    CMD ["python3", "app.py"]

---

# 📦 requirements.txt

    requests==2.33.0
    pytest==9.0.3

---

# 💻 Practice Commands

## 1. Go to Project Directory

    cd ~/github-actions-practice

---

## 2. Create `app.py`

    cat > app.py << 'EOF'
    #!/usr/bin/env python3

    from http.server import HTTPServer, BaseHTTPRequestHandler
    import json


    class Handler(BaseHTTPRequestHandler):

        def do_GET(self):

            if self.path == '/health':
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.end_headers()

                self.wfile.write(
                    json.dumps({"status": "healthy"}).encode()
                )

            else:
                self.send_response(200)
                self.send_header('Content-type', 'text/plain')
                self.end_headers()

                self.wfile.write(b"Hello from CI/CD!")

        def log_message(self, *args):
            pass


    if __name__ == '__main__':
        server = HTTPServer(('0.0.0.0', 8080), Handler)

        print("Server running on port 8080")

        server.serve_forever()
    EOF

---

# 3. Create Dockerfile

    cat > Dockerfile << 'EOF'
    FROM python:3.11-slim

    WORKDIR /app

    COPY requirements.txt .

    RUN pip install --no-cache-dir -r requirements.txt

    COPY . .

    EXPOSE 8080

    CMD ["python3", "app.py"]
    EOF

---

# 4. Test Docker Build Locally

If Docker is installed:

    docker build -t my-app:test .

Run the container:

    docker run -d \
      -p 8080:8080 \
      --name test-app \
      my-app:test

Test the health endpoint:

    curl http://localhost:8080/health

Expected output:

    {"status": "healthy"}

Stop and remove the test container:

    docker stop test-app
    docker rm test-app

---

# 5. Commit and Push

    git add app.py Dockerfile requirements.txt .github/workflows/docker-publish.yml

Commit:

    git commit -m "Day 45: Docker CI/CD pipeline"

Push:

    git push

---

# 📝 Day 45 Quick Revision

## Docker CI/CD Flow

    Code Push
        ↓
    GitHub Actions
        ↓
    Run Tests
        ↓
    Build Docker Image
        ↓
    Push to Registry
        ↓
    Deploy

---

# 🔑 Important GitHub Actions

## Checkout

    uses: actions/checkout@v4

## Docker Login

    uses: docker/login-action@v3

## Docker Build & Push

    uses: docker/build-push-action@v5

## QEMU

    uses: docker/setup-qemu-action@v3

## Docker Buildx

    uses: docker/setup-buildx-action@v3

---

# ⭐ Important Concepts

## 1. Never Store Docker Password Directly

Use GitHub Secrets:

    DOCKERHUB_USERNAME
    DOCKERHUB_TOKEN

---

## 2. Don't Push Images from Pull Requests

    push: ${{ github.event_name != 'pull_request' }}

---

## 3. Tag Images with Commit SHA

    tags: myuser/my-app:${{ github.sha }}

This gives every build a unique identifier and makes rollback easier.

---

## 4. Use Layer Caching

    cache-from: type=gha
    cache-to: type=gha,mode=max

This can make repeated Docker builds much faster.

---

## 5. Test Before Push

    docker:
      needs: test

Only successful tests should allow the Docker image to be pushed.

---

# 📚 Day 45 Summary

Docker images can be automatically built and pushed using GitHub Actions.

### Complete CI/CD Flow

    Developer
        ↓
    git push
        ↓
    GitHub Actions
        ↓
    Checkout Code
        ↓
    Run Tests
        ↓
    Docker Build
        ↓
    Docker Login
        ↓
    Push Image
        ↓
    Docker Registry

### Key Takeaways

- Docker images can be built automatically in CI.
- Use `docker/login-action` for registry authentication.
- Use `docker/build-push-action` to build and push images.
- Store Docker credentials in GitHub Secrets.
- Use `push: false` for Pull Requests.
- Push images only after tests pass.
- Use `${{ github.sha }}` for image traceability.
- Use Docker layer caching to speed up CI builds.
- Use QEMU + Buildx for multi-architecture images.
- Docker Hub, GHCR, AWS ECR, and Google GCR are common container registries.

---

# 🎯 Day 45 Complete

> **Docker + GitHub Actions = Automated Container CI/CD**
