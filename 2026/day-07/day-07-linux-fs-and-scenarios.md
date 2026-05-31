## DAY 07 — Linux Filesystem Hierarchy

### What it is:
Understand the Linux directory structure and troubleshoot real scenarios.

### Key Directories:
```
/           → root of everything (starting point)
/home       → user home directories (/home/alice, /home/bob)
/root       → root user's home directory
/etc        → ALL configuration files (nginx.conf, passwd, hosts)
/var/log    → ALL log files (nginx, sshd, system logs)
/tmp        → temporary files (cleared on reboot)
/bin        → essential commands (ls, cp, mv, cat)
/usr/bin    → user commands (python, git, curl)
/opt        → third-party apps (custom software)
```

### Key Commands:
```bash
ls -l /etc | head -5            # list config files
cat /etc/hostname               # see server hostname
ls /var/log                     # list log files
du -sh /var/log/* | sort -h     # find biggest log files
ls -la ~                        # list home directory
```

### Real-world scenarios:
```
Service not starting?
  → systemctl status myapp
  → journalctl -u myapp -n 50
  → systemctl is-enabled myapp

High CPU?
  → top  OR  ps aux --sort=-%cpu | head -10

Permission denied on script?
  → ls -l script.sh          (check permissions)
  → chmod +x script.sh       (add execute)
  → ./script.sh              (run it)
```

---
