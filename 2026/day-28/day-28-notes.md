## Day 28 — Revision — Quick Practice

```bash
# Permissions
chmod 755 script.sh      # rwxr-xr-x
chmod 644 file.txt       # rw-r--r--
chmod u+x script.sh      # add execute for owner
chown ec2-user file.txt  # change owner

# Find process on port
ss -tulnp | grep 8080

# Crontab — run at 3AM daily
crontab -e
# 0 3 * * * /path/to/script.sh
crontab -l

# Git quick recap
git log --oneline --graph --all
git stash list
git branch -a
git remote -v
git reflog
```

---
