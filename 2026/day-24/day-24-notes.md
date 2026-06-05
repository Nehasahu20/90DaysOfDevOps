## Day 24 — Advanced Git: Merge, Rebase, Stash, Cherry-pick

### Git Merge

```bash
# Fast-forward merge
git checkout -b feature-login
echo "login" >> git-commands.md
git add . && git commit -m "add login"
git switch main
git merge feature-login
git log --oneline --graph --all
# Straight line = fast-forward (no merge commit)

# Merge commit (both branches have commits)
git checkout -b feature-signup
echo "signup" >> git-commands.md
git add . && git commit -m "signup"
git switch main
echo "main update" >> git-commands.md
git add . && git commit -m "update main"
git merge feature-signup
git log --oneline --graph --all
# Shows branch lines + merge commit

# Intentional merge conflict
git checkout -b conflict-branch
echo "line from feature" > conflict.txt
git add . && git commit -m "feature line"
git switch main
echo "line from main" > conflict.txt
git add . && git commit -m "main line"
git merge conflict-branch
# CONFLICT! Edit conflict.txt manually then:
git add conflict.txt
git commit -m "resolve conflict"
```

### Git Rebase

```bash
git checkout -b feature-dashboard
echo "dashboard v1" >> git-commands.md && git add . && git commit -m "dashboard 1"
echo "dashboard v2" >> git-commands.md && git add . && git commit -m "dashboard 2"

git switch main
echo "hotfix" >> git-commands.md && git add . && git commit -m "hotfix on main"

# Rebase — replays feature commits on top of main
git switch feature-dashboard
git rebase main
git log --oneline --graph --all
# Linear history — no merge commit!
```

| | Merge | Rebase |
|--|---|---|
| History | Branch + merge commit | Linear, clean |
| Safe to share? | Yes | Never rebase pushed commits |

### Git Stash

```bash
# Make changes but don't commit
echo "work in progress" >> git-commands.md

# Save work temporarily
git stash push -m "wip: adding commands"

# Switch branch freely
git switch feature-login

# Come back and restore
git switch main
git stash pop

# Multiple stashes
git stash list
git stash apply stash@{0}   # apply but keep in list
git stash pop               # apply and remove from list
```

### Cherry-pick

```bash
git checkout -b feature-hotfix
echo "fix A" >> git-commands.md && git add . && git commit -m "hotfix A"
echo "fix B" >> git-commands.md && git add . && git commit -m "hotfix B"
echo "fix C" >> git-commands.md && git add . && git commit -m "hotfix C"

git log --oneline
# copy hash of commit B

git switch main
git cherry-pick <HASH_OF_B>
git log --oneline
# Only hotfix B applied to main!
```
