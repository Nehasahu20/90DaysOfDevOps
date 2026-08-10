# 🚀 Day 47 — Advanced Triggers

## 📌 All Ways to Trigger a Workflow

GitHub Actions workflows can be triggered by different events.

    on:
      push:                  # Code pushed
      pull_request:          # PR opened/updated
      schedule:              # Cron timer
      workflow_dispatch:     # Manual from UI
      workflow_run:          # After another workflow finishes
      repository_dispatch:   # External HTTP call to GitHub API
      release:               # GitHub release created
      issues:                # Issue opened/closed

Different triggers allow us to build smarter and more automated CI/CD pipelines.

---

# 1️⃣ PR Lifecycle Triggers

A Pull Request can go through different stages during its lifecycle.

You can configure GitHub Actions to react to specific PR events:

    on:
      pull_request:
        types:
          - opened
          - synchronize
          - reopened
          - closed
          - labeled
          - ready_for_review

### Common Pull Request Events

| Event | Meaning |
|---|---|
| `opened` | PR was just created |
| `synchronize` | New commit was pushed to the PR |
| `reopened` | Closed PR was reopened |
| `closed` | PR was closed |
| `labeled` | Label was added to PR |
| `ready_for_review` | Draft PR became ready for review |

---

# 🔍 Check if PR Was Actually Merged

A `closed` event does not necessarily mean the PR was merged.

A PR can be:

    Closed + Merged

or:

    Closed + Not Merged

To check whether it was merged:

    - name: Run only if merged
      if: github.event.pull_request.merged == true
      run: echo "PR was merged!"

---

# 📋 PR Information Available

### PR Title

    ${{ github.event.pull_request.title }}

### PR Number

    ${{ github.event.pull_request.number }}

### PR Author

    ${{ github.event.pull_request.user.login }}

### Target Branch

    ${{ github.event.pull_request.base.ref }}

### Source Branch

    ${{ github.event.pull_request.head.ref }}

Example:

    feature/login
          ↓
    Pull Request
          ↓
        main

---

# 2️⃣ Schedule Triggers — Cron

The `schedule` trigger runs workflows automatically at specific times.

Useful for:

- Nightly tests
- Health checks
- Cleanup jobs
- Reports
- Security scans
- Database maintenance
- Scheduled deployments

Example:

    on:
      schedule:
        - cron: '0 2 * * *'

This runs every day at 2:00 AM UTC.

### Common Examples

    0 2 * * *
    Every day at 2 AM UTC

    0 */6 * * *
    Every 6 hours

    0 9 * * 1
    Every Monday at 9 AM UTC

---

# ⏰ Cron Syntax

Cron has five fields:

    ┌───────────── minute (0-59)
    │ ┌───────────── hour (0-23)
    │ │ ┌───────────── day of month (1-31)
    │ │ │ ┌───────────── month (1-12)
    │ │ │ │ ┌───────────── day of week (0-6, 0=Sunday)
    │ │ │ │ │
    * * * * *

---

# 📚 Common Cron Examples

| Cron | Meaning |
|---|---|
| `0 0 * * *` | Daily at midnight |
| `0 9 * * 1-5` | Weekdays at 9 AM |
| `*/15 * * * *` | Every 15 minutes |
| `0 0 1 * *` | First day of every month |
| `0 */6 * * *` | Every 6 hours |
| `0 2 * * *` | Every day at 2 AM |

> ⚠️ GitHub Actions cron schedules use UTC time.

---

# 3️⃣ Path Filters — Run Only When Specific Files Change

Path filters help save CI/CD resources.

For example, if only documentation changes:

    README.md
    docs/guide.md

there may be no need to run backend tests.

Example:

    on:
      push:
        branches: [ main ]
        paths:
          - 'src/**'
          - 'requirements.txt'
          - '**.py'

---

# 📁 Path Filter Examples

### Any file inside `src/`

    src/**

### Specific file

    requirements.txt

### Any Python file

    **.py

### Python files inside src

    src/**/*.py

### Anything inside tests

    tests/**

### Dockerfile

    Dockerfile

### Any YAML file

    **.yml

---

# 🚫 paths-ignore

You can also ignore specific files or directories:

    on:
      pull_request:
        paths-ignore:
          - 'docs/**'
          - '**.md'

This means the workflow will not run when only documentation or Markdown files change.

---

# 4️⃣ workflow_run — Trigger After Another Workflow

`workflow_run` allows one workflow to start after another workflow completes.

This is useful for chaining CI/CD workflows.

Example:

    Run Tests
        ↓
    workflow_run
        ↓
    Deploy

The second workflow waits for the first workflow to finish.

---

# 🛠️ workflow_run Example

Create:

    .github/workflows/deploy-after-tests.yml

Example:

    name: Deploy After Tests

    on:
      workflow_run:
        workflows: ["Run Tests"]
        types:
          - completed

    jobs:
      deploy:
        runs-on: ubuntu-latest

        if: ${{ github.event.workflow_run.conclusion == 'success' }}

        steps:
          - name: Deploy
            run: echo "Tests passed, deploying!"

The workflow name:

    workflows: ["Run Tests"]

must match the first workflow's `name:` exactly.

---

# 📊 workflow_run Conclusion Values

You can check:

    ${{ github.event.workflow_run.conclusion }}

Common values:

    success
    failure
    cancelled
    timed_out
    skipped

Example:

    if: ${{ github.event.workflow_run.conclusion == 'success' }}

This means deployment runs only when the previous workflow succeeds.

---

# 5️⃣ repository_dispatch — External HTTP Trigger

`repository_dispatch` allows external systems to trigger a GitHub Actions workflow.

Useful when:

- Another server needs to trigger GitHub Actions
- An external CI/CD system sends an event
- A deployment platform sends a webhook
- An external script starts a workflow
- Another application needs to trigger automation

---

# 📡 Workflow That Listens for repository_dispatch

Example:

    on:
      repository_dispatch:
        types:
          - deploy-triggered
          - custom-event

Jobs can access event information:

    jobs:
      handle-dispatch:
        runs-on: ubuntu-latest

        steps:
          - name: Show event data
            run: |
              echo "Event type: ${{ github.event.action }}"
              echo "Payload: ${{ toJson(github.event.client_payload) }}"

---

# 🌐 Trigger repository_dispatch Using curl

An external system can send an HTTP request to GitHub:

    curl -X POST \
      -H "Authorization: token YOUR_GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      https://api.github.com/repos/OWNER/REPO/dispatches \
      -d '{"event_type": "deploy-triggered", "client_payload": {"env": "production"}}'

The important values are:

    event_type

and:

    client_payload

The workflow can access them using:

    github.event.action

and:

    github.event.client_payload

> ⚠️ Never commit a real GitHub token into your repository or workflow file.

---

# 6️⃣ Branch Filters

You can combine branch filters with paths and events.

Example:

    on:
      push:
        branches:
          - main
          - 'release/**'
          - 'feature/*'

This allows workflows to run for:

    main
    release/v1.0
    release/v2.0
    feature/login

---

# 🚫 branches-ignore

You can exclude branches:

    branches-ignore:
      - 'wip/**'

This skips work-in-progress branches.

---

# 🔀 Combining Branch + Path Filters

You can combine branch and path filters:

    on:
      push:
        branches:
          - main
          - 'release/**'

        paths:
          - 'src/**'

This means the workflow runs when:

1. Code is pushed to `main` or `release/**`
2. A file inside `src/` changed

---

# 🧠 Trigger Combination Example

    on:
      push:
        branches:
          - main
          - 'release/**'

        paths:
          - 'src/**'
          - 'Dockerfile'

Flow:

    Push
      ↓
    Correct Branch?
      ↓
    Correct Files Changed?
      ↓
    Run Workflow

---

# 🧪 Practice Files Created

## Task 1: PR Lifecycle

Create:

    .github/workflows/pr-lifecycle.yml

Command:

    cat > .github/workflows/pr-lifecycle.yml << 'EOF'
    name: PR Lifecycle

    on:
      pull_request:
        types: [opened, synchronize, closed]

    jobs:
      pr-event:
        runs-on: ubuntu-latest

        steps:
          - name: PR opened
            if: github.event.action == 'opened'
            run: echo "New PR #${{ github.event.pull_request.number }} opened by ${{ github.event.pull_request.user.login }}"

          - name: PR updated
            if: github.event.action == 'synchronize'
            run: echo "PR #${{ github.event.pull_request.number }} was updated"

          - name: PR merged
            if: github.event.action == 'closed' && github.event.pull_request.merged == true
            run: echo "PR #${{ github.event.pull_request.number }} was MERGED!"

          - name: PR closed without merge
            if: github.event.action == 'closed' && github.event.pull_request.merged == false
            run: echo "PR #${{ github.event.pull_request.number }} was closed (not merged)"
    EOF

---

# Task 2: PR Validation Checks

Create:

    .github/workflows/pr-checks.yml

Command:

    cat > .github/workflows/pr-checks.yml << 'EOF'
    name: PR Validation

    on:
      pull_request:
        types: [opened, synchronize]

    jobs:
      validate:
        runs-on: ubuntu-latest

        steps:
          - uses: actions/checkout@v4

          - name: Check PR title
            run: |
              TITLE="${{ github.event.pull_request.title }}"
              echo "PR Title: $TITLE"

              if [[ ${#TITLE} -lt 10 ]]; then
                echo "ERROR: PR title is too short (min 10 chars)"
                exit 1
              fi

              echo "PR title length is OK"

          - name: Run quick tests
            run: bash scripts/test.sh
    EOF

---

# Task 3: Scheduled Tasks

Create:

    .github/workflows/scheduled-tasks.yml

Command:

    cat > .github/workflows/scheduled-tasks.yml << 'EOF'
    name: Scheduled Maintenance

    on:
      schedule:
        - cron: '0 2 * * *'
        - cron: '0 9 * * 1'

      workflow_dispatch:

    jobs:
      daily-health-check:
        runs-on: ubuntu-latest

        steps:
          - uses: actions/checkout@v4

          - name: Health check
            run: |
              echo "Running daily health check at $(date)"
              bash scripts/test.sh

          - name: Report
            run: echo "Health check completed successfully"
    EOF

---

# Task 4: Smart Triggers with Path Filters

Create:

    .github/workflows/smart-triggers.yml

Command:

    cat > .github/workflows/smart-triggers.yml << 'EOF'
    name: Smart Path Triggers

    on:
      push:
        branches: [ main ]
        paths:
          - '**.py'
          - 'Dockerfile'
          - 'requirements.txt'

    jobs:
      python-changed:
        runs-on: ubuntu-latest

        steps:
          - uses: actions/checkout@v4

          - name: Python files changed
            run: |
              echo "Python or Docker files changed — running CI"
              bash scripts/test.sh
    EOF

---

# Task 5: workflow_run — Tests → Deploy Chain

## First Workflow — Tests

Create:

    .github/workflows/tests.yml

Command:

    cat > .github/workflows/tests.yml << 'EOF'
    name: Run Tests

    on:
      push:
        branches: [ main ]

    jobs:
      test:
        runs-on: ubuntu-latest

        steps:
          - uses: actions/checkout@v4
          - run: bash scripts/test.sh
    EOF

---

## Second Workflow — Deploy After Tests

Create:

    .github/workflows/deploy-after-tests.yml

Command:

    cat > .github/workflows/deploy-after-tests.yml << 'EOF'
    name: Deploy After Tests

    on:
      workflow_run:
        workflows: ["Run Tests"]
        types: [completed]

    jobs:
      deploy:
        runs-on: ubuntu-latest

        if: ${{ github.event.workflow_run.conclusion == 'success' }}

        steps:
          - name: Deploy
            run: echo "Tests passed! Deploying application..."
    EOF

---

# 🔄 Tests → Deploy Flow

    Code Push
        ↓
    Run Tests
        ↓
    Tests Pass?
       / \
     Yes  No
      ↓    ↓
    Deploy  Stop

---

# Task 6: External Trigger — repository_dispatch

Create:

    .github/workflows/external-trigger.yml

Command:

    cat > .github/workflows/external-trigger.yml << 'EOF'
    name: External Trigger

    on:
      repository_dispatch:
        types: [deploy-request]

    jobs:
      handle-dispatch:
        runs-on: ubuntu-latest

        steps:
          - name: Show dispatch info
            run: |
              echo "Triggered externally!"
              echo "Event: ${{ github.event.action }}"
              echo "Environment: ${{ github.event.client_payload.environment }}"

          - name: Deploy
            run: echo "Deploying to ${{ github.event.client_payload.environment }}"
    EOF

---

# 📁 Final Project Structure

After completing Day 47:

    github-actions-practice/
    │
    ├── app.py
    ├── Dockerfile
    ├── requirements.txt
    │
    └── .github/
        │
        ├── workflows/
        │   ├── reusable-build.yml
        │   ├── call-build.yml
        │   ├── use-composite.yml
        │   ├── pr-lifecycle.yml
        │   ├── pr-checks.yml
        │   ├── scheduled-tasks.yml
        │   ├── smart-triggers.yml
        │   ├── tests.yml
        │   ├── deploy-after-tests.yml
        │   └── external-trigger.yml
        │
        └── actions/
            └── setup-and-greet/
                └── action.yml

---

# 💻 Practice Commands

Go to the project:

    cd ~/github-actions-practice

Add Day 47 files:

    git add \
    .github/workflows/pr-lifecycle.yml \
    .github/workflows/pr-checks.yml \
    .github/workflows/scheduled-tasks.yml \
    .github/workflows/smart-triggers.yml \
    .github/workflows/tests.yml \
    .github/workflows/deploy-after-tests.yml \
    .github/workflows/external-trigger.yml

Commit:

    git commit -m "Day 47: advanced triggers"

Push:

    git push

---

# 🌐 Test repository_dispatch Manually

Replace:

    YOUR_TOKEN

with your GitHub token.

Replace:

    YOUR_USERNAME

with your GitHub username.

Replace:

    github-actions-practice

with your repository name.

Command:

    curl -X POST \
      -H "Authorization: token YOUR_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      https://api.github.com/repos/YOUR_USERNAME/github-actions-practice/dispatches \
      -d '{"event_type": "deploy-request", "client_payload": {"environment": "staging"}}'

The workflow receives:

    Event:
    deploy-request

and:

    Environment:
    staging

---

# 🔐 Security Note

Never hard-code a real GitHub token.

Bad:

    curl -H "Authorization: token ghp_xxxxxxxxx"

Use secure storage such as:

- GitHub Secrets
- Environment variables
- Secure secret managers

Never commit tokens into Git.

---

# 🧠 Advanced Trigger Flow

    Code Push
        ↓
      push

    Pull Request
        ↓
    pull_request

    Scheduled Time
        ↓
    schedule

    Manual Button
        ↓
    workflow_dispatch

    Another Workflow
        ↓
    workflow_run

    External System
        ↓
    repository_dispatch

---

# 📚 Trigger Comparison

| Trigger | Use Case |
|---|---|
| `push` | Run workflow when code is pushed |
| `pull_request` | Run CI when PR events occur |
| `schedule` | Run jobs at scheduled times |
| `workflow_dispatch` | Manually run workflow from GitHub UI |
| `workflow_run` | Chain one workflow after another |
| `repository_dispatch` | Trigger workflow from external systems |
| `release` | Run workflow when a release event occurs |
| `issues` | React to issue events |

---

# 🎯 Important Trigger Concepts

## push

Used when code is pushed:

    on:
      push:
        branches: [ main ]

## pull_request

Used for Pull Request events:

    on:
      pull_request:
        types: [opened, synchronize, closed]

## schedule

Used for scheduled automation:

    on:
      schedule:
        - cron: '0 2 * * *'

## workflow_dispatch

Used to manually run a workflow from GitHub Actions UI:

    on:
      workflow_dispatch:

## workflow_run

Used to trigger a workflow after another workflow finishes:

    on:
      workflow_run:
        workflows: ["Run Tests"]
        types: [completed]

## repository_dispatch

Used to trigger a workflow externally:

    on:
      repository_dispatch:
        types: [deploy-request]

---

# 🧩 Path Filters

Run only when specific files change:

    on:
      push:
        paths:
          - 'src/**'
          - 'Dockerfile'
          - 'requirements.txt'

Ignore specific paths:

    on:
      pull_request:
        paths-ignore:
          - 'docs/**'
          - '**.md'

---

# 🌿 Branch Filters

Run only on selected branches:

    on:
      push:
        branches:
          - main
          - 'release/**'
          - 'feature/*'

Ignore branches:

    on:
      push:
        branches-ignore:
          - 'wip/**'

---

# 🧠 Simple Way to Remember

    push
      =
    Code Changed

    pull_request
      =
    PR Activity

    schedule
      =
    Time Based

    workflow_dispatch
      =
    Manual

    workflow_run
      =
    Workflow Chain

    repository_dispatch
      =
    External Trigger

    paths
      =
    Specific Files

    branches
      =
    Specific Branches

---

# 📊 Day 47 Summary

Advanced triggers allow GitHub Actions to run exactly when needed.

### Pull Request Triggers

Use:

    pull_request:
      types:

to react to:

- opened
- synchronize
- reopened
- closed
- labeled
- ready_for_review

### Schedule

Use:

    schedule:
      - cron:

for:

- Nightly tests
- Health checks
- Maintenance
- Reports
- Security scans

### Path Filters

Use:

    paths:

to run workflows only when specific files change.

Use:

    paths-ignore:

to ignore specific file changes.

### workflow_run

Use:

    workflow_run:

to chain workflows together.

Example:

    Tests
      ↓
    Deploy

### repository_dispatch

Use:

    repository_dispatch:

to trigger GitHub Actions from external systems.

### Branch Filters

Use:

    branches:

to control which branches trigger workflows.

Use:

    branches-ignore:

to exclude branches.

---

# 🔥 Real-World CI/CD Example

A production-style GitHub Actions setup could look like:

    Developer Push
          ↓
    Pull Request
          ↓
    PR Validation
          ↓
    Tests
          ↓
    Merge to Main
          ↓
    Build Docker Image
          ↓
    Push Docker Image
          ↓
    Deploy
          ↓
    Scheduled Health Check

Workflows can be connected using:

    pull_request
         ↓
       push
         ↓
    workflow_run
         ↓
      deploy

---

# 🧠 Final Revision

                         GitHub Actions Triggers
                                  │
             ┌────────────────────┼────────────────────┐
             │                    │                    │
             ↓                    ↓                    ↓
            push             pull_request          schedule
             │                    │                    │
             ↓                    ↓                    ↓
          Code Push           PR Events           Timer
                                  │
                                  ↓
                         workflow_dispatch
                                  │
                                  ↓
                               Manual
                                  │
                                  ↓
                           workflow_run
                                  │
                                  ↓
                         Workflow Chain
                                  │
                                  ↓
                      repository_dispatch
                                  │
                                  ↓
                         External Systems

---

# 🎯 Day 47 Complete

> **Advanced Triggers = Smarter CI/CD Automation 🚀**

> **`push` = Code changes**

> **`pull_request` = PR lifecycle**

> **`schedule` = Cron-based automation**

> **`workflow_dispatch` = Manual execution**

> **`workflow_run` = Workflow chaining**

> **`repository_dispatch` = External trigger**

> **`paths` = Run only for specific file changes**

> **`branches` = Run only for specific branches**

> **Advanced triggers help reduce unnecessary CI/CD runs and make automation more efficient, predictable, and production-ready.**
