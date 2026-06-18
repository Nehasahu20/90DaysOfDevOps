# Day 35 – Multi-Stage Builds & Docker Hub

## Why Image Size Matters

Large Docker images create several problems:

- Slow CI/CD pipelines (longer push/pull times)
- Higher storage costs (Docker Hub, ECR, GCR)
- Larger attack surface (more packages = more vulnerabilities)
- Slower Kubernetes deployments
- Increased network bandwidth usage

### Example

```text
1 GB Image  → Slow deployment
10 MB Image → Fast deployment
```

---

# Task 1 – Single-Stage Build (The Problem)

## Simple Go Application

### main.go

```go
package main

import "fmt"

func main() {
    fmt.Println("Hello, DevOps!")
}
```

---

## Single-Stage Dockerfile

```dockerfile
FROM golang:1.21

WORKDIR /app

COPY main.go .

RUN go build -o app main.go

CMD ["./app"]
```

---

## Build Image

```bash
docker build -t go-single -f Dockerfile.single .
```

Check image size:

```bash
docker images go-single
```

Example:

```text
REPOSITORY    TAG       SIZE
go-single     latest    ~850MB
```

---

## Why Is It So Large?

The final image contains:

```text
✓ Go compiler
✓ Go SDK
✓ Source code
✓ Build cache
✓ Application binary
```

But at runtime you only need:

```text
✓ Application binary
```

Everything else is wasted space.

---

# Task 2 – Multi-Stage Build (The Solution)

## How Multi-Stage Builds Work

### Stage 1

Build the application.

```text
Install tools
Compile code
Generate binary
```

### Stage 2

Create a clean runtime image.

```text
Copy binary only
Discard compiler
Discard SDK
Discard source code
```

---

## Multi-Stage Dockerfile

```dockerfile
# ─────────────────────────────────────
# Stage 1 - Build
# ─────────────────────────────────────

FROM golang:1.21 AS builder

WORKDIR /app

COPY main.go .

RUN CGO_ENABLED=0 GOOS=linux go build -o app main.go

# ─────────────────────────────────────
# Stage 2 - Run
# ─────────────────────────────────────

FROM alpine:3.19

WORKDIR /app

COPY --from=builder /app/app .

CMD ["./app"]
```

---

## Build Image

```bash
docker build -t go-multi -f Dockerfile.multi .
```

Check size:

```bash
docker images | grep go
```

Example:

```text
go-single   latest   ~850MB
go-multi    latest   ~10MB
```

---

## Why Is It Smaller?

Discarded after Stage 1:

```text
❌ Go compiler
❌ Go SDK
❌ Source code
❌ Build cache
❌ Temporary files
```

Final image contains only:

```text
✓ Alpine Linux (~5 MB)
✓ Compiled binary (~5 MB)
```

Result:

```text
98% smaller image
```

---

## Important Build Flags

### CGO_ENABLED=0

```bash
CGO_ENABLED=0
```

Creates a static binary.

Benefits:

- No external C libraries required
- Easier deployment
- Smaller image

---

### GOOS=linux

```bash
GOOS=linux
```

Compiles for Linux even if building on:

- macOS
- Windows

Useful for cross-platform development.

---

# Node.js Multi-Stage Example

## Stage 1 – Build

```dockerfile
FROM node:20 AS builder

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

RUN npm run build
```

---

## Stage 2 – Production

```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules

CMD ["node", "dist/index.js"]
```

---

## Benefits

Not copied into final image:

```text
❌ TypeScript
❌ Webpack
❌ ESLint
❌ Testing frameworks
❌ Build tools
```

Final image contains:

```text
✓ Compiled application
✓ Runtime dependencies
```

Result:

```text
Smaller and faster production image
```

---

# Task 3 – Push Images to Docker Hub

## What Is Docker Hub?

Docker Hub is a container image registry.

Think of it as:

```text
GitHub → Source Code
Docker Hub → Docker Images
```

---

## Step 1 – Login

```bash
docker login
```

Enter:

- Docker Hub username
- Password or Access Token

---

## Step 2 – Tag Image

Format:

```text
username/image-name:tag
```

Example:

```bash
docker tag go-multi yourusername/go-hello:v1.0

docker tag go-multi yourusername/go-hello:latest
```

---

## Step 3 – Push Image

```bash
docker push yourusername/go-hello:v1.0

docker push yourusername/go-hello:latest
```

---

## Step 4 – Verify

Remove local image:

```bash
docker rmi yourusername/go-hello:v1.0
```

Pull from Docker Hub:

```bash
docker pull yourusername/go-hello:v1.0
```

Run:

```bash
docker run yourusername/go-hello:v1.0
```

Output:

```text
Hello, DevOps!
```

---

# Task 4 – Versioning on Docker Hub

## Create New Version

```bash
docker tag go-multi yourusername/go-hello:v2.0

docker push yourusername/go-hello:v2.0
```

---

## Pull Specific Versions

### Exact Version

```bash
docker pull yourusername/go-hello:v1.0
```

### Latest Version

```bash
docker pull yourusername/go-hello:latest
```

---

## Important Note About `latest`

Many beginners think:

```text
latest = newest image automatically
```

Wrong.

`latest` is simply another tag.

You must manually update it:

```bash
docker tag go-multi yourusername/go-hello:latest

docker push yourusername/go-hello:latest
```

---

# Task 5 – Docker Image Best Practices

## Production-Ready Dockerfile

```dockerfile
# ─────────────────────────────────────
# Stage 1 - Build
# ─────────────────────────────────────

FROM golang:1.21-alpine3.19 AS builder

WORKDIR /app

COPY main.go .

RUN CGO_ENABLED=0 GOOS=linux go build -o app main.go

# ─────────────────────────────────────
# Stage 2 - Runtime
# ─────────────────────────────────────

FROM alpine:3.19

RUN apk --no-cache add ca-certificates && \
    addgroup -S appgroup && \
    adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder /app/app .

RUN chown appuser:appgroup app

USER appuser

CMD ["./app"]
```

---

## Why Use Specific Tags?

Avoid:

```dockerfile
FROM golang:latest
```

Use:

```dockerfile
FROM golang:1.21-alpine3.19
```

Benefits:

- Predictable builds
- Reproducible deployments
- No unexpected upgrades

---

## Why Combine RUN Commands?

Bad:

```dockerfile
RUN apk add ca-certificates

RUN addgroup -S appgroup

RUN adduser -S appuser -G appgroup
```

Good:

```dockerfile
RUN apk --no-cache add ca-certificates && \
    addgroup -S appgroup && \
    adduser -S appuser -G appgroup
```

Benefits:

- Fewer image layers
- Smaller image size
- Faster builds

---

## Why Use Non-Root Users?

Create user:

```dockerfile
adduser -S appuser
```

Switch user:

```dockerfile
USER appuser
```

---

### Verify

```bash
docker build -t go-best -f Dockerfile.best .
```

Run:

```bash
docker run --rm go-best whoami
```

Output:

```text
appuser
```

Not:

```text
root
```

---

## Security Benefit

If container is compromised:

### Running as Root

```text
Container compromise
        ↓
Root access
        ↓
Potential host damage
```

### Running as Non-Root

```text
Container compromise
        ↓
Limited permissions
        ↓
Damage contained
```

---

# Inspect Image Layers

## View Layers

```bash
docker history go-best
```

Compare:

```bash
docker history go-single
```

---

## Why Fewer Layers Matter

Benefits:

- Smaller image
- Faster downloads
- Better caching
- Lower storage cost

---

# Size Comparison Summary

| Image | Base Image | Approx Size | Security |
|---------|------------|------------|------------|
| go-single | golang:1.21 | ~850MB | Root user, full SDK |
| go-multi | alpine:3.19 | ~10MB | Root user, binary only |
| go-best | alpine:3.19 | ~8MB | Non-root, binary only |
| node-single | node:20 | ~1GB | Full Node + npm |
| node-multi | node:20-alpine | ~150MB | Production deps only |

---

# Architecture of a Multi-Stage Build

```text
┌──────────────────────────────┐
│ Stage 1: Builder             │
│ ---------------------------- │
│ Go SDK                       │
│ Source Code                  │
│ Compiler                     │
│ Build Dependencies           │
└──────────────┬───────────────┘
               │
               │ COPY BINARY
               ▼
┌──────────────────────────────┐
│ Stage 2: Runtime             │
│ ---------------------------- │
│ Alpine Linux                 │
│ Application Binary           │
└──────────────────────────────┘
```

---

# Quick Reference

```bash
# Build single-stage image
docker build -t go-single -f Dockerfile.single .

# Build multi-stage image
docker build -t go-multi -f Dockerfile.multi .

# View image size
docker images

# Login to Docker Hub
docker login

# Tag image
docker tag go-multi yourusername/go-hello:v1.0

# Push image
docker push yourusername/go-hello:v1.0

# Pull image
docker pull yourusername/go-hello:v1.0

# Run image
docker run yourusername/go-hello:v1.0

# Build without cache
docker build --no-cache -t go-best -f Dockerfile.best .

# View layers
docker history go-best
```

---

## Final Takeaway

Day 35 introduces one of the most important Docker optimization techniques:

### Multi-Stage Builds

They allow you to:

- Remove build tools from production images
- Reduce image size by 90–99%
- Improve security
- Speed up CI/CD pipelines
- Reduce storage costs

Combined with Docker Hub versioning, tagging, and non-root containers, these practices form the foundation of production-grade container image management.
