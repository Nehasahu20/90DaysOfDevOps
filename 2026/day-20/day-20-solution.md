## Day 20 — Bash Scripting Challenge: Log Analyzer

### What You Learn
- Parse log files with `grep`, `awk`, `sort`, `uniq`
- Count errors, find critical events, generate reports

---

### Create Sample Log

```bash
cat << 'EOF' > sample.log
2026-05-31 08:01:01 INFO Server started
2026-05-31 08:05:10 ERROR Connection timed out
2026-05-31 08:20:44 CRITICAL Disk space below threshold
2026-05-31 08:25:55 ERROR File not found
2026-05-31 08:40:28 ERROR Permission denied
2026-05-31 08:45:39 CRITICAL Database connection lost
2026-05-31 08:55:01 ERROR Connection timed out
2026-05-31 09:00:12 ERROR Disk I/O error
EOF
```

---

### Task 1 — Input Validation

```bash
if [ -z "$1" ]; then
  echo "Usage: bash log_analyzer.sh <logfile>"
  exit 1
fi

if [ ! -f "$1" ]; then
  echo "ERROR: File not found!"
  exit 1
fi
```

**Practice:**
```bash
bash log_analyzer.sh                 # no arg → shows usage
bash log_analyzer.sh /wrong/path     # wrong path → error
bash log_analyzer.sh sample.log      # works
```

---

### Task 2 — Count Errors

```bash
ERROR_COUNT=$(grep -cE "ERROR|Failed" sample.log)
echo "Total Errors: $ERROR_COUNT"
```

**Practice:**
```bash
grep -c "ERROR" sample.log
grep -cE "ERROR|Failed" sample.log
```

---

### Task 3 — Critical Events with Line Numbers

```bash
echo "--- Critical Events ---"
grep -n "CRITICAL" sample.log
```

**Practice:**
```bash
grep -n "CRITICAL" sample.log
# Output:
# 5: 2026-05-31 08:20:44 CRITICAL Disk space below threshold
# 10: 2026-05-31 08:45:39 CRITICAL Database connection lost
```

---

### Task 4 — Top 5 Error Messages

```bash
grep "ERROR" sample.log | awk '{$1=$2=$3=""; print $0}' | sed 's/^ *//' | sort | uniq -c | sort -rn | head -5
```

**Practice:**
```bash
# Step by step breakdown:
grep "ERROR" sample.log                    # get ERROR lines
grep "ERROR" sample.log | awk '{$1=$2=$3=""; print}'  # remove date/time
grep "ERROR" sample.log | awk '{$1=$2=$3=""; print}' | sort | uniq -c | sort -rn | head -5
```

---

### Task 5 — Generate Report

```bash
DATE=$(date +%Y-%m-%d)
REPORT="log_report_$DATE.txt"

{
  echo "Date     : $DATE"
  echo "Log File : $1"
  echo "Total Lines : $(wc -l < $1)"
  echo "Total Errors: $(grep -cE 'ERROR|Failed' $1)"
  echo ""
  echo "--- Top 5 Errors ---"
  grep "ERROR" $1 | awk '{$1=$2=$3=""; print}' | sort | uniq -c | sort -rn | head -5
  echo ""
  echo "--- Critical Events ---"
  grep -n "CRITICAL" $1
} > "$REPORT"


echo "Report saved: $REPORT"
cat "$REPORT"
```

**Practice:**
```bash
bash log_analyzer.sh sample.log
cat log_report_$(date +%Y-%m-%d).txt
```

---

### Task 6 — Archive Log

```bash
mkdir -p archive
cp sample.log archive/
echo "Archived to archive/"
ls archive/
```

---

### Day 20 — Key Learnings

1. `grep -cE "ERROR|Failed"` counts multiple patterns in one command
2. `awk '{$1=$2=$3=""; print}'` removes first 3 columns (date/time/level)
3. `sort | uniq -c | sort -rn | head -5` finds top 5 most frequent lines
4. `grep -n` shows line numbers — useful for locating events in large logs

---
