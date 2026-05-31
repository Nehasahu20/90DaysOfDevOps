## DAY 12 — Revision Day (Days 01-11)

### What it is:
Revision and consolidation of all previous days.

### Quick revision commands to run:
```bash
# Processes
ps aux | head -5
systemctl status sshd

# Files
touch test.txt && echo "hello" > test.txt && cat test.txt
ls -l test.txt
chmod 755 test.txt && ls -l test.txt

# Ownership
sudo chown root:root test.txt && ls -l test.txt

# Users
id $USER
groups $USER

# Disk/Memory
free -h
df -h
```

---
