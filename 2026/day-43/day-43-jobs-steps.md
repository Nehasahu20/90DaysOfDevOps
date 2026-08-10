# Day 43 — Jobs, Steps, Environment Variables & Conditionals

## Job Dependencies — Sequential Jobs

By default, jobs run in parallel.

Use `needs:` to make jobs run sequentially.

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Building..."

  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - run: echo "Testing..."

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - run: echo "Deploying..."
```

### Flow

```text
build
  ↓
test
  ↓
deploy
```

Each job waits for the previous job to finish.

---

## Multiple Job Dependencies

A job can wait for multiple jobs.

```yaml
deploy:
  needs: [build, test]
  runs-on: ubuntu-latest

  steps:
    - run: echo "Deploying..."
```

Here, `deploy` waits for **both `build` and `test`** to finish.

```text
build ──┐
        ├──→ deploy
test  ──┘
```

---

# Environment Variables

Environment variables allow you to store values that can be used by your workflow, jobs, or steps.

There are **3 levels**.

---

## Level 1 — Workflow-Level Environment Variables

Available in **all jobs and steps**.

```yaml
env:
  APP_NAME: my-app
  VERSION: 1.0.0

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Build
        run: echo "Building $APP_NAME version $VERSION"
```

Here:

```text
APP_NAME = my-app
VERSION  = 1.0.0
```

These variables are available throughout the workflow.

---

## Level 2 — Job-Level Environment Variables

Available only inside that specific job.

```yaml
jobs:
  build:
    runs-on: ubuntu-latest

    env:
      BUILD_ENV: production

    steps:
      - name: Show environment
        run: echo "Env is $BUILD_ENV"
```

`BUILD_ENV` is available inside the `build` job.

---

## Level 3 — Step-Level Environment Variables

Available only inside that specific step.

```yaml
steps:
  - name: Deploy step
    env:
      DEPLOY_TARGET: aws
    run: echo "Deploying to $DEPLOY_TARGET"
```

`DEPLOY_TARGET` is available only in that step.

---

# Environment Variable Scope

```text
Workflow
   |
   ├── Workflow-level ENV
   |       |
   |       ├── Job 1
   |       |    └── Steps
   |       |
   |       └── Job 2
   |            └── Steps
   |
   └── Available throughout workflow
```

Job-level:

```text
Job
 |
 ├── Job-level ENV
 |
 ├── Step 1
 ├── Step 2
 └── Step 3
```

Step-level:

```text
Step
 |
 └── Step-level ENV only
```

---

# Built-in GitHub Variables

GitHub automatically provides many environment variables.

```bash
$GITHUB_REPOSITORY
```

Repository name:

```text
owner/repository
```

---

```bash
$GITHUB_SHA
```

Commit SHA/hash.

---

```bash
$GITHUB_REF
```

Branch or tag reference.

---

```bash
$GITHUB_ACTOR
```

User or application that triggered the workflow.

---

```bash
$GITHUB_WORKFLOW
```

Workflow name.

---

```bash
$GITHUB_RUN_NUMBER
```

Workflow run number.

---

```bash
$GITHUB_WORKSPACE
```

Path to the checked-out repository.

---

## Using GitHub Variables

```yaml
- name: Show GitHub information
  run: |
    echo "Repository: $GITHUB_REPOSITORY"
    echo "Branch: $GITHUB_REF"
    echo "Commit: $GITHUB_SHA"
    echo "Actor: $GITHUB_ACTOR"
```

---

# Job Outputs — Passing Data Between Jobs

You can use **job outputs** to pass data from one job to another.

Example:

```yaml
jobs:
  prepare:
    runs-on: ubuntu-latest

    outputs:
      build_version: ${{ steps.get_version.outputs.version }}

    steps:
      - name: Get version
        id: get_version
        run: echo "version=1.2.3" >> "$GITHUB_OUTPUT"

  deploy:
    needs: prepare
    runs-on: ubuntu-latest

    steps:
      - name: Use version
        run: echo "Deploying version ${{ needs.prepare.outputs.build_version }}"
```

### How it works

```text
prepare job
     |
     v
Get version
     |
     v
$GITHUB_OUTPUT
     |
     v
Job output
     |
     v
deploy job
```

---

# How `$GITHUB_OUTPUT` Works

Write a key/value pair:

```bash
echo "my_key=my_value" >> "$GITHUB_OUTPUT"
```

Then access it from another job:

```yaml
${{ needs.JOB_NAME.outputs.my_key }}
```

For example:

```yaml
${{ needs.prepare.outputs.build_version }}
```

---

# Conditionals — `if:` Statement

The `if:` condition controls whether a step or job runs.

---

## Run Only on Main Branch

```yaml
- name: Deploy to production
  if: github.ref == 'refs/heads/main'
  run: echo "Deploying..."
```

This step runs only when the workflow is running on the `main` branch.

---

## Run Only if Previous Steps Succeeded

```yaml
- name: Notify success
  if: success()
  run: echo "All good!"
```

---

## Run if Previous Step Failed

```yaml
- name: Cleanup on failure
  if: failure()
  run: echo "Something went wrong, cleaning up"
```

---

## Run Always

```yaml
- name: Always notify
  if: always()
  run: echo "Workflow finished"
```

This runs even when previous steps fail or the workflow is otherwise unsuccessful.

---

## Run on a Specific Event

```yaml
- name: Run only on PR
  if: github.event_name == 'pull_request'
  run: echo "This is a PR!"
```

---

## Combining Conditions

You can combine multiple conditions using `&&`.

```yaml
- name: Deploy only on main push
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  run: echo "Deploying main branch"
```

This runs only when:

```text
Branch = main
AND
Event = push
```

---

# Condition Functions

| Function | Meaning |
|---|---|
| `success()` | All previous steps passed |
| `failure()` | A previous step failed |
| `always()` | Always run |
| `cancelled()` | Workflow was cancelled |
| `contains(str, val)` | String contains a value |
| `startsWith(str, val)` | String starts with a value |

---

# Practice Files

## Task 1 — Multi-Job Chain

Create:

```text
.github/workflows/multi-job.yml
```

Using:

```bash
cat > .github/workflows/multi-job.yml << 'EOF'
name: Multi-Job Pipeline

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Build
        run: |
          echo "Building application..."
          echo "Build complete!"

  test:
    needs: build
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Test
        run: |
          echo "Running tests..."
          echo "All tests passed!"

  deploy:
    needs: test
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Deploy
        run: echo "Deploying to production!"
EOF
```

### Flow

```text
Build
  ↓
Test
  ↓
Deploy
```

---

# Task 2 — Three-Level Environment Variables

Create:

```text
.github/workflows/env-vars.yml
```

Using:

```bash
cat > .github/workflows/env-vars.yml << 'EOF'
name: Environment Variables Demo

on:
  workflow_dispatch:

env:
  WORKFLOW_VAR: "I am workflow-level"

jobs:
  show-envs:
    runs-on: ubuntu-latest

    env:
      JOB_VAR: "I am job-level"

    steps:
      - name: Show workflow variable
        run: echo "$WORKFLOW_VAR"

      - name: Show job variable
        run: echo "$JOB_VAR"

      - name: Show step variable
        env:
          STEP_VAR: "I am step-level"
        run: echo "$STEP_VAR"

      - name: Show GitHub built-ins
        run: |
          echo "Repo: $GITHUB_REPOSITORY"
          echo "Branch: $GITHUB_REF"
          echo "Commit: $GITHUB_SHA"
          echo "Actor: $GITHUB_ACTOR"
EOF
```

---

# Task 3 — Job Outputs

Create:

```text
.github/workflows/job-outputs.yml
```

Using:

```bash
cat > .github/workflows/job-outputs.yml << 'EOF'
name: Job Outputs Demo

on:
  workflow_dispatch:

jobs:
  generate:
    runs-on: ubuntu-latest

    outputs:
      timestamp: ${{ steps.ts.outputs.time }}
      version: ${{ steps.ver.outputs.version }}

    steps:
      - name: Get timestamp
        id: ts
        run: echo "time=$(date +%Y%m%d-%H%M%S)" >> "$GITHUB_OUTPUT"

      - name: Get version
        id: ver
        run: echo "version=2.1.0" >> "$GITHUB_OUTPUT"

  use-outputs:
    needs: generate
    runs-on: ubuntu-latest

    steps:
      - name: Use the outputs
        run: |
          echo "Timestamp: ${{ needs.generate.outputs.timestamp }}"
          echo "Version: ${{ needs.generate.outputs.version }}"
EOF
```

### Flow

```text
generate
   |
   ├── timestamp
   |
   └── version
        |
        v
use-outputs
```

---

# Task 4 — Conditionals

Create:

```text
.github/workflows/conditionals.yml
```

Using:

```bash
cat > .github/workflows/conditionals.yml << 'EOF'
name: Conditionals Demo

on:
  push:
    branches: [ main, develop ]
  workflow_dispatch:

jobs:
  check-conditions:
    runs-on: ubuntu-latest

    steps:
      - name: Run on main only
        if: github.ref == 'refs/heads/main'
        run: echo "This is the main branch!"

      - name: Run on develop only
        if: github.ref == 'refs/heads/develop'
        run: echo "This is develop branch!"

      - name: Always runs
        run: echo "This always runs"

      - name: Run on manual trigger
        if: github.event_name == 'workflow_dispatch'
        run: echo "Manually triggered!"

      - name: Simulate success check
        run: echo "Step succeeded"

      - name: Run after success
        if: success()
        run: echo "Previous step succeeded, I run!"

      - name: This always runs
        if: always()
        run: echo "I always run no matter what"
EOF
```

---

# Task 5 — Smart Parallel Pipeline

This example demonstrates parallel jobs.

`lint` and `test` run independently, then `deploy` waits for both.

Create:

```text
.github/workflows/smart-pipeline.yml
```

Using:

```bash
cat > .github/workflows/smart-pipeline.yml << 'EOF'
name: Smart Pipeline

on:
  push:
  pull_request:

jobs:
  lint:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Lint check
        run: echo "Linting code..."

  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Run tests
        run: echo "Running tests..."

  deploy:
    needs: [lint, test]
    runs-on: ubuntu-latest

    if: github.ref == 'refs/heads/main'

    steps:
      - name: Deploy
        run: echo "Both lint and test passed, deploying!"
EOF
```

### Flow

```text
          ┌──→ Lint ──┐
Push ─────┤           ├──→ Deploy
          └──→ Test ──┘
```

`lint` and `test` can run in parallel.

`deploy` waits for both.

---

# Practice Commands

## Go to Your Repository

```bash
cd ~/github-actions-practice
```

---

## Add All Day 43 Workflows

```bash
git add .github/workflows/multi-job.yml \
        .github/workflows/env-vars.yml \
        .github/workflows/job-outputs.yml \
        .github/workflows/conditionals.yml \
        .github/workflows/smart-pipeline.yml
```

---

## Commit

```bash
git commit -m "Day 43: jobs, env vars, outputs, conditionals"
```

---

## Push

```bash
git push
```

---

# After Pushing

Go to:

```text
GitHub Repository
      ↓
Actions
```

Then:

### `multi-job.yml`

Watch:

```text
build → test → deploy
```

### `env-vars.yml`

Run manually using:

```text
Run workflow
```

Check the three environment variable levels.

### `job-outputs.yml`

Run manually and check how data moves between jobs.

### `conditionals.yml`

Test different branches/events and observe which steps execute.

### `smart-pipeline.yml`

Observe:

```text
lint ──┐
       ├──→ deploy
test ──┘
```

---

# Key Things to Remember

| Concept | Key Syntax | Purpose |
|---|---|---|
| Sequential jobs | `needs: job_name` | Run jobs in order |
| Multiple dependencies | `needs: [job1, job2]` | Wait for multiple jobs |
| Workflow environment | `env:` at top | Shared across workflow |
| Job environment | `env:` under job | Job-specific variables |
| Step environment | `env:` under step | Step-specific variables |
| Job outputs | `outputs:` + `$GITHUB_OUTPUT` | Pass data between jobs |
| Conditional | `if:` | Skip/run steps or jobs |
| Success check | `if: success()` | Run if previous steps succeeded |
| Failure check | `if: failure()` | Run after failure |
| Always run | `if: always()` | Run regardless of previous result |
| Cancelled check | `if: cancelled()` | Run when workflow is cancelled |

---

# Complete Concept Flow

```text
GitHub Event
     |
     v
Workflow
     |
     v
Jobs
     |
     ├───────────────┐
     |               |
     v               v
   Build           Lint
     |               |
     v               v
   Test             Test
     |               |
     └───────┬───────┘
             |
             v
          Deploy
```

---

# Summary

- Jobs run **in parallel by default**.
- Use `needs:` to create sequential dependencies.
- `needs: build` means the job waits for `build`.
- `needs: [build, test]` means the job waits for both.
- Environment variables can be defined at **workflow, job, or step level**.
- `$GITHUB_*` variables provide information about the current GitHub Actions run.
- `$GITHUB_OUTPUT` allows a step to create outputs.
- Job `outputs:` allows data to be passed between jobs.
- `if:` controls whether a step or job runs.
- `success()` runs after successful previous steps.
- `failure()` runs after a failure.
- `always()` runs regardless of the previous result.
- Matrix and parallel jobs can make CI/CD pipelines faster.

## Final Flow

```text
                    GitHub Event
                         |
                         v
                      Workflow
                         |
              ┌──────────┴──────────┐
              |                     |
              v                     v
             Build                Lint
              |                     |
              v                     v
             Test                  Test
              |                     |
              └──────────┬──────────┘
                         |
                         v
                       Deploy
```

**Day 43 = Jobs + Dependencies + Environment Variables + Outputs + Conditionals**
