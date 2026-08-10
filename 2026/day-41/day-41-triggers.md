# Day 41 — Introduction to GitHub Actions

## What is GitHub Actions?

GitHub Actions is a CI/CD platform built directly into GitHub. It lets you automate:

- Building your code
- Running tests
- Deploying applications
- Any custom automation task

You write automation as **YAML files** stored inside your repository.

---

## Core Concepts

### 1. Workflow

A workflow is an automated process.

- Defined in a `.yml` file inside `.github/workflows/`
- Triggered by events such as push, pull request, schedule, or manual execution
- One repository can have many workflows

---

### 2. Event (Trigger)

An event tells GitHub Actions **WHEN** to run the workflow.

| Event | When it fires |
|---|---|
| `push` | Code is pushed to the repository |
| `pull_request` | A PR is opened or updated |
| `schedule` | At a fixed time using cron |
| `workflow_dispatch` | Manually triggered from GitHub UI |
| `release` | A release is created |

---

### 3. Job

A job is a group of steps that run together.

- Each job runs on a runner (virtual machine)
- Jobs run in parallel by default
- Jobs can be made sequential using `needs:`

Example:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Building application"

  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - run: echo "Running tests"
```

Here, the `test` job waits for the `build` job because of:

```yaml
needs: build
```

---

### 4. Step

A step is one command or action inside a job.

Steps run sequentially, one after another.

There are two main types:

#### `run:`

Used to execute shell commands.

```yaml
- name: Show files
  run: ls -la
```

#### `uses:`

Used to run a pre-built GitHub Action.

```yaml
- name: Checkout code
  uses: actions/checkout@v4
```

---

### 5. Action

An Action is a reusable piece of automation.

Examples:

```yaml
actions/checkout@v4
```

Checks out your repository code.

```yaml
actions/setup-python@v5
```

Installs and configures Python.

---

### 6. Runner

A runner is the machine that runs your job.

GitHub provides hosted runners such as:

```text
ubuntu-latest
windows-latest
macos-latest
```

You can also use your own machine as a **self-hosted runner**.

---

# Workflow File Structure

A typical repository can contain multiple workflows:

```text
your-repo/
└── .github/
    └── workflows/
        ├── ci.yml
        ├── deploy.yml
        └── tests.yml
```

The `.github/workflows/` directory is where GitHub looks for workflow files.

---

# Basic Workflow Anatomy

A simple GitHub Actions workflow looks like this:

```yaml
name: My First Workflow

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Say Hello
        run: echo "Hello, GitHub Actions!"

      - name: Run multiple commands
        run: |
          echo "Step 1"
          echo "Step 2"
          ls -la
```

### Understanding the Structure

```text
name:
    Name of the workflow shown in GitHub UI

on:
    Trigger — when should the workflow run?

jobs:
    Jobs — what should be executed?

build:
    Job name — you choose the name

runs-on:
    Runner/machine where the job runs

steps:
    Commands/actions executed inside the job

uses:
    Pre-built GitHub Action

run:
    Shell command
```

---

# How Data Flows

The basic flow of GitHub Actions is:

```text
GitHub Event
(push / pull request)
        |
        v
Workflow Triggered
        |
        v
Job Starts on Runner
        |
        v
Step 1 → Step 2 → Step 3
        |
        v
Job Completed
```

For example:

```text
Developer
    |
    | git push
    v
GitHub Repository
    |
    v
GitHub Actions
    |
    v
Workflow
    |
    v
Job
    |
    ├── Checkout Code
    ├── Install Dependencies
    ├── Run Tests
    └── Build Application
```

---

# Practice — Set Up Your Repository

## 1. SSH into your EC2 server

```bash
ssh -i ~/Downloads/nehanew.pem ec2-user@YOUR_EC2_PUBLIC_DNS
```

Replace `YOUR_EC2_PUBLIC_DNS` with your actual EC2 public DNS.

---

## 2. Go to your practice repository

```bash
cd ~/github-actions-practice
```

---

## 3. Create the workflows directory

```bash
mkdir -p .github/workflows
```

---

## 4. Create Your First Workflow

Create:

```text
.github/workflows/hello.yml
```

You can create it using:

```bash
cat > .github/workflows/hello.yml << 'EOF'
name: Hello World

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  greet:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Say Hello
        run: echo "Hello from GitHub Actions!"

      - name: Show date and time
        run: date

      - name: List files
        run: ls -la
EOF
```

---

# 5. Check the Workflow File

```bash
cat .github/workflows/hello.yml
```

You should see:

```yaml
name: Hello World

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  greet:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Say Hello
        run: echo "Hello from GitHub Actions!"

      - name: Show date and time
        run: date

      - name: List files
        run: ls -la
```

---

# 6. Push to GitHub

```bash
git add .
git commit -m "Add hello world workflow"
git push origin main
```

The `push` event will trigger the workflow automatically.

---

# Explore GitHub UI After Pushing

1. Go to your GitHub repository.
2. Click the **Actions** tab.
3. You will see the **Hello World** workflow.
4. Click on the workflow run.
5. Click on the job.
6. Expand each step to see its logs.

You should see output from:

```text
Checkout code
Say Hello
Show date and time
List files
```

---

# Key Things to Remember

| Concept | Location | Purpose |
|---|---|---|
| Workflow file | `.github/workflows/*.yml` | Defines automation |
| `on:` | Top of workflow | Defines when to trigger |
| `jobs:` | Inside workflow | Groups steps |
| `runs-on:` | Inside job | Defines runner |
| `steps:` | Inside job | Commands/actions to execute |
| `uses:` | Inside step | Uses a pre-built Action |
| `run:` | Inside step | Runs a shell command |

---

# Important GitHub Actions Commands and Keywords

```text
name:
    Workflow name

on:
    Workflow trigger

push:
    Runs when code is pushed

pull_request:
    Runs when a pull request is opened/updated

schedule:
    Runs automatically at a scheduled time

workflow_dispatch:
    Allows manual execution

jobs:
    Defines jobs

runs-on:
    Defines the runner

steps:
    Defines steps inside a job

uses:
    Uses a pre-built GitHub Action

run:
    Executes a shell command

needs:
    Creates a dependency between jobs
```

---

# Example — Multiple Jobs

Jobs normally run in parallel:

```yaml
name: CI Pipeline

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Build
        run: echo "Building application"

  test:
    runs-on: ubuntu-latest

    steps:
      - name: Test
        run: echo "Running tests"
```

To make one job wait for another:

```yaml
name: CI Pipeline

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Build
        run: echo "Building application"

  test:
    needs: build
    runs-on: ubuntu-latest

    steps:
      - name: Test
        run: echo "Running tests"
```

The flow becomes:

```text
Build
  |
  v
Test
```

---

# GitHub Actions in DevOps

GitHub Actions can become the CI part of a complete DevOps pipeline:

```text
Developer
    |
    | git push
    v
GitHub
    |
    v
GitHub Actions
    |
    ├── Checkout
    ├── Test
    ├── Security Scan
    ├── Build
    └── Docker Image
            |
            v
      Container Registry
            |
            v
          ArgoCD
            |
            v
        Kubernetes
```

For the hackathon, GitHub Actions can later be extended with:

```text
GitHub Actions
      |
      ├── Unit Tests
      ├── CodeQL
      ├── Secret Scanning
      ├── Trivy
      ├── Docker Build
      └── Push Image
```

---

# Summary

- **GitHub Actions** = Automation and CI/CD platform built into GitHub.
- **Workflow** = YAML file stored inside `.github/workflows/`.
- **Event** = Defines when the workflow runs.
- **Job** = Group of steps.
- **Step** = Individual command or action.
- **Action** = Reusable automation component.
- **Runner** = Machine that executes the job.
- `uses:` = Uses a pre-built action.
- `run:` = Executes a shell command.
- `needs:` = Makes one job depend on another.
- Workflows can run on `push`, `pull_request`, schedules, manual triggers, and other events.

## Final Flow

```text
Git Push
   ↓
GitHub Event
   ↓
Workflow Triggered
   ↓
Runner Starts
   ↓
Job
   ↓
Steps
   ├── Checkout
   ├── Test
   ├── Build
   └── Deploy
   ↓
Application Updated
```

**GitHub Actions = Automate → Test → Build → Deploy**
