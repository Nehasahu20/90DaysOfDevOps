# Day 42 — Runners: GitHub-Hosted vs Self-Hosted

## What is a Runner?

A runner is the machine (virtual or physical) that executes your GitHub Actions jobs.

Think of it as the **"worker"** that does the actual work.

---

# GitHub-Hosted Runners

GitHub provides virtual machines that are ready to use.

| Label | OS | Pre-installed Tools |
|---|---|---|
| `ubuntu-latest` | Ubuntu | Git, Node, Python, Docker, Java, etc. |
| `ubuntu-22.04` | Ubuntu 22.04 | Same as above |
| `ubuntu-20.04` | Ubuntu 20.04 | Older versions |
| `windows-latest` | Windows Server | PowerShell, .NET, Chocolatey |
| `macos-latest` | macOS | Xcode, Homebrew, Node |

> Runner images and included software can change over time. Check GitHub's current runner documentation when exact versions matter.

---

## How to Use a GitHub-Hosted Runner

```yaml
jobs:
  my-job:
    runs-on: ubuntu-latest

    steps:
      - name: Say Hello
        run: echo "Running on GitHub-hosted runner"
```

Here:

```text
runs-on: ubuntu-latest
```

means GitHub creates a temporary Ubuntu virtual machine for the job.

---

## What You Get with GitHub-Hosted Runners

For GitHub Free, public repositories generally have access to GitHub-hosted runner usage without the same private-repository minute limits, while private repositories have plan-specific included minutes and storage. Exact limits can change.

Typical hosted runner characteristics:

```text
Fresh virtual machine
        ↓
Job runs
        ↓
Job finishes
        ↓
VM is destroyed
```

This means you should **not depend on files or state remaining between workflow runs**.

---

# Self-Hosted Runners

A self-hosted runner is **your own machine** connected to GitHub.

Examples:

```text
EC2 Server
Laptop
Physical Server
Virtual Machine
Private Cloud Server
```

Instead of GitHub providing the machine:

```text
GitHub Actions
      ↓
YOUR MACHINE
```

---

## Why Use a Self-Hosted Runner?

Self-hosted runners can be useful when you:

- Need more RAM or CPU
- Need access to a private network or database
- Need specific software installed
- Need custom hardware
- Want more control over the environment
- Need persistent local state

### Important

Self-hosted runners are **not automatically unlimited or free**.

You are responsible for the cost of the machine you use, such as an AWS EC2 instance.

---

# How to Set Up a Self-Hosted Runner on EC2

For an Amazon Linux EC2 server:

## 1. Go to GitHub

Go to:

```text
GitHub Repository
      ↓
Settings
      ↓
Actions
      ↓
Runners
      ↓
New self-hosted runner
```

Choose:

```text
Linux
x64
```

GitHub will then show commands specific to your repository and the current runner version.

> Use the commands shown by GitHub rather than copying an old runner version from notes, because runner versions change.

---

## 2. Create a Folder for the Runner

```bash
mkdir -p ~/actions-runner
cd ~/actions-runner
```

---

## 3. Download the Runner

GitHub will provide the current download command on the **New self-hosted runner** page.

It will look similar to:

```bash
curl -o actions-runner-linux-x64.tar.gz -L https://github.com/actions/runner/releases/download/VERSION/actions-runner-linux-x64-VERSION.tar.gz
```

Replace `VERSION` with the version currently provided by GitHub.

---

## 4. Extract the Runner

```bash
tar xzf ./actions-runner-linux-x64.tar.gz
```

---

## 5. Configure the Runner

GitHub will provide a temporary registration token.

The command looks like:

```bash
./config.sh --url https://github.com/YOUR_USERNAME/YOUR_REPO --token YOUR_TOKEN
```

Replace:

```text
YOUR_USERNAME
YOUR_REPO
YOUR_TOKEN
```

with the values provided by GitHub.

> Never commit or share the registration token.

---

## 6. Start the Runner

```bash
./run.sh
```

You should see the runner connect to GitHub.

Keep this terminal running while practicing.

---

# Install Missing Dependencies on Amazon Linux

If your runner reports missing dependencies, install the packages required by the error.

For example, depending on the Amazon Linux version and the current runner requirements:

```bash
sudo dnf install -y libicu
```

For .NET-related requirements, follow the dependency instructions shown by the runner/GitHub documentation for your specific OS version.

---

# Use Self-Hosted Runner in a Workflow

```yaml
jobs:
  my-job:
    runs-on: self-hosted

    steps:
      - name: Say Hello
        run: echo "Running on my machine"
```

Here:

```text
runs-on: self-hosted
```

means GitHub looks for a registered self-hosted runner.

---

# Runner Labels

Labels allow you to target specific runners.

Default labels on self-hosted runners commonly include:

```text
self-hosted
linux / windows / macOS
x64 / arm64
```

You can also create custom labels.

Example:

```bash
./config.sh \
  --url https://github.com/YOUR_USERNAME/YOUR_REPO \
  --token YOUR_TOKEN \
  --labels my-ec2,production,aws
```

Then use the labels in your workflow:

```yaml
jobs:
  deploy:
    runs-on: [self-hosted, my-ec2]

    steps:
      - name: Deploy
        run: echo "Deploying from EC2"
```

### Important

When multiple labels are specified, the runner must match **all required labels**.

```text
[self-hosted, my-ec2]

        ↓

Self-hosted? YES
        +
my-ec2? YES
        ↓
Runner selected
```

---

# Matrix Builds — Run on Multiple OS

A matrix allows you to run the same job with multiple configurations.

Example:

```yaml
name: Multi-OS Test

on:
  push:
  workflow_dispatch:

jobs:
  test:
    runs-on: ${{ matrix.os }}

    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]

    steps:
      - uses: actions/checkout@v4

      - name: Show OS info
        run: echo "Running on ${{ matrix.os }}"
```

This creates **3 jobs**:

```text
Ubuntu
Windows
macOS
```

They can run in parallel.

---

# Matrix with Multiple Dimensions

You can use more than one matrix variable.

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest]
    node: [18, 20, 22]
```

This creates:

```text
2 operating systems × 3 Node versions = 6 jobs
```

The combinations are:

```text
Ubuntu + Node 18
Ubuntu + Node 20
Ubuntu + Node 22

Windows + Node 18
Windows + Node 20
Windows + Node 22
```

---

# Practice Files

## Task 1 — Multi-OS Workflow

Create:

```text
.github/workflows/multi-os.yml
```

Using:

```bash
cat > .github/workflows/multi-os.yml << 'EOF'
name: Multi-OS Test

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  test:
    runs-on: ${{ matrix.os }}

    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]

    steps:
      - uses: actions/checkout@v4

      - name: Show OS info
        run: echo "Running on ${{ runner.os }}"

      - name: Show runner details
        run: |
          echo "OS: ${{ runner.os }}"
          echo "Architecture: ${{ runner.arch }}"
EOF
```

---

# Task 2 — Check Pre-installed Tools

Create:

```text
.github/workflows/check-tools.yml
```

Using:

```bash
cat > .github/workflows/check-tools.yml << 'EOF'
name: Check Pre-installed Tools

on:
  workflow_dispatch:

jobs:
  check:
    runs-on: ubuntu-latest

    steps:
      - name: Check Git
        run: git --version

      - name: Check Node
        run: node --version

      - name: Check Python
        run: python3 --version

      - name: Check Docker
        run: docker --version

      - name: Check Java
        run: java --version
EOF
```

---

# Task 3 — Self-Hosted Runner Workflow

Create:

```text
.github/workflows/self-hosted.yml
```

Using:

```bash
cat > .github/workflows/self-hosted.yml << 'EOF'
name: Self-Hosted Runner Demo

on:
  workflow_dispatch:

jobs:
  on-my-machine:
    runs-on: self-hosted

    steps:
      - uses: actions/checkout@v4

      - name: Show hostname
        run: hostname

      - name: Show who I am
        run: whoami

      - name: Show disk space
        run: df -h

      - name: Show memory
        run: free -m
EOF
```

---

# Practice Commands

## Go to Your Repository

```bash
cd ~/github-actions-practice
```

---

## Commit and Push Multi-OS Workflow

```bash
git add .github/workflows/multi-os.yml
git commit -m "Day 42: multi-OS matrix build"
git push
```

---

## Commit the Other Workflows

```bash
git add .github/workflows/check-tools.yml
git add .github/workflows/self-hosted.yml
git commit -m "Day 42: add runner practice workflows"
git push
```

---

# Check Self-Hosted Runner Logs

Go to the runner directory:

```bash
cd ~/actions-runner
```

Check diagnostic logs:

```bash
cat _diag/*.log | tail -50
```

---

# Check Runner Status

```bash
ps aux | grep run.sh
```

---

# Stop the Runner Gracefully

If the runner is running in the current terminal:

```text
Ctrl + C
```

This is the simplest way to stop it.

---

# Comparison Table

| Feature | GitHub-Hosted | Self-Hosted |
|---|---|---|
| Machine | GitHub's VM | Your machine |
| Cost | Free with plan limits | Your machine cost |
| Setup | Almost zero | Manual setup |
| RAM/CPU | GitHub-provided | Depends on your machine |
| Security | Isolated VM managed by GitHub | Your responsibility |
| Minutes | Plan-dependent | No GitHub-hosted minute usage for the self-hosted execution itself |
| Internet | Available | Depends on your network |
| State | Fresh environment each run | Can persist if you configure it that way |
| Control | Limited | High |
| Software | Pre-installed tools | You install what you need |

---

# GitHub-Hosted vs Self-Hosted

## GitHub-Hosted

```text
GitHub
   |
   v
GitHub Actions
   |
   v
GitHub VM
   |
   v
Your Job
   |
   v
VM Removed
```

The environment is normally fresh for each job.

---

## Self-Hosted

```text
GitHub
   |
   v
GitHub Actions
   |
   v
Your EC2 / Server
   |
   v
Your Job
   |
   v
Machine Remains
```

You control the machine and its installed software.

---

# Important Security Note for Self-Hosted Runners

Self-hosted runners require extra security responsibility.

A workflow running on your self-hosted runner can execute commands on that machine.

Therefore:

- Don't use untrusted workflows on a sensitive server.
- Don't expose important credentials unnecessarily.
- Keep the runner updated.
- Use least-privilege IAM permissions.
- Separate production runners from development runners.
- Don't allow arbitrary pull requests to run privileged deployment commands.

For your hackathon, this is especially important because you will later add **DevSecOps, AWS credentials, Terraform, secrets, and deployment automation**.

---

# Key Things to Remember

```text
Runner
→ Machine that executes GitHub Actions jobs

GitHub-hosted runner
→ Temporary VM provided by GitHub

Self-hosted runner
→ Your own EC2, laptop, VM, or server

runs-on: ubuntu-latest
→ GitHub-hosted Ubuntu runner

runs-on: self-hosted
→ Your own registered runner

Labels
→ Target specific runners

Matrix
→ Run the same job using multiple configurations

needs:
→ Create dependencies between jobs
```

---

# Summary

- **GitHub-hosted runners** = GitHub-provided virtual machines.
- **Self-hosted runners** = Your own machines.
- GitHub-hosted runners are convenient and usually provide a fresh environment for each job.
- Self-hosted runners provide more control over hardware, software, networking, and environment.
- **Labels** allow you to target specific self-hosted runners.
- **Matrix builds** allow the same job to run across multiple operating systems or software versions.
- `runs-on: ubuntu-latest` = GitHub-hosted Ubuntu runner.
- `runs-on: self-hosted` = Your own registered runner.

## Final Flow

```text
                    GitHub Actions
                         |
              ┌──────────┴──────────┐
              |                     |
              v                     v
     GitHub-Hosted Runner     Self-Hosted Runner
              |                     |
              v                     v
       GitHub VM                 Your EC2
              |                     |
              v                     v
          Job Runs              Job Runs
```

**GitHub-Hosted = Easy + Managed**

**Self-Hosted = Control + Customization**

**Matrix = Multiple OS/Versions in Parallel**
