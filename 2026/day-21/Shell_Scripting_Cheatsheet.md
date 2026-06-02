## Day 21 — Shell Scripting Cheat Sheet

### Basics

```bash
#!/bin/bash              # shebang — always first line
chmod +x script.sh       # give execute permission
./script.sh              # run script
bash script.sh           # run with bash

NAME="Neha"              # variable — no spaces around =
echo "$NAME"             # always double-quote variables
echo '$NAME'             # single quote — no expansion

read -p "Enter: " VAR    # read input from console

$0  $1  $2               # script name, arg1, arg2
$#                       # total argument count
$@                       # all arguments
$?                       # exit code of last command
```

---

### Conditionals

```bash
if [ $NUM -gt 0 ]; then
  echo "Positive"
elif [ $NUM -lt 0 ]; then
  echo "Negative"
else
  echo "Zero"
fi

# File checks
[ -f file ]   # is a file
[ -d dir ]    # is a directory
[ -z "$V" ]   # is empty
[ -n "$V" ]   # is not empty

# Case
case $X in
  1) echo "One" ;;
  2) echo "Two" ;;
  *) echo "Other" ;;
esac
```

---

### Loops

```bash
# For loop
for i in 1 2 3; do echo $i; done

# C-style for
for ((i=1; i<=5; i++)); do echo $i; done

# While loop
while [ $N -gt 0 ]; do
  echo $N
  N=$((N - 1))
done

# Until loop
until [ $N -ge 5 ]; do
  N=$((N + 1))
done

# Loop over files
for f in *.log; do echo $f; done

# break / continue
[ $i -eq 3 ] && continue
[ $i -eq 5 ] && break
```

---

### Functions

```bash
greet() { echo "Hello, $1!"; }
greet "Neha"

add() { echo $(($1 + $2)); }
RESULT=$(add 5 10)

local_demo() {
  local X="inside"
  echo $X
}
```

---

### Text Processing

```bash
grep "ERROR" file              # search
grep -i "error" file           # case insensitive
grep -c "ERROR" file           # count
grep -n "ERROR" file           # with line numbers
grep -v "INFO" file            # exclude
grep -E "ERROR|CRITICAL" file  # multiple patterns

awk '{print $1}' file          # first column
awk -F: '{print $1}' /etc/passwd  # custom delimiter
awk '{$1=$2=""; print}' file   # remove columns

sed 's/old/new/g' file         # replace
sed -i 's/old/new/g' file      # replace in-place
sed '/ERROR/d' file            # delete matching lines

sort file | uniq -c | sort -rn # count + sort by frequency
wc -l file                     # count lines
tail -f file                   # follow live log
head -10 file                  # first 10 lines
```

---

### Error Handling

```bash
set -e             # stop on error
set -u             # stop on undefined variable
set -o pipefail    # stop on pipe failure
set -x             # debug mode

exit 0             # success
exit 1             # failure
echo $?            # check last exit code

trap 'echo "Error on line $LINENO"' ERR
trap 'cleanup' EXIT
```

---

### Useful One-Liners

```bash
find /tmp -name "*.log" -mtime +7 -delete          # delete old files
wc -l *.log                                         # count lines in all logs
sed -i 's/old/new/g' *.conf                         # replace in multiple files
systemctl is-active nginx && echo "UP" || echo "DOWN"  # check service
df / | awk 'NR==2{print $5}' | tr -d '%'            # get disk % usage
tail -f app.log | grep "ERROR"                      # live error monitoring
```

---

### Day 21 — Key Learnings

1. `grep | awk | sort | uniq` pipeline is the core of log analysis
2. Always use `set -euo pipefail` in production scripts
3. `trap` handles cleanup when script exits unexpectedly

---
