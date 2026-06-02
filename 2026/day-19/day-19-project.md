## Day 19 — Shell Scripting Project: Log Rotation, Backup & Crontab

### What You Learn
- Compress old log files automatically
- Create timestamped backups
- Schedule scripts with crontab

---

### Task 1 — Log Rotation Script

```bash
#!/bin/bash

LOG_DIR=$1

if [ ! -d "$LOG_DIR" ]; then
  echo "ERROR: Directory $LOG_DIR does not exist!"
  exit 1
fi

# Compress .log files older than 7 days
COMPRESSED=0
for f in $(find $LOG_DIR -name "*.log" -mtime +7); do
  gzip "$f"
  COMPRESSED=$((COMPRESSED + 1))
done

# Delete .gz files older than 30 days
DELETED=0
for f in $(find $LOG_DIR -name "*.gz" -mtime +30); do
  rm "$f"
  DELETED=$((DELETED + 1))
done

echo "Compressed: $COMPRESSED | Deleted: $DELETED"
```

**Practice:**
```bash
mkdir -p /tmp/myapp_logs
touch -d '10 days ago' /tmp/myapp_logs/app1.log
touch -d '35 days ago' /tmp/myapp_logs/old.gz
bash log_rotate.sh /tmp/myapp_logs
```

---

### Task 2 — Server Backup Script

```bash
#!/bin/bash

read -p "Enter source directory: " SOURCE_DIR
read -p "Enter backup destination: " BACKUP_DIR

if [ ! -d "$SOURCE_DIR" ]; then
  echo "ERROR: Source not found!"
  exit 1
fi

mkdir -p $BACKUP_DIR
DATE=$(date +%Y-%m-%d)
ARCHIVE="$BACKUP_DIR/backup-$DATE.tar.gz"

tar -czf "$ARCHIVE" "$SOURCE_DIR"

if [ -f "$ARCHIVE" ]; then
  SIZE=$(du -sh "$ARCHIVE" | cut -f1)
  echo "Backup created : $ARCHIVE"
  echo "Backup size    : $SIZE"
fi

# Delete backups older than 14 days
find $BACKUP_DIR -name "*.tar.gz" -mtime +14 -delete
echo "Old backups cleaned."
```

**Practice:**
```bash
bash backup.sh
# Enter source: /tmp/myapp_logs
# Enter destination: /tmp/backups
ls -lh /tmp/backups/
```

---

### Task 3 — Crontab Syntax

```
* * * * *  command
│ │ │ │ │
│ │ │ │ └── Day of week (0=Sun)
│ │ │ └──── Month (1-12)
│ │ └────── Day of month (1-31)
│ └──────── Hour (0-23)
└────────── Minute (0-59)
```

**Cron entries:**
```bash
0 2 * * *    bash ~/log_rotate.sh    # daily at 2 AM
0 3 * * 0    bash ~/backup.sh         # every Sunday at 3 AM
*/5 * * * *  bash ~/healthcheck.sh   # every 5 minutes
0 1 * * *    bash ~/maintenance.sh   # daily at 1 AM
```

**Practice:**
```bash
crontab -l                           # view current cron jobs
crontab -e                           # edit cron jobs
(crontab -l; echo "0 2 * * * bash ~/log_rotate.sh") | crontab -
```

---

### Task 4 — Maintenance Script

```bash
#!/bin/bash
set -euo pipefail

LOG="/tmp/maintenance.log"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') : $1" | tee -a $LOG
}

log "Maintenance started"
# call log rotation
# call backup
log "Maintenance completed"
```

**Practice:**
```bash
bash maintenance.sh
cat /tmp/maintenance.log
```

---

### Day 19 — Key Learnings

1. `find -mtime +7` finds files older than 7 days
2. `tar -czf archive.tar.gz /path` creates compressed backup
3. `date +%Y-%m-%d` gives today's date for timestamped filenames
4. Cron `*/5 * * * *` means every 5 minutes

---
