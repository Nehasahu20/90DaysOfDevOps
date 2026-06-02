## Day 22 — Introduction to Git

### What You Learn
- Install and configure Git
- Create a repo, stage files, commit changes
- Build a commit history

---

### Task 1 — Install & Configure

```bash
git --version
git config --global user.name "Neha Sahu"
git config --global user.email "neha@example.com"
git config --list
```

---

### Task 2 — Create Repo

```bash
mkdir devops-git-practice
cd devops-git-practice
git init              # creates .git/ folder
git status            # check current state
ls -la .git/          # explore hidden folder
```

**.git/ folder contains:**

| File/Folder | Purpose |
|-------------|---------|
| `HEAD` | points to current branch |
| `config` | repo-level git config |
| `objects/` | all file content + history |
| `refs/` | branch and tag pointers |
| `hooks/` | scripts that run on git events |

---

### Task 3 — Create & Track File

```bash
touch git-commands.md         # create file
git status                    # shows: untracked file
git add git-commands.md       # stage file
git status                    # shows: changes to be committed
```

---

### Task 4 — Commit

```bash
git commit -m "add git commands reference"
git log                       # full history
git log --oneline             # compact history
```

---

### Task 5 — Build Commit History

```bash
echo "new command" >> git-commands.md
git diff                      # see what changed
git add git-commands.md
git commit -m "add branching commands"

# Repeat 3+ times for history
git log --oneline
```

---

### Task 6 — Git Concepts (Q&A)

| Question | Answer |
|----------|--------|
| `git add` vs `git commit` | `add` stages changes, `commit` saves them permanently |
| What is staging area? | Middle step — choose exactly what goes into a commit |
| What does `git log` show? | Commit hash, author, date, message |
| What is `.git/` folder? | Contains all history — delete it and repo is gone |
| Working dir vs staging vs repo | Edit → Stage (add) → Save (commit) |

---

### Essential Git Commands

```bash
git init                        # initialize new repo
git status                      # check current state
git add <file>                  # stage a file
git add .                       # stage all files
git commit -m "message"         # save staged changes
git log                         # view full history
git log --oneline               # compact history
git diff                        # see unstaged changes
git diff --staged               # see staged changes
git config --global user.name   # set name
git config --list               # view all config
```

---

### Day 22 — Key Learnings

1. `git init` creates a `.git/` folder — this IS the repository
2. Three areas: **Working Directory** → `git add` → **Staging** → `git commit` → **Repository**
3. `git status` is your best friend — read it carefully every time
4. Each commit needs a clear, descriptive message

---
