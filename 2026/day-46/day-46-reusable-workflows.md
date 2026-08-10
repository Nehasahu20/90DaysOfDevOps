# 🚀 Day 46 — Reusable Workflows & Composite Actions

## 📌 The Problem: DRY in CI/CD

Without reusability, you may copy the same build steps across multiple repositories.

For example:

    Repository 1 → Build Steps
    Repository 2 → Build Steps
    Repository 3 → Build Steps
    Repository 4 → Build Steps
    Repository 5 → Build Steps

If you need to change one step, you have to update all 5 workflow files.

This violates the **DRY principle**:

> **DRY = Don't Repeat Yourself**

### 💡 Solution

GitHub Actions provides two powerful ways to reuse CI/CD logic:

1. **Reusable Workflows**
2. **Composite Actions**

---

# 🔄 Reusable Workflows

A **reusable workflow** is a complete GitHub Actions workflow that another workflow can call, similar to calling a function.

### Basic Concept

    caller-workflow.yml
            │
            │ calls
            ↓
    reusable-build.yml
            │
            ↓
        Build Steps

---

# 🛠️ Create a Reusable Workflow

Create:

    .github/workflows/reusable-build.yml

Example:

    name: Reusable Build

    on:
      workflow_call:

        inputs:
          app_name:
            required: true
            type: string

          environment:
            required: false
            type: string
            default: staging

        secrets:
          DOCKER_TOKEN:
            required: true

        outputs:
          image_tag:
            description: "The Docker image tag"
            value: ${{ jobs.build.outputs.tag }}

    jobs:
      build:
        runs-on: ubuntu-latest

        outputs:
          tag: ${{ steps.build.outputs.tag }}

        steps:
          - uses: actions/checkout@v4

          - name: Build
            id: build
            run: |
              TAG="${{ inputs.app_name }}-${{ github.sha }}"

              echo "Building ${{ inputs.app_name }} for ${{ inputs.environment }}"

              echo "tag=$TAG" >> $GITHUB_OUTPUT

---

# 🔑 workflow_call

The key that makes a workflow reusable is:

    on:
      workflow_call:

This means the workflow can be called by another workflow.

A reusable workflow can define:

- `inputs`
- `secrets`
- `outputs`

---

# 📥 Inputs

Inputs allow the calling workflow to send parameters to the reusable workflow.

Example:

    inputs:
      my_param:
        type: string
        required: true
        description: "What this parameter does"

Supported input types include:

    string
    boolean
    number

You can also provide a default value:

    inputs:
      environment:
        type: string
        required: false
        default: staging

---

# 🔐 Secrets

Reusable workflows can receive secrets from the calling workflow.

Example:

    secrets:
      MY_SECRET:
        required: false

Inside the reusable workflow:

    - run: echo "${{ secrets.MY_SECRET }}"

> ⚠️ Never print real passwords, tokens, or sensitive credentials in GitHub Actions logs.

---

# 📤 Outputs

Reusable workflows can return values to the calling workflow.

Example:

    outputs:
      image_tag:
        description: "The Docker image tag"
        value: ${{ jobs.build.outputs.tag }}

The job must expose the output:

    jobs:
      build:
        outputs:
          tag: ${{ steps.build.outputs.tag }}

And the step generates the value:

    - name: Build
      id: build
      run: |
        TAG="${{ inputs.app_name }}-${{ github.sha }}"
        echo "tag=$TAG" >> $GITHUB_OUTPUT

### Output Flow

    Step Output
         ↓
    Job Output
         ↓
    Workflow Output
         ↓
    Calling Workflow

---

# 📞 Call the Reusable Workflow

Create:

    .github/workflows/call-build.yml

Example:

    name: Deploy My App

    on:
      push:
        branches: [ main ]

    jobs:
      build-app:
        uses: ./.github/workflows/reusable-build.yml

        with:
          app_name: my-app
          environment: production

        secrets:
          DOCKER_TOKEN: ${{ secrets.DOCKERHUB_TOKEN }}

      deploy:
        needs: build-app
        runs-on: ubuntu-latest

        steps:
          - name: Deploy
            run: echo "Deploying tag: ${{ needs.build-app.outputs.image_tag }}"

---

# 🔄 Reusable Workflow Flow

    call-build.yml
          ↓
    calls reusable-build.yml
          ↓
    Receives Inputs
          ↓
    Uses Secrets
          ↓
    Runs Build
          ↓
    Creates Output
          ↓
    Returns Output
          ↓
    call-build.yml
          ↓
    Deploy

---

# 📚 Access Inputs and Secrets

Inside the reusable workflow:

### Access Input

    - run: echo "${{ inputs.my_param }}"

### Access Secret

    - run: echo "${{ secrets.MY_SECRET }}"

### Access Output from Calling Workflow

    ${{ needs.build-app.outputs.image_tag }}

---

# 🧩 Composite Actions

A **composite action** bundles multiple GitHub Actions steps into one reusable action.

Instead of repeating the same steps:

    Setup Python
        ↓
    Print Greeting
        ↓
    Show Python Version
        ↓
    Show Python Path

You can bundle them into a single action.

### Composite Action Location

Composite actions are stored inside:

    .github/actions/NAME/action.yml

Example:

    .github/actions/setup-and-greet/action.yml

---

# 🛠️ Create a Composite Action

Create:

    .github/actions/setup-and-greet/action.yml

Example:

    name: Setup and Greet

    description: Sets up Python and greets the user

    inputs:
      python-version:
        description: Python version to use
        required: false
        default: '3.11'

      greeting:
        description: Greeting message
        required: true

    outputs:
      setup-time:
        description: When setup completed
        value: ${{ steps.time.outputs.time }}

    runs:
      using: composite

      steps:
        - name: Setup Python
          uses: actions/setup-python@v5
          with:
            python-version: ${{ inputs.python-version }}

        - name: Greet
          shell: bash
          run: echo "${{ inputs.greeting }}"

        - name: Record time
          id: time
          shell: bash
          run: echo "time=$(date)" >> $GITHUB_OUTPUT

---

# 🔍 Understanding Composite Actions

A composite action contains multiple steps:

    runs:
      using: composite
      steps:

Each step can:

- Run shell commands
- Use other GitHub Actions
- Access inputs
- Generate outputs

---

# ▶️ Use Composite Action in a Workflow

Example:

    jobs:
      my-job:
        runs-on: ubuntu-latest

        steps:
          - uses: actions/checkout@v4

          - name: Run my custom action
            uses: ./.github/actions/setup-and-greet
            id: setup

            with:
              python-version: '3.11'
              greeting: 'Hello from composite action!'

          - name: Use the output
            run: echo "Setup done at: ${{ steps.setup.outputs.setup-time }}"

---

# 🔄 Composite Action Flow

    Workflow
        ↓
    uses: ./.github/actions/setup-and-greet
        ↓
    Composite Action
        ↓
    Setup Python
        ↓
    Greet
        ↓
    Record Time
        ↓
    Return Output

---

# ⚖️ Reusable Workflow vs Composite Action

| Feature | Reusable Workflow | Composite Action |
|---|---|---|
| What it is | Full workflow with jobs | Group of reusable steps |
| Location | `.github/workflows/` | `.github/actions/NAME/` |
| Trigger | `workflow_call` | `uses:` inside a step |
| Can have jobs | ✅ Yes | ❌ No |
| Can use secrets | ✅ Yes, explicitly passed | ⚠️ No direct workflow-secret interface |
| Can contain multiple steps | ✅ Yes | ✅ Yes |
| Best for | Full CI/CD pipelines | Grouped setup/repeated steps |

---

# 🎯 When to Use What?

## Use Reusable Workflows When

You want to reuse an entire CI/CD pipeline.

Example:

    Build
        ↓
    Test
        ↓
    Docker Build
        ↓
    Security Scan
        ↓
    Push
        ↓
    Deploy

A reusable workflow is ideal for this.

---

## Use Composite Actions When

You want to reuse a group of steps.

Example:

    Setup Python
        ↓
    Install Dependencies
        ↓
    Run Common Setup

A composite action is ideal for this.

---

# 🧪 Practice Project

## Task 1: Project Directory

Go to the project:

    cd ~/github-actions-practice

---

# Task 2: Reusable Build Workflow

Create the workflows directory:

    mkdir -p .github/workflows

Create:

    .github/workflows/reusable-build.yml

Using:

    cat > .github/workflows/reusable-build.yml << 'EOF'
    name: Reusable Build Workflow

    on:
      workflow_call:

        inputs:
          app_name:
            required: true
            type: string

          python_version:
            required: false
            type: string
            default: '3.11'

        outputs:
          build_tag:
            description: "Build tag created"
            value: ${{ jobs.build.outputs.tag }}

    jobs:

      build:
        runs-on: ubuntu-latest

        outputs:
          tag: ${{ steps.tag.outputs.value }}

        steps:

          - uses: actions/checkout@v4

          - uses: actions/setup-python@v5
            with:
              python-version: ${{ inputs.python_version }}

          - name: Install deps
            run: |
              if [ -f requirements.txt ]; then
                pip install -r requirements.txt
              fi

          - name: Generate tag
            id: tag
            run: |
              echo "value=${{ inputs.app_name }}-${{ github.run_number }}" >> $GITHUB_OUTPUT

          - name: Build summary
            run: |
              echo "Built ${{ inputs.app_name }}, tag=${{ steps.tag.outputs.value }}"
    EOF

---

# Task 3: Caller Workflow

Create:

    .github/workflows/call-build.yml

Using:

    cat > .github/workflows/call-build.yml << 'EOF'
    name: Call Reusable Build

    on:
      push:
        branches: [ main ]

      workflow_dispatch:

    jobs:

      build-my-app:
        uses: ./.github/workflows/reusable-build.yml

        with:
          app_name: my-python-app
          python_version: '3.11'

      use-results:
        needs: build-my-app
        runs-on: ubuntu-latest

        steps:
          - name: Show build tag
            run: echo "Build tag was: ${{ needs.build-my-app.outputs.build_tag }}"
    EOF

---

# Task 4: Understand the Caller Workflow

The caller workflow:

    call-build.yml

calls:

    reusable-build.yml

using:

    jobs:
      build-my-app:
        uses: ./.github/workflows/reusable-build.yml

It passes inputs:

    with:
      app_name: my-python-app
      python_version: '3.11'

Then another job receives the output:

    needs.build-my-app.outputs.build_tag

---

# Task 5: Create Composite Action

Create the directory:

    mkdir -p .github/actions/setup-and-greet

Create:

    .github/actions/setup-and-greet/action.yml

Using:

    cat > .github/actions/setup-and-greet/action.yml << 'EOF'
    name: Setup and Greet

    description: Sets up the environment and greets

    inputs:
      python-version:
        description: Python version
        required: false
        default: '3.11'

      greeting:
        description: Custom greeting
        required: false
        default: 'Hello from composite action!'

    outputs:
      python-path:
        description: Path to Python binary
        value: ${{ steps.show-python.outputs.path }}

    runs:
      using: composite

      steps:

        - name: Setup Python
          uses: actions/setup-python@v5
          with:
            python-version: ${{ inputs.python-version }}

        - name: Greet
          shell: bash
          run: echo "${{ inputs.greeting }}"

        - name: Show Python info
          id: show-python
          shell: bash
          run: |
            echo "Python version: $(python --version)"
            echo "path=$(which python)" >> $GITHUB_OUTPUT
    EOF

---

# Task 6: Workflow That Uses the Composite Action

Create:

    .github/workflows/use-composite.yml

Using:

    cat > .github/workflows/use-composite.yml << 'EOF'
    name: Use Composite Action

    on:
      workflow_dispatch:

    jobs:

      test-composite:
        runs-on: ubuntu-latest

        steps:

          - uses: actions/checkout@v4

          - name: Run composite action
            id: setup
            uses: ./.github/actions/setup-and-greet

            with:
              python-version: '3.11'
              greeting: 'Hello World from my custom action!'

          - name: Use output
            run: echo "Python at: ${{ steps.setup.outputs.python-path }}"
    EOF

---

# 📁 Final Project Structure

After completing the practice, your project should look like:

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
        │   └── use-composite.yml
        │
        └── actions/
            └── setup-and-greet/
                └── action.yml

---

# 💻 Practice Commands

Go to the project:

    cd ~/github-actions-practice

Create composite action directory:

    mkdir -p .github/actions/setup-and-greet

Add all files:

    git add \
    .github/workflows/reusable-build.yml \
    .github/workflows/call-build.yml \
    .github/actions/setup-and-greet/action.yml \
    .github/workflows/use-composite.yml

Commit:

    git commit -m "Day 46: reusable workflows and composite actions"

Push:

    git push

---

# 🚀 After Push

After pushing the files to GitHub:

### 1. Trigger `call-build.yml`

You can trigger it through a push to `main` or manually using `workflow_dispatch`.

### 2. Check the Reusable Workflow

See how:

    call-build.yml
           ↓
    reusable-build.yml

### 3. Check Outputs

Verify that the build tag is passed from the reusable workflow:

    reusable-build.yml
           ↓
       build_tag
           ↓
    call-build.yml

### 4. Trigger `use-composite.yml`

Run the workflow manually and verify that the composite action:

    Setup Python
        ↓
    Greeting
        ↓
    Python Information
        ↓
    Output

works correctly.

---

# 🔍 Reusable Workflow Example

    Caller Workflow
          │
          │ uses
          ↓
    Reusable Workflow
          │
          ├── Job 1
          ├── Job 2
          ├── Job 3
          └── Job 4

A reusable workflow can contain multiple jobs.

---

# 🔍 Composite Action Example

    Workflow Job
          │
          │ uses
          ↓
    Composite Action
          │
          ├── Step 1
          ├── Step 2
          ├── Step 3
          └── Step 4

A composite action is a collection of steps used inside a job.

---

# ⭐ Important Syntax

## Reusable Workflow

    on:
      workflow_call:

## Reusable Workflow Inputs

    inputs:
      app_name:
        required: true
        type: string

## Reusable Workflow Secrets

    secrets:
      DOCKER_TOKEN:
        required: true

## Reusable Workflow Outputs

    outputs:
      build_tag:
        description: "Build tag created"
        value: ${{ jobs.build.outputs.tag }}

## Call Reusable Workflow

    jobs:
      build:
        uses: ./.github/workflows/reusable-build.yml

## Pass Inputs

    with:
      app_name: my-python-app

## Pass Secrets

    secrets:
      DOCKER_TOKEN: ${{ secrets.DOCKERHUB_TOKEN }}

## Get Workflow Output

    ${{ needs.build.outputs.build_tag }}

---

# ⭐ Composite Action Syntax

## Location

    .github/actions/NAME/action.yml

## Define Composite Action

    runs:
      using: composite

## Use Composite Action

    uses: ./.github/actions/setup-and-greet

## Pass Input

    with:
      python-version: '3.11'

## Get Composite Action Output

    ${{ steps.setup.outputs.python-path }}

---

# ⚖️ Reusable Workflow vs Composite Action — Quick Revision

| Feature | Reusable Workflow | Composite Action |
|---|---|---|
| Purpose | Reuse complete workflows | Reuse multiple steps |
| Main Level | Workflow | Job step |
| Location | `.github/workflows/` | `.github/actions/NAME/` |
| Trigger | `workflow_call` | `uses:` |
| Multiple Jobs | ✅ Yes | ❌ No |
| Inputs | ✅ Yes | ✅ Yes |
| Outputs | ✅ Yes | ✅ Yes |
| Secrets | ✅ Can explicitly receive secrets | ❌ No direct workflow-secret interface |
| Best Use | Full CI/CD pipelines | Common setup/task steps |

---

# 🎯 Simple Way to Remember

    Reusable Workflow
            =
    Reusable Pipeline

    Composite Action
            =
    Reusable Steps

### Example

If you want to reuse:

    Build
        ↓
    Test
        ↓
    Docker Build
        ↓
    Security Scan
        ↓
    Push
        ↓
    Deploy

Use a:

**Reusable Workflow**

If you want to reuse:

    Setup Python
        ↓
    Install Dependencies
        ↓
    Print Version

Use a:

**Composite Action**

---

# 📚 Day 46 Summary

Reusable workflows and composite actions help keep GitHub Actions workflows clean, maintainable, and DRY.

## Reusable Workflows

- Reuse entire GitHub Actions workflows.
- Use `on: workflow_call`.
- Can contain multiple jobs.
- Accept inputs.
- Can receive secrets explicitly.
- Can return outputs.
- Best for complete CI/CD pipelines.

## Composite Actions

- Bundle multiple workflow steps into one reusable action.
- Live inside `.github/actions/NAME/action.yml`.
- Use `runs: using: composite`.
- Can accept inputs.
- Can produce outputs.
- Best for common setup and repeated steps.

### Key Concepts

    Reusable Workflow
            ↓
    Entire CI/CD Pipeline
            ↓
    Can contain multiple jobs

    Composite Action
            ↓
    Group of Reusable Steps
            ↓
    Used inside a Job

---

# 🧠 Final Revision

                         GitHub Actions
                                │
                 ┌──────────────┴──────────────┐
                 │                             │
                 ↓                             ↓
        Reusable Workflow             Composite Action
                 │                             │
                 ↓                             ↓
          Full Workflow                 Group of Steps
                 │                             │
                 ↓                             ↓
          Multiple Jobs                  One Job Step
                 │                             │
                 ↓                             ↓
          workflow_call                       uses

### Remember:

> **Reusable Workflows = Entire workflows you can call like functions.**

> **`on: workflow_call` = Makes a workflow reusable.**

> **Inputs = Pass data into a reusable workflow.**

> **Secrets = Pass sensitive values into a reusable workflow.**

> **Outputs = Return data from a reusable workflow.**

> **Composite Actions = Bundle multiple steps into one reusable action.**

> **Composite Actions live in `.github/actions/NAME/action.yml`.**

> **Reusable Workflows are best for full CI/CD pipelines.**

> **Composite Actions are best for grouped setup or repeated steps.**

---

# 🎯 Day 46 Complete

> **Reusable Workflows = Reusable Pipelines 🔄**
>
> **Composite Actions = Reusable Steps 🧩**
>
> **DRY CI/CD = Less Duplication + Easier Maintenance + Consistent Automation**
