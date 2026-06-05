---

## Day 23 — Git Branching & GitHub

### 

# PRATICE COMMAND
```bash
# List all branches
git branch
# Output: * main

# Create new branch
git branch feature-1

# Switch to branch
git switch feature-1
# Output: Switched to branch 'feature-1'

# Create + switch in one command
git checkout -b feature-2

# Make commit on feature-1
echo "feature work" >> git-commands.md
git add git-commands.md
git commit -m "add feature-1 changes"

# Switch to main — feature-1 commit NOT here
git switch main
git log --oneline

# Delete branch
git branch -d feature-2
```

### Push to GitHub

```bash
# Connect local repo to GitHub
git remote add origin https://github.com/YOUR_USERNAME/devops-git-practice.git
git remote -v

# Push main branch
git push -u origin main

# Push feature-1 branch
git push -u origin feature-1

# Pull changes from GitHub
git pull origin main

# Clone a repo
git clone https://github.com/Nehasahu20/90DaysOfDevOps.git

# Fork sync
git remote add upstream https://github.com/Nehasahu20/90DaysOfDevOps.git
git fetch upstream
git merge upstream/main
```

### Clone vs Fork
| | Clone | Fork |
|---|---|---|
| What | Local copy | GitHub copy |
| When | Use code | Contribute |

### origin vs upstream
- origin = your repo on GitHub
- upstream = original repo you forked from

---
