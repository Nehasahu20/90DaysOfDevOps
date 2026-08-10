# 🚀 Day 48 — CI/CD Capstone Project

## 🎯 The Goal

Build a complete, production-quality CI/CD pipeline that:

1. Validates every Pull Request before merge
2. Builds and tests on every push to `main`
3. Builds and pushes Docker image
4. Runs health checks on schedule
5. Reuses workflows to avoid duplication
6. Performs security scanning
7. Reports pipeline results clearly

---

## 🏗️ Project Architecture

github-actions-practice/
├── app.py
├── Dockerfile
├── requirements.txt
├── scripts/
│   └── test.sh
└── .github/
    ├── workflows/
    │   ├── reusable-build-test.yml
    │   ├── reusable-docker.yml
    │   ├── pr-pipeline.yml
    │   ├── main-pipeline.yml
    │   └── health-check.yml
    └── actions/
        └── setup-and-greet/

### 📁 File Responsibilities

| File | Purpose |
|---|---|
| `app.py` | Python web application |
| `Dockerfile` | Docker image build instructions |
| `requirements.txt` | Python dependencies |
| `scripts/test.sh` | Application test script |
| `reusable-build-test.yml` | Reusable build + test workflow |
| `reusable-docker.yml` | Reusable Docker build + push workflow |
| `pr-pipeline.yml` | Pull Request validation |
| `main-pipeline.yml` | Main CI/CD pipeline |
| `health-check.yml` | Scheduled health check |

---

## 🔄 Pipeline Flow

### Pull Request Pipeline

PR Opened / Updated
        ↓
pr-pipeline.yml
        ↓
Build + Test
        ↓
Lint
        ↓
PR Result
        ↓
Ready to Merge

### Push to Main Pipeline

Push to main
     ↓
main-pipeline.yml
     ↓
Build + Test
     ↓
Docker Build + Push
     ↓
Security Scan
     ↓
Pipeline Summary

### Scheduled Health Check

Daily 2 AM UTC
      ↓
health-check.yml
      ↓
Check Repository
      ↓
Validate app.py
      ↓
Validate Dockerfile
      ↓
Run Tests
      ↓
Health Report

---

## 1️⃣ Reusable Workflow — Build + Test

File:

`.github/workflows/reusable-build-test.yml`

A reusable workflow prevents duplicate build and testing logic across multiple pipelines.

Create the workflow:

    mkdir -p .github/workflows

    cat > .github/workflows/reusable-build-test.yml << 'EOF'
    name: Reusable Build and Test

    on:
      workflow_call:
        inputs:
          python-version:
            required: false
            type: string
            default: '3.11'

          run-lint:
            required: false
            type: boolean
            default: true

        outputs:
          test-result:
            description: "Pass or fail"
            value: ${{ jobs.build-test.outputs.result }}

    jobs:
      build-test:
        runs-on: ubuntu-latest

        outputs:
          result: ${{ steps.test.outputs.status }}

        steps:
          - uses: actions/checkout@v4

          - uses: actions/setup-python@v5
            with:
              python-version: ${{ inputs.python-version }}

          - name: Cache dependencies
            uses: actions/cache@v4
            with:
              path: ~/.cache/pip
              key: ${{ runner.os }}-pip-${{ hashFiles('requirements.txt') }}

          - name: Install dependencies
            run: pip install -r requirements.txt

          - name: Lint
            if: inputs.run-lint == true
            run: |
              python -m py_compile app.py
              echo "Lint passed"

          - name: Run tests
            id: test
            run: |
              bash scripts/test.sh
              echo "status=passed" >> $GITHUB_OUTPUT
    EOF

---

## 🧠 Reusable Build Workflow

The workflow accepts:

- `python-version`
- `run-lint`

Example:

    with:
      python-version: '3.11'
      run-lint: true

It performs:

Checkout
   ↓
Setup Python
   ↓
Cache pip dependencies
   ↓
Install dependencies
   ↓
Lint
   ↓
Run tests

---

## 2️⃣ Reusable Workflow — Docker Build + Push

File:

`.github/workflows/reusable-docker.yml`

This workflow handles:

- Docker image building
- Docker Hub login
- Docker image pushing
- Image tagging

Create the workflow:

    cat > .github/workflows/reusable-docker.yml << 'EOF'
    name: Reusable Docker Build Push

    on:
      workflow_call:
        inputs:
          image-name:
            required: true
            type: string

          push:
            required: false
            type: boolean
            default: true

        secrets:
          DOCKERHUB_USERNAME:
            required: true

          DOCKERHUB_TOKEN:
            required: true

        outputs:
          image-tag:
            description: "Full image tag"
            value: ${{ jobs.docker.outputs.tag }}

    jobs:
      docker:
        runs-on: ubuntu-latest

        outputs:
          tag: ${{ steps.meta.outputs.full-tag }}

        steps:
          - uses: actions/checkout@v4

          - name: Generate tag
            id: meta
            run: |
              TAG="${{ inputs.image-name }}:${{ github.sha }}"
              echo "full-tag=$TAG" >> $GITHUB_OUTPUT

          - name: Login to Docker Hub
            if: inputs.push == true
            uses: docker/login-action@v3
            with:
              username: ${{ secrets.DOCKERHUB_USERNAME }}
              password: ${{ secrets.DOCKERHUB_TOKEN }}

          - name: Build and push
            uses: docker/build-push-action@v5
            with:
              context: .
              push: ${{ inputs.push }}
              tags: ${{ steps.meta.outputs.full-tag }}
    EOF

---

## 🐳 Docker Workflow Flow

Checkout Code
     ↓
Generate Image Tag
     ↓
Login to Docker Hub
     ↓
Docker Build
     ↓
Docker Push

The image is tagged using:

`github.sha`

Example:

`myuser/my-app:a82d91f4...`

This gives every image a unique and traceable tag.

---

## 3️⃣ Pull Request Pipeline

File:

`.github/workflows/pr-pipeline.yml`

The PR pipeline validates every Pull Request targeting `main`.

Create:

    cat > .github/workflows/pr-pipeline.yml << 'EOF'
    name: PR Pipeline

    on:
      pull_request:
        branches: [ main ]
        types: [opened, synchronize, reopened]

    jobs:
      validate:
        uses: ./.github/workflows/reusable-build-test.yml
        with:
          python-version: '3.11'
          run-lint: true

      pr-summary:
        needs: validate
        runs-on: ubuntu-latest
        if: always()

        steps:
          - name: PR check result
            run: |
              if [ "${{ needs.validate.result }}" == "success" ]; then
                echo "All checks passed! PR is ready for review."
              else
                echo "Some checks failed. Please fix before merging."
                exit 1
              fi
    EOF

---

## 🔍 PR Pipeline Flow

Pull Request
      ↓
pr-pipeline.yml
      ↓
Reusable Build + Test
      ↓
   ┌───────┐
   ↓       ↓
  Lint    Test
   └───┬───┘
       ↓
   PR Summary
       ↓
 Ready to Merge

---

## 4️⃣ Main Pipeline — Build + Docker + Security

File:

`.github/workflows/main-pipeline.yml`

This pipeline runs whenever code is pushed to `main`.

It performs:

1. Build
2. Test
3. Docker Build
4. Docker Push
5. Security Scan
6. Final Pipeline Summary

Create:

    cat > .github/workflows/main-pipeline.yml << 'EOF'
    name: Main Pipeline

    on:
      push:
        branches: [ main ]

    jobs:
      build-test:
        uses: ./.github/workflows/reusable-build-test.yml
        with:
          python-version: '3.11'
          run-lint: true

      docker:
        needs: build-test
        uses: ./.github/workflows/reusable-docker.yml
        with:
          image-name: ${{ secrets.DOCKERHUB_USERNAME }}/my-app
          push: true
        secrets:
          DOCKERHUB_USERNAME: ${{ secrets.DOCKERHUB_USERNAME }}
          DOCKERHUB_TOKEN: ${{ secrets.DOCKERHUB_TOKEN }}

      security-scan:
        needs: build-test
        runs-on: ubuntu-latest

        steps:
          - uses: actions/checkout@v4

          - name: Trivy vulnerability scan
            uses: aquasecurity/trivy-action@master
            with:
              scan-type: fs
              scan-ref: .
              severity: HIGH,CRITICAL

      notify:
        needs: [docker, security-scan]
        runs-on: ubuntu-latest
        if: always()

        steps:
          - name: Pipeline complete
            run: |
              echo "Docker: ${{ needs.docker.result }}"
              echo "Security: ${{ needs.security-scan.result }}"
              echo "Image: ${{ needs.docker.outputs.image-tag }}"
    EOF

---

## 🔐 Security Scan

The pipeline uses:

`Trivy`

Trivy scans the repository for vulnerabilities.

Configured severity levels:

- HIGH
- CRITICAL

Flow:

Build + Test
     ↓
     ├───────────────┐
     ↓               ↓
Docker Build      Trivy Scan
     ↓               ↓
Docker Push       Security
     └───────┬───────┘
             ↓
          Notify

---

## 5️⃣ Health Check Workflow

File:

`.github/workflows/health-check.yml`

The health check runs:

`Every day at 2 AM UTC`

It can also be manually triggered using:

`workflow_dispatch`

Create:

    cat > .github/workflows/health-check.yml << 'EOF'
    name: Health Check

    on:
      schedule:
        - cron: '0 2 * * *'

      workflow_dispatch:

    jobs:
      health:
        runs-on: ubuntu-latest

        steps:
          - uses: actions/checkout@v4

          - name: Check app files
            run: |
              echo "Checking repository health..."
              ls -la

          - name: Verify app.py
            run: |
              python3 -c "import ast; ast.parse(open('app.py').read()); print('app.py is valid Python')"

          - name: Verify Dockerfile
            run: |
              if [ -f Dockerfile ]; then
                echo "Dockerfile exists"
                head -5 Dockerfile
              else
                echo "WARN: Dockerfile missing"
              fi

          - name: Run tests
            run: bash scripts/test.sh

          - name: Health report
            run: echo "Health check passed at $(date)"
    EOF

---

## ❤️ Health Check Flow

Scheduled Trigger
       ↓
Repository Check
       ↓
Check app.py
       ↓
Check Dockerfile
       ↓
Run Tests
       ↓
Health Report

---

## 🔐 GitHub Secrets Required

Before running the Docker pipeline, create these GitHub repository secrets:

`DOCKERHUB_USERNAME`

`DOCKERHUB_TOKEN`

Go to:

GitHub
→ Repository
→ Settings
→ Secrets and variables
→ Actions
→ New repository secret

### DOCKERHUB_USERNAME

Your Docker Hub username.

### DOCKERHUB_TOKEN

Your Docker Hub access token.

> ⚠️ Never put your Docker Hub password or token directly inside a workflow file.

---

## 📁 Complete GitHub Actions Structure

github-actions-practice/
├── app.py
├── Dockerfile
├── requirements.txt
├── scripts/
│   └── test.sh
└── .github/
    ├── workflows/
    │   ├── reusable-build-test.yml
    │   ├── reusable-docker.yml
    │   ├── pr-pipeline.yml
    │   ├── main-pipeline.yml
    │   └── health-check.yml
    └── actions/
        └── setup-and-greet/

---

## 🧪 Practice Commands

Go to the project:

    cd ~/github-actions-practice

Add all capstone workflow files:

    git add \
    .github/workflows/reusable-build-test.yml \
    .github/workflows/reusable-docker.yml \
    .github/workflows/pr-pipeline.yml \
    .github/workflows/main-pipeline.yml \
    .github/workflows/health-check.yml

Commit:

    git commit -m "Day 48: complete CI/CD capstone project"

Push:

    git push

---

## 🧪 Test the PR Pipeline

Create a test branch:

    git checkout -b test-pr

Make a small change:

    echo "# Test" >> README.md

Add the change:

    git add README.md

Commit:

    git commit -m "Test PR"

Push the branch:

    git push origin test-pr

Then open a Pull Request on GitHub.

---

## 🔄 PR Testing Flow

test-pr branch
      ↓
Push
      ↓
Open Pull Request
      ↓
pr-pipeline.yml
      ↓
Build + Test
      ↓
Lint
      ↓
PR Summary

---

## 🖱️ Manually Trigger Health Check

Go to:

GitHub
→ Actions
→ Health Check
→ Run workflow

This manually starts:

`health-check.yml`

without waiting for the scheduled cron.

---

## 🧪 Testing the Main Pipeline

Merge the Pull Request into:

`main`

Then:

Push to main
      ↓
main-pipeline.yml
      ↓
Build + Test
      ↓
Docker Build
      ↓
Docker Push
      ↓
Trivy Security Scan
      ↓
Pipeline Summary

---

## 🐳 Verify Docker Image

After a successful main pipeline, go to Docker Hub and check:

`my-app`

The image should have a tag based on:

`github.sha`

Example:

`myuser/my-app:4f8c2a1...`

---

## 📊 Workflow Comparison

| Workflow | Trigger | Purpose |
|---|---|---|
| `reusable-build-test.yml` | `workflow_call` | Build + test + lint |
| `reusable-docker.yml` | `workflow_call` | Docker build + push |
| `pr-pipeline.yml` | `pull_request` | Validate Pull Requests |
| `main-pipeline.yml` | `push` | Full CI/CD pipeline |
| `health-check.yml` | `schedule` | Daily health check |

---

## 🏗️ Complete CI/CD Architecture

GitHub Repository
        │
        ↓
Pull Request / Push
        │
   ┌────┴────┐
   │         │
   ↓         ↓
Pull Request  main
   │         │
   ↓         ↓
PR Pipeline  Main Pipeline
   │         │
   ↓         ↓
Reusable     Reusable
Build/Test   Build/Test
   │         │
 ┌─┴─┐     ┌─┴─┐
 ↓   ↓     ↓   ↓
Lint Test Lint Test
 │   │     │   │
 └─┬─┘     └─┬─┘
   │         │
   ↓         ↓
PR Result  Docker Build
              ↓
          Docker Push
              ↓
          Trivy Scan
              ↓
            Notify

---

## ⏰ Scheduled Health Architecture

Cron
 │
 ↓
health-check.yml
 │
 ├── Check app.py
 │
 ├── Check Dockerfile
 │
 └── Run Tests
       ↓
   Health Report

---

## 🔥 Complete Capstone Flow

Developer
    │
    ↓
Create Pull Request
    │
    ↓
PR Pipeline
    │
    ↓
Reusable Build + Test
    │
    ├── Lint
    │
    └── Test
    │
    ↓
PR Validation
    │
    ↓
PR Merge
    │
    ↓
main branch
    │
    ↓
Main Pipeline
    │
    ↓
Reusable Build + Test
    │
    ↓
Docker Build
    │
    ↓
Docker Push
    │
    ↓
Trivy Security Scan
    │
    ↓
Pipeline Summary
    │
    ↓
Scheduled Health Checks

---

## 🧠 Day 48 Key Learnings

### Reusable Workflows

`workflow_call`

allows one workflow to be called by another workflow.

### PR Validation

`pull_request`

allows every Pull Request to be validated before merge.

### Main CI/CD

    push:
      branches: [ main ]

runs the production pipeline whenever code reaches `main`.

### Docker Automation

`docker/login-action`

and

`docker/build-push-action`

automate Docker authentication, image building, and pushing.

### Security Scanning

`Trivy`

helps detect vulnerabilities before deployment.

### Scheduled Monitoring

    schedule:
      - cron: '0 2 * * *'

runs automated health checks every day.

### Traceability

`github.sha`

creates traceable Docker image tags.

### Secrets

GitHub Secrets safely store Docker Hub credentials.

### Reusability

Reusable workflows reduce duplicate CI/CD configuration.

---

## 🎯 Design Principles Used

### 1. DRY — Don't Repeat Yourself

Instead of repeating build and test steps across multiple workflows, both PR and main pipelines reuse:

`reusable-build-test.yml`

This reduces duplication.

### 2. Fail Fast

The pipeline follows:

Lint
 ↓
Test
 ↓
Docker Build
 ↓
Docker Push

If tests fail, Docker build and push should not proceed.

### 3. Security

Every main push performs a vulnerability scan using:

`Trivy`

The pipeline checks:

`HIGH`

and

`CRITICAL`

severity vulnerabilities.

### 4. Traceability

Docker images are tagged using:

`github.sha`

This makes it possible to identify exactly which commit created an image.

### 5. Reusability

Reusable workflows are called using:

`uses: ./.github/workflows/reusable-build-test.yml`

and:

`uses: ./.github/workflows/reusable-docker.yml`

This keeps the CI/CD architecture clean.

### 6. Visibility

The final notification job reports:

- Docker result
- Security result
- Docker image tag

This makes pipeline results easier to understand.

---

## 📚 Day 48 Summary

The capstone combines everything learned throughout the GitHub Actions and Docker CI/CD journey.

CI/CD CAPSTONE
      │
      ├── Pull Request
      │      ↓
      │   PR Pipeline
      │      ↓
      │   Build + Test
      │      ↓
      │   Lint + Tests
      │      ↓
      │   PR Validation
      │
      ├── Push to Main
      │      ↓
      │   Main Pipeline
      │      ↓
      │   Build + Test
      │      ↓
      │   Docker Build
      │      ↓
      │   Docker Push
      │      ↓
      │   Trivy Scan
      │      ↓
      │   Notify
      │
      └── Schedule
             ↓
         Health Check
             ↓
         Repository Check
             ↓
         Application Check
             ↓
         Dockerfile Check
             ↓
         Tests
             ↓
         Health Report

---

## 🏆 Final Takeaways

> **Reusable workflows = Avoid duplication**

> **`workflow_call` = Reusable workflow**

> **`pull_request` = Validate every PR**

> **`push` to main = Run production CI/CD**

> **Docker Build + Push = Package and publish application**

> **Trivy = Security vulnerability scanning**

> **`schedule` = Automated health checks**

> **`github.sha` = Traceable Docker image tags**

> **GitHub Secrets = Secure credential storage**

> **Workflow dependencies = Control job execution order**

> **DRY + Fail Fast + Security + Visibility = Production-quality CI/CD**

---

# 🚀 Day 48 Complete

The CI/CD capstone now provides a complete automation pipeline:

Code
 ↓
Pull Request Validation
 ↓
Merge
 ↓
Build
 ↓
Test
 ↓
Docker Build
 ↓
Docker Push
 ↓
Security Scan
 ↓
Pipeline Summary
 ↓
Scheduled Health Checks

### Technologies Covered

- GitHub Actions
- Reusable Workflows
- Composite Actions
- Docker
- Docker Hub
- CI/CD
- Pull Request Validation
- Automated Testing
- Security Scanning
- Scheduled Workflows
- GitHub Secrets
- Workflow Dependencies
- Docker Image Tagging
- Pipeline Visibility
