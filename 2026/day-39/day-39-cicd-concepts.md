# Day 39 - What is CI/CD?

## Why CI/CD Exists - The Problem

### Without CI/CD (Manual Deployments)

Imagine a team with 5 developers:

* Dev A pushes code and manually deploys → works fine
* Dev B pushes different code and manually deploys → breaks Dev A's changes
* Dev C forgets to run tests → bug reaches production

### Common Problems

1. Developers overwrite each other's changes
2. "It works on my machine" issues
3. No consistent testing before deployment
4. Maximum 1–2 deployments per day
5. No audit trail of deployments
6. Difficult rollback when failures occur

---

## "It Works on My Machine" Explained

### Developer Environment

```text
Python 3.11
MySQL 8.0
libssl 1.1
Ubuntu 22.04
```

### Production Environment

```text
Python 3.8
MySQL 5.7
libssl 1.0
CentOS 7
```

Result:

```text
Code passes locally
        ↓
Deploy to production
        ↓
Application crashes
        ↓
Hours wasted debugging
```

### How Docker + CI/CD Solves This

* Docker ensures the same environment everywhere
* CI/CD provides automated and repeatable deployments

```text
Development → Staging → Production

Same Container
Same Process
Same Results
```

---

## Manual vs CI/CD Deployment Frequency

| Deployment Type    | Frequency               |
| ------------------ | ----------------------- |
| Manual Deployments | 1–2 deployments/day     |
| CI/CD Pipeline     | 50–100+ deployments/day |

Many large technology companies deploy multiple times every hour using automated pipelines.

---

# Continuous Integration (CI)

## Definition

Continuous Integration is the practice of automatically building and testing code whenever developers push changes to a repository.

---

## CI Workflow

1. Developer writes code
2. Code is pushed to GitHub
3. Pipeline starts automatically
4. Application is built
5. Tests are executed
6. Security scans are performed
7. Results are reported

If any step fails:

* Developer is notified
* Pull Request is blocked
* Issue is fixed before merge

---

## What CI Catches

* Compilation failures
* Broken unit tests
* Security vulnerabilities
* Code style violations
* Merge conflicts

---

## Real Example

A developer pushes a Flask application.

CI Pipeline runs:

```bash
pytest tests/
flake8 app.py
bandit -r app.py
```

Purpose:

```text
pytest  -> Unit Testing
flake8  -> Code Style Check
bandit  -> Security Scan
```

Outcome:

```text
All Pass
    ↓
Safe to Merge

Any Fail
    ↓
Developer Fixes Issue
```

---

# Continuous Delivery (CD)

## Definition

Continuous Delivery automatically packages and deploys applications to staging environments after CI succeeds.

Production deployment still requires manual approval.

---

## Delivery Workflow

```text
Code Push
    ↓
CI Passes
    ↓
Build Docker Image
    ↓
Push Image to Registry
    ↓
Deploy to Staging
    ↓
QA Testing
    ↓
Manual Approval
    ↓
Production Deployment
```

---

## Why Manual Approval?

Organizations often need control over:

* Release schedules
* Weekend deployments
* Holiday deployments
* Business approvals
* Compliance requirements

---

# Continuous Deployment

## Definition

Continuous Deployment automatically deploys every successful change to production with no human intervention.

---

## Deployment Workflow

```text
Developer Merges Code
        ↓
Tests Pass
        ↓
Docker Image Built
        ↓
Deploy to Production
        ↓
Users Receive Update
```

Time from merge to production can be only a few minutes.

---

## Companies Using Continuous Deployment

* Netflix
* GitHub
* Etsy
* Amazon

These organizations rely on strong automated testing and monitoring.

---

# CI vs CD Comparison

| Feature                    | CI  | Continuous Delivery | Continuous Deployment |
| -------------------------- | --- | ------------------- | --------------------- |
| Auto Build                 | ✅   | ✅                   | ✅                     |
| Auto Testing               | ✅   | ✅                   | ✅                     |
| Auto Deploy to Staging     | ❌   | ✅                   | ✅                     |
| Auto Deploy to Production  | ❌   | ❌                   | ✅                     |
| Manual Production Approval | N/A | ✅ Required          | ❌ Not Required        |
| Risk Level                 | Low | Medium              | High                  |

---

# Pipeline Anatomy

## Key Terms

| Term     | Definition                 | Example             |
| -------- | -------------------------- | ------------------- |
| Trigger  | Event that starts pipeline | Push, Pull Request  |
| Stage    | Logical group of jobs      | Test, Build, Deploy |
| Job      | Unit of work inside stage  | Run Tests           |
| Step     | Individual command         | `pytest tests/`     |
| Runner   | Machine executing jobs     | GitHub Runner       |
| Artifact | Output shared between jobs | Docker Image        |

---

# Pipeline Structure

```text
Pipeline
│
├── Stage: Test
│   ├── Job: Unit Tests
│   │   ├── Install Dependencies
│   │   ├── Run Tests
│   │   └── Upload Coverage Report
│   │
│   └── Job: Lint
│       ├── Flake8
│       └── MyPy
│
├── Stage: Build
│   └── Job: Build Image
│       ├── Docker Build
│       ├── Docker Push
│       └── Save Artifact
│
└── Stage: Deploy
    └── Job: Deploy Staging
        ├── Pull Image
        ├── SSH Server
        └── Docker Compose Up
```

---

# CI/CD Pipeline Diagram

```text
Developer Pushes Code
          │
          ▼

┌─────────────────────┐
│      TEST STAGE     │
├─────────────────────┤
│ Install Dependencies│
│ Run Tests           │
│ Lint Code           │
│ Security Scan       │
└─────────────────────┘
          │
          ▼

┌─────────────────────┐
│     BUILD STAGE     │
├─────────────────────┤
│ Docker Build        │
│ Docker Tag          │
│ Docker Push         │
└─────────────────────┘
          │
          ▼

┌─────────────────────┐
│    DEPLOY STAGE     │
├─────────────────────┤
│ Pull Docker Image   │
│ Deploy to Staging   │
│ Smoke Testing       │
└─────────────────────┘
          │
          ▼

Application Live
```

---

# GitHub Actions Example

**File:** `.github/workflows/test.yml`

```yaml
name: CI Pipeline

on:
  push:
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - uses: actions/setup-python@v4
        with:
          python-version: "3.11"

      - run: pip install -r requirements.txt

      - run: pytest tests/

  lint:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - run: pip install ruff mypy

      - run: ruff check .

      - run: mypy app/
```

---

# CI/CD Tools Comparison

| Tool           | Type                | Best For               | Pricing     |
| -------------- | ------------------- | ---------------------- | ----------- |
| GitHub Actions | Cloud               | GitHub Repositories    | Free Tier   |
| GitLab CI      | Cloud / Self-Hosted | Enterprise Pipelines   | Free Tier   |
| Jenkins        | Self-Hosted         | Full Control           | Free        |
| CircleCI       | Cloud               | Fast Docker Builds     | Free Tier   |
| ArgoCD         | Kubernetes          | GitOps CD              | Open Source |
| Tekton         | Kubernetes          | Cloud-Native Pipelines | Open Source |

---

# The Full DevOps Loop

```text
PLAN
  ↓
CODE
  ↓
BUILD
  ↓
TEST
  ↓
RELEASE
  ↓
DEPLOY
  ↓
OPERATE
  ↓
MONITOR
  ↓
FEEDBACK
  ↓
PLAN
```

### Responsibilities

| Area   | Covers                    |
| ------ | ------------------------- |
| CI     | Build + Test              |
| CD     | Release + Deploy          |
| DevOps | Entire Software Lifecycle |

---

# Complete Workflow

1. Developer writes code
2. Git commit and Git push
3. CI pipeline starts

   * Lint code
   * Run tests
   * Security scan
   * Build Docker image
4. Push image to registry
5. CD pipeline starts

   * Deploy to Development
   * Deploy to Staging
   * Run Smoke Tests
   * Deploy to Production
6. Monitoring tools observe application
7. Alerts are generated if issues occur
8. Developers receive feedback and improve the application

---

# Key Takeaways

* CI automatically builds and tests code.
* Continuous Delivery deploys to staging automatically but requires production approval.
* Continuous Deployment automatically deploys to production.
* Docker ensures consistency across environments.
* CI/CD reduces human error and deployment risk.
* Automated pipelines enable faster and safer software delivery.

---

## Day 39 Summary

CI/CD is the backbone of modern DevOps. It automates building, testing, packaging, and deployment processes, allowing teams to release software faster, more reliably, and with greater confidence.
