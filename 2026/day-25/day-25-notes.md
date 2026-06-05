## Day 25 — Git Reset vs Revert & Branching Strategies

### Git Reset

```bash
# Make 3 commits
echo "A" >> git-commands.md && git add . && git commit -m "commit A"
echo "B" >> git-commands.md && git add . && git commit -m "commit B"
echo "C" >> git-commands.md && git add . && git commit -m "commit C"

# --soft: undo commit, changes stay STAGED
git reset --soft HEAD~1
git status   # Changes to be committed

# --mixed: undo commit, changes UNSTAGED
git reset --mixed HEAD~1
git status   # Changes not staged

# --hard: undo commit, changes DELETED
git reset --hard HEAD~1
git status   # Clean — changes GONE!

# Safety net
git reflog   # see all git actions ever
```

| Flag | Staged | Working Dir | Destructive |
|---|---|---|---|
| --soft | Yes | Yes | No |
| --mixed | No | Yes | No |
| --hard | No | No | YES |

### Git Revert

```bash
echo "X" >> file && git add . && git commit -m "commit X"
echo "Y" >> file && git add . && git commit -m "commit Y"
echo "Z" >> file && git add . && git commit -m "commit Z"

git log --oneline
# copy hash of Y

git revert <HASH_OF_Y>
# Creates NEW undo commit — Y still in history!
git log --oneline
```

| | git reset | git revert |
|--|---|---|
| History | Removes commit | Adds undo commit |
| Safe for shared? | No | Yes |
| When to use | Local cleanup | Undoing pushed commits |

### Branching Strategies

| Strategy | Best For |
|---|---|
| GitFlow | Large teams, scheduled releases |
| GitHub Flow | Startups, fast CI/CD |
| Trunk-Based | Senior teams, continuous deploy |
