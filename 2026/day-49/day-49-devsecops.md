# 🔐 Day 49 — DevSecOps: Security in CI/CD

## What is DevSecOps?

**DevSecOps = Development + Security + Operations**

Traditional approach:

Development → Testing → Deployment → Security Check

Security is checked **AFTER release**.

DevSecOps approach:

Code → Lint → Test → Security Scan → Build → Deploy

Security is integrated into the CI/CD pipeline from the beginning.

---

## Types of Security Checks in CI/CD

| Security Check | Tool | What It Finds |
|---|---|---|
| Dependency vulnerabilities | Trivy, Snyk | Known CVEs in packages |
| Secret scanning | GitHub Secret Scanning, Gitleaks | Passwords, API keys, tokens |
| Container scanning | Trivy | Vulnerabilities in Docker images |
| Code quality / SAST | CodeQL | Code-level security bugs |
| Dependency review | GitHub Dependency Review | Newly added risky packages |
| License compliance | FOSSA | License violations |

---

# 🔎 Trivy — Vulnerability Scanner

**Trivy** is an open-source security scanner by Aqua Security.

Trivy can scan:

- Container images
- Filesystems
- Git repositories
- Kubernetes configurations
- Dependencies
- Configuration files

---

# 📦 Install Trivy on Amazon Linux

## Add Trivy Repository

    sudo rpm --import https://aquasecurity.github.io/trivy-repo/rpm/public.key

    sudo bash -c 'cat > /etc/yum.repos.d/trivy.repo << EOF
    [trivy]
    name=Trivy repository
    baseurl=https://aquasecurity.github.io/trivy-repo/rpm/releases/\$basearch/
    gpgcheck=1
    enabled=1
    gpgkey=https://aquasecurity.github.io/trivy-repo/rpm/public.key
    EOF'

## Install Trivy

    sudo dnf install -y trivy

## Verify Installation

    trivy --version

---

# 🔍 Trivy Scan Commands

## 1. Scan Filesystem

    trivy fs .

Scans the project for vulnerabilities in dependencies and configuration files.

## 2. Scan a Docker Image

    trivy image python:3.11-slim

## 3. Scan Only HIGH and CRITICAL Vulnerabilities

    trivy fs --severity HIGH,CRITICAL .

## 4. Output Results as JSON

    trivy fs --format json --output results.json .

## 5. Output Results as Table

    trivy fs --format table .

## 6. Fail CI Pipeline if Critical Vulnerability Is Found

    trivy fs --exit-code 1 --severity CRITICAL .

If no critical vulnerability is found:

    Exit code 0
    Pipeline continues

If a critical vulnerability is found:

    Exit code 1
    Pipeline fails

## 7. Update Trivy Database

    trivy image --download-db-only

---

# 📊 Understanding Vulnerability Results

| Library | Version | Vulnerability | Severity | Fixed Version |
|---|---|---|---|---|
| requests | 2.31.0 | CVE-2023-32681 | MEDIUM | 2.31.0 |
| certifi | 2023.5.7 | CVE-2023-37920 | HIGH | 2023.07.22 |

### Library

The package that contains the vulnerability.

### Version

The currently installed package version.

### CVE

CVE stands for **Common Vulnerabilities and Exposures**.

Example:

    CVE-2023-32681

### Severity

Severity levels:

    CRITICAL > HIGH > MEDIUM > LOW

### Fixed Version

The package version containing the security fix.

---

# 🔧 Fixing Vulnerabilities

If `requests` has a vulnerability, update `requirements.txt`.

Before:

    requests==2.31.0

After:

    requests==2.33.0

Then verify:

    trivy fs .

Expected result:

    0 vulnerabilities found

---

# ⚙️ Trivy in GitHub Actions

## Filesystem Scan

    - name: Trivy filesystem scan
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: fs
        scan-ref: .
        severity: HIGH,CRITICAL
        exit-code: '1'

This means the GitHub Actions pipeline will fail if HIGH or CRITICAL vulnerabilities are detected.

---

# 🐳 Container Image Scan

## Build Docker Image

    - name: Build image
      run: docker build -t my-app:test .

## Scan Docker Image

    - name: Trivy image scan
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: image
        image-ref: my-app:test
        severity: CRITICAL
        exit-code: '1'

Pipeline flow:

    Dockerfile
        ↓
    Docker Build
        ↓
    my-app:test
        ↓
    Trivy Image Scan
        ↓
    Vulnerability Check
        ↓
    Pass → Continue
    Fail → Stop Pipeline

---

# 📄 Save Trivy Results as SARIF

SARIF results can be uploaded to GitHub Security.

    - name: Trivy scan with SARIF output
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: fs
        format: sarif
        output: trivy-results.sarif

    - name: Upload SARIF to GitHub Security
      uses: github/codeql-action/upload-sarif@v3
      with:
        sarif_file: trivy-results.sarif

This allows Trivy security findings to appear in the GitHub Security section.

---

# 🚫 .trivyignore — Ignore Specific CVEs

Sometimes a vulnerability may be:

- A false positive
- Not exploitable in your environment
- An accepted business risk

Create `.trivyignore`:

    cat > .trivyignore << 'EOF'

    # Accepted risk: CVE-XXXX-XXXX
    # Reason: not exploitable in our use case

    CVE-2023-12345
    CVE-2023-67890
    EOF

### Important

Do not blindly ignore vulnerabilities.

Every ignored CVE should have a documented reason.

---

# 🔑 GitHub Secret Scanning

GitHub can automatically scan repositories for exposed secrets such as:

- AWS Access Keys
- GitHub Personal Access Tokens
- Stripe API Keys
- Slack Webhooks
- SSH Private Keys
- API Tokens
- Cloud Credentials
- Other secret patterns

---

# ⚙️ Enable Secret Scanning

Go to:

**Repository → Settings → Security → Secret scanning → Enable**

---

# 🛑 Push Protection

Push Protection can block pushes when GitHub detects a secret.

Enable it from:

**Repository → Settings → Security → Secret scanning → Push protection → Enable**

Flow:

    Developer
        ↓
    git push
        ↓
    Secret detected?
       ↓
     ┌─┴─┐
     ↓   ↓
    NO  YES
     ↓   ↓
    Push  Push
    allowed blocked

Never commit:

- AWS credentials
- Docker passwords
- API tokens
- Private keys
- Database passwords

Use **GitHub Secrets** instead.

---

# 📦 Dependency Review Action

Dependency Review checks newly added dependencies in Pull Requests.

File:

    .github/workflows/dependency-review.yml

Example:

    name: Dependency Review

    on:
      pull_request:

    jobs:
      review:
        runs-on: ubuntu-latest

        permissions:
          contents: read
          pull-requests: write

        steps:
          - uses: actions/checkout@v4

          - uses: actions/dependency-review-action@v4
            with:
              fail-on-severity: high
              comment-summary-in-pr: always

This helps prevent vulnerable dependencies from being merged into the project.

---

# 🔐 Permissions — Principle of Least Privilege

Give workflows only the permissions they actually need.

Do not give every workflow full access to the repository.

---

## Workflow-Level Permissions

    permissions:
      contents: read
      packages: write
      security-events: write

### contents: read

Allows the workflow to read repository files.

### packages: write

Allows pushing packages or container images to GitHub Container Registry.

### security-events: write

Allows uploading security findings such as CodeQL or Trivy SARIF results.

---

# Job-Level Permissions

Permissions can also be configured for a specific job.

    jobs:
      scan:
        permissions:
          contents: read
          security-events: write

This gives the security scanning job only the permissions it requires.

---

# 📋 Common GitHub Actions Permissions

| Permission | Values | Used For |
|---|---|---|
| `contents` | read/write | Read or modify repository files |
| `packages` | read/write | GitHub Container Registry |
| `security-events` | write | CodeQL/Trivy security results |
| `pull-requests` | write | Comment on PRs |
| `id-token` | write | OIDC authentication |

---

# 🧪 Trivy Scan Examples — Real Commands

## Example 1: Scan requirements.txt

    cd ~/github-actions-practice

    trivy fs --severity HIGH,CRITICAL requirements.txt

## Example 2: Scan Entire Project

    trivy fs .

## Example 3: Scan Python Packages Only

    trivy fs --scanners vuln .

## Example 4: Check a Specific CVE

    trivy fs . | grep CVE-2023

## Example 5: Scan Docker Image

    trivy image python:3.11-slim

## Example 6: Generate JSON Output and Parse with jq

    trivy fs --format json . | jq '.Results[].Vulnerabilities[] | {id: .VulnerabilityID, pkg: .PkgName, sev: .Severity}'

## Example 7: Scan Only Critical Vulnerabilities

    trivy fs --severity CRITICAL --exit-code 1 .

## Example 8: Generate HTML Report

    trivy fs --format template --template "@contrib/html.tpl" -o report.html .

This creates:

    report.html

which can be opened in a browser.

---

# 🔧 What Was Fixed in Our Project

## BEFORE — requirements.txt

    requests==2.31.0
    pytest==7.4.0

Potential vulnerabilities were detected.

## AFTER — requirements.txt

    requests==2.33.0
    pytest==9.0.3

After upgrading dependencies:

    trivy fs .

Expected result:

    0 vulnerabilities found

---

# 🔄 DevSecOps Pipeline

The complete DevSecOps pipeline looks like:

    Developer
        ↓
    Git Push
        ↓
    Lint
        ↓
    Unit Tests
        ↓
    Dependency Review
        ↓
    Secret Scanning
        ↓
    SAST / CodeQL
        ↓
    Trivy Filesystem Scan
        ↓
    Docker Build
        ↓
    Trivy Container Scan
        ↓
    Docker Push
        ↓
    Deploy

Security is integrated throughout the pipeline instead of being performed only after deployment.

---

# 🛡️ Security Layers

    DevSecOps
        |
        +---------------+---------------+
        |               |               |
       Code        Dependencies       Secrets
        |               |               |
     CodeQL           Trivy       Secret Scanning
        |               |               |
        +---------------+---------------+
                        |
                  Docker Image
                        |
                        ↓
                  Trivy Scan
                        |
                        ↓
                     Deploy

---

# 🧠 DevSecOps Security Strategy

## 1. Shift Security Left

Find vulnerabilities early.

Instead of:

    Code → Build → Deploy → Security Check

Use:

    Code → Security Check → Build → Deploy

---

## 2. Automate Security

Security checks should run automatically in CI/CD.

Examples:

- Trivy
- CodeQL
- Secret Scanning
- Dependency Review
- Snyk

---

## 3. Fail on Critical Vulnerabilities

Use:

    exit-code: '1'

This prevents the pipeline from continuing when serious vulnerabilities are found.

---

## 4. Protect Secrets

Use:

**GitHub Secrets**

instead of hardcoding credentials.

Never put secrets directly inside:

- `app.py`
- `Dockerfile`
- GitHub Actions YAML
- `requirements.txt`
- `README.md`

---

## 5. Use Least Privilege

Give workflows only the permissions they need.

Example:

    permissions:
      contents: read

Avoid unnecessary write permissions.

---

# 📊 Security Tool Summary

| Tool | Purpose |
|---|---|
| Trivy | Dependency, filesystem and container vulnerability scanning |
| GitHub Secret Scanning | Detect exposed credentials |
| Push Protection | Block commits containing secrets |
| Dependency Review | Check new dependencies in PRs |
| CodeQL | Static Application Security Testing |
| Snyk | Dependency and security scanning |
| FOSSA | License compliance |

---

# 🎯 Day 49 Summary

**DevSecOps = Shift security left into the CI/CD pipeline.**

### Trivy

Scans:

- Filesystems
- Docker Images
- Dependencies
- Configuration
- Kubernetes

### Secret Scanning

GitHub can automatically detect:

- API Keys
- Passwords
- Tokens
- Private Keys
- Cloud Credentials

### Dependency Review

Checks newly added packages in Pull Requests.

### Permissions

Give workflows the minimum required permissions.

### .trivyignore

Use it only for carefully reviewed:

- False positives
- Accepted risks
- Non-exploitable vulnerabilities

### Pipeline Protection

Use:

    exit-code: '1'

to fail the pipeline when important vulnerabilities are discovered.

---

# 🏆 Final Takeaways

> **DevSecOps = Development + Security + Operations**

> **Shift security left into CI/CD**

> **Trivy = Scan filesystems and containers for vulnerabilities**

> **Secret Scanning = Detect exposed credentials**

> **Push Protection = Block pushes containing secrets**

> **Dependency Review = Check newly added dependencies**

> **CodeQL = Find code-level security vulnerabilities**

> **Least Privilege = Give workflows only required permissions**

> **.trivyignore = Carefully document accepted/false-positive CVEs**

> **exit-code: 1 = Fail the pipeline when vulnerabilities are detected**

> **Upgrade vulnerable dependencies to fixed versions**

> **Never hardcode passwords, API keys, tokens, or private keys**

---

# 🚀 Day 49 Complete

The CI/CD pipeline is now becoming a **DevSecOps pipeline**:

    Code
     ↓
    Lint
     ↓
    Test
     ↓
    Dependency Review
     ↓
    Secret Scanning
     ↓
    SAST / CodeQL
     ↓
    Trivy Filesystem Scan
     ↓
    Docker Build
     ↓
    Trivy Container Scan
     ↓
    Docker Push
     ↓
    Deploy

### 🔐 Security is no longer a final step.

### 🛡️ Security is part of every stage of CI/CD.
