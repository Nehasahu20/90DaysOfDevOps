# Day 44 — Secrets, Artifacts & Caching

## Secrets — Storing Sensitive Data

Secrets store passwords, API keys, tokens, database credentials, and other sensitive information. They are encrypted and should never be exposed in workflow logs.

### How to Add a Secret

GitHub → Your Repository → Settings → Secrets and variables → Actions → New repository secret

Example:

    Name: DEMO_TOKEN
    Value: mysecretvalue123

### Use Secret in Workflow

    steps:
      - name: Use secret
        env:
          MY_TOKEN: ${{ secrets.MY_SECRET_NAME }}
        run: echo "Token is set: $MY_TOKEN"

### NEVER Do This

    - run: echo "${{ secrets.MY_TOKEN }}"

### Always Use Environment Variable

    - name: Check secret
      env:
        TOKEN: ${{ secrets.MY_TOKEN }}
      run: echo "Token length: ${#TOKEN}"

## Secret Levels

| Level | Where to Set | Scope |
|---|---|---|
| Repository Secret | Repo → Settings → Secrets | One repository |
| Environment Secret | Repo → Settings → Environments | Specific environment |
| Organization Secret | Organization → Settings → Secrets | Multiple repositories |

### Environment-Specific Secrets

    jobs:
      deploy:
        runs-on: ubuntu-latest
        environment: production
        steps:
          - name: Deploy
            env:
              PROD_KEY: ${{ secrets.PROD_API_KEY }}
            run: echo "Deploying with production key"

## Artifacts — Saving Files Between Jobs

Artifacts are files produced by a workflow that you want to:

- Pass from one job to another
- Download after the workflow finishes
- Keep as a record
- Store test reports
- Store build outputs
- Store logs

### Upload Artifact

    - name: Upload test results
      uses: actions/upload-artifact@v4
      with:
        name: test-results
        path: ./test-output/
        retention-days: 30

### Download Artifact

    - name: Download test results
      uses: actions/download-artifact@v4
      with:
        name: test-results
        path: ./downloaded/

The artifact name used during download must match the upload name.

### Download from GitHub UI

GitHub → Actions → Click on a workflow run → Scroll down → Artifacts → Download

### Artifact Flow

    Build Job
        ↓
    Create Files
        ↓
    Upload Artifact
        ↓
    GitHub Storage
        ↓
    Another Job
        ↓
    Download Artifact

## Caching — Speed Up Workflows

Cache saves downloaded dependencies so they do not need to be downloaded every time.

Without cache:

    Workflow
        ↓
    Download Dependencies
        ↓
    Install Packages
        ↓
    Slow

With cache:

    Workflow
        ↓
    Restore Cache
        ↓
    Install Packages
        ↓
    Faster

### Cache Python pip Packages

    - name: Cache pip
      uses: actions/cache@v4
      with:
        path: ~/.cache/pip
        key: ${{ runner.os }}-pip-${{ hashFiles('requirements.txt') }}
        restore-keys: |
          ${{ runner.os }}-pip-

    - name: Install dependencies
      run: pip install -r requirements.txt

### Cache Node.js npm Packages

    - name: Cache npm
      uses: actions/cache@v4
      with:
        path: ~/.npm
        key: ${{ runner.os }}-npm-${{ hashFiles('package-lock.json') }}

### Cache Key Strategy

    Operating System + Package Manager + Dependency File Hash

Example:

    key: ${{ runner.os }}-pip-${{ hashFiles('requirements.txt') }}

If requirements.txt changes:

    requirements.txt changes
            ↓
        New hash
            ↓
      New cache key
            ↓
    Fresh dependencies

If requirements.txt stays the same:

    Same requirements.txt
            ↓
        Same hash
            ↓
      Same cache key
            ↓
        Cache Hit
            ↓
      Restore cache

# Practice Files Created

## Task 1 — Secrets Demo

Create `.github/workflows/secrets-demo.yml`

    cat > .github/workflows/secrets-demo.yml << 'EOF'
    name: Secrets Demo

    on:
      workflow_dispatch:

    jobs:
      use-secrets:
        runs-on: ubuntu-latest

        steps:
          - name: Use secret safely
            env:
              MY_TOKEN: ${{ secrets.DEMO_TOKEN }}
            run: |
              echo "Token is configured: $([ -n "$MY_TOKEN" ] && echo 'YES' || echo 'NO')"
              echo "Token length: ${#MY_TOKEN}"

          - name: Show what NOT to do
            run: echo "Never use secrets directly in run commands"
    EOF

First add a secret in GitHub:

    Repo → Settings → Secrets and variables → Actions → New repository secret

Name:

    DEMO_TOKEN

Value:

    mysecretvalue123

## Task 2 — Secrets as Environment Variables

Create `.github/workflows/env-secrets.yml`

    cat > .github/workflows/env-secrets.yml << 'EOF'
    name: Environment Secrets

    on:
      workflow_dispatch:

    jobs:
      check-env-secret:
        runs-on: ubuntu-latest
        environment: staging

        steps:
          - name: Use environment secret
            env:
              STAGE_DB: ${{ secrets.STAGING_DB_URL }}
            run: |
              if [ -n "$STAGE_DB" ]; then
                echo "Staging DB is configured"
              else
                echo "Staging DB secret not set"
              fi
    EOF

Create the staging environment in:

    GitHub → Repository → Settings → Environments

Then add the secret:

    STAGING_DB_URL

## Task 3 & 4 — Upload and Download Artifacts

Create `.github/workflows/artifacts.yml`

    cat > .github/workflows/artifacts.yml << 'EOF'
    name: Artifacts Demo

    on:
      workflow_dispatch:

    jobs:
      build:
        runs-on: ubuntu-latest

        steps:
          - uses: actions/checkout@v4

          - name: Create build output
            run: |
              mkdir -p build-output
              echo "Build completed at $(date)" > build-output/build.log
              echo "Version: 1.0.0" >> build-output/build.log

          - name: Upload build artifact
            uses: actions/upload-artifact@v4
            with:
              name: build-output
              path: build-output/
              retention-days: 7

      test:
        needs: build
        runs-on: ubuntu-latest

        steps:
          - name: Download build artifact
            uses: actions/download-artifact@v4
            with:
              name: build-output
              path: ./downloaded-build/

          - name: Read the artifact
            run: cat ./downloaded-build/build.log
    EOF

## Task 5 — Real Test Script

Create the scripts directory:

    mkdir -p scripts

Create the test script:

    cat > scripts/test.sh << 'EOF'
    #!/bin/bash

    set -e

    echo "=== Running Tests ==="

    echo "Test 1: Checking app.py exists..."

    if [ -f "app.py" ]; then
        echo "PASS: app.py exists"
    else
        echo "FAIL: app.py not found"
        exit 1
    fi

    echo "Test 2: Checking Dockerfile exists..."

    if [ -f "Dockerfile" ]; then
        echo "PASS: Dockerfile exists"
    else
        echo "FAIL: Dockerfile not found"
        exit 1
    fi

    echo "Test 3: Python syntax check..."

    python3 -m py_compile app.py

    echo "PASS: Python syntax is valid"
    echo "=== All Tests Passed ==="
    EOF

Make it executable:

    chmod +x scripts/test.sh

Create workflow that runs the test:

Create `.github/workflows/run-tests.yml`

    cat > .github/workflows/run-tests.yml << 'EOF'
    name: Run Tests

    on:
      push:
      pull_request:

    jobs:
      test:
        runs-on: ubuntu-latest

        steps:
          - uses: actions/checkout@v4

          - name: Run test script
            run: bash scripts/test.sh

          - name: Upload test results
            if: always()
            uses: actions/upload-artifact@v4
            with:
              name: test-logs
              path: scripts/
    EOF

## Task 6 — pip Caching

Create `.github/workflows/cache-demo.yml`

    cat > .github/workflows/cache-demo.yml << 'EOF'
    name: Cache Demo

    on:
      workflow_dispatch:

    jobs:
      install-with-cache:
        runs-on: ubuntu-latest

        steps:
          - uses: actions/checkout@v4

          - name: Cache pip packages
            uses: actions/cache@v4
            id: pip-cache
            with:
              path: ~/.cache/pip
              key: ${{ runner.os }}-pip-${{ hashFiles('requirements.txt') }}
              restore-keys: |
                ${{ runner.os }}-pip-

          - name: Install dependencies
            run: pip install -r requirements.txt

          - name: Show cache status
            run: |
              echo "Cache hit: ${{ steps.pip-cache.outputs.cache-hit }}"
              pip list | head -10
    EOF

# Practice Commands

Go to your practice repository:

    cd ~/github-actions-practice

Create scripts directory:

    mkdir -p scripts

Push all Day 44 files:

    git add .github/workflows/secrets-demo.yml \
    .github/workflows/env-secrets.yml \
    .github/workflows/artifacts.yml \
    .github/workflows/run-tests.yml \
    .github/workflows/cache-demo.yml \
    scripts/test.sh

Commit:

    git commit -m "Day 44: secrets, artifacts, caching"

Push:

    git push

# After Push

## 1. Add Secret

Go to:

    GitHub → Settings → Secrets and variables → Actions

Add:

    DEMO_TOKEN

## 2. Trigger Secrets Demo

    GitHub → Actions → Secrets Demo → Run workflow

Check the workflow logs.

The secret value should not be printed.

## 3. Trigger Artifacts Demo

    GitHub → Actions → Artifacts Demo → Run workflow

After the workflow finishes:

    Workflow Run → Artifacts → Download

## 4. Run Cache Demo Twice

    GitHub → Actions → Cache Demo → Run workflow

Run it a second time.

The second run should normally show:

    Cache hit: true

# Summary

| Feature | Purpose | Key Action |
|---|---|---|
| Secrets | Store passwords/tokens safely | `${{ secrets.NAME }}` |
| Repository Secrets | One repository access | Settings → Secrets |
| Environment Secrets | Deployment-specific secrets | `environment:` |
| Artifacts | Save/share files | `upload-artifact` / `download-artifact` |
| Cache | Speed up installations | `actions/cache@v4` |

# Golden Rules

1. Always use secrets through `env:`.
2. Never hard-code passwords, API keys, or tokens.
3. Never unnecessarily print secret values in workflow logs.
4. Use artifacts to save or share workflow files.
5. Artifacts expire, so use `retention-days:` when required.
6. Use cache to speed up dependency installation.
7. Cache keys should include the OS, package manager, and dependency file hash.
8. `hashFiles()` creates a hash based on file contents.
9. Use `actions/upload-artifact@v4` to upload files.
10. Use `actions/download-artifact@v4` to download files.
11. Use `actions/cache@v4` to cache dependencies.

# Day 44 Key Points

    Secrets   = Protect sensitive information
    Artifacts = Save and share workflow files
    Cache     = Speed up future workflow runs

## Day 44 = Secrets + Artifacts + Caching
