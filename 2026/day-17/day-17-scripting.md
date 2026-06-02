# Complete DevOps Study Notes


## Day 17 — Loops, Arguments and Error Handling

---

### Task 1: For Loop

**What is For Loop?**
- Repeats commands for every item in a list

**Syntax:**

```bash
for VARIABLE in item1 item2 item3
do
  echo $VARIABLE
done
```

**Script: for_loop.sh**

```bash
#!/bin/bash
for FRUIT in Apple Mango Banana Orange Grapes
do
  echo "Fruit: $FRUIT"
done
```

**Output:**

```
Fruit: Apple
Fruit: Mango
Fruit: Banana
Fruit: Orange
Fruit: Grapes
```

**Script: count.sh (numbers 1 to 10)**

```bash
#!/bin/bash
for NUM in $(seq 1 10)
do
  echo "Number: $NUM"
done
# seq 1 10 generates numbers from 1 to 10 automatically
```

**Output:**

```
Number: 1
Number: 2
...
Number: 10
```

---

### Task 2: While Loop

**What is While Loop?**
- Repeats commands as long as condition is TRUE

**Syntax:**

```bash
while [ condition ]
do
  commands
done
```

**Script: countdown.sh**

```bash
#!/bin/bash
read -p "Enter a number to countdown: " NUM
while [ $NUM -ge 0 ]
do
  echo "Countdown: $NUM"
  NUM=$((NUM - 1))
done
echo "Done!"
# $((NUM - 1)) → arithmetic in bash
# -ge          → greater than or equal to
```

**Output (input 5):**

```
Countdown: 5
Countdown: 4
Countdown: 3
Countdown: 2
Countdown: 1
Countdown: 0
Done!
```

---

### Task 3: Command Line Arguments

**What are Arguments?**
- Values you pass to a script when running it
- Example: `./greet.sh Neha DevOps`

**Special Variables:**

| Variable | Meaning |
|----------|---------|
| `$0` | script name itself |
| `$1` | first argument |
| `$2` | second argument |
| `$#` | total count of arguments |
| `$@` | all arguments together |

**Script: greet_arg.sh**

```bash
#!/bin/bash
if [ -z "$1" ]; then
  echo "Usage: ./greet_arg.sh <name>"
  exit 1
fi
echo "Hello, $1!"
# -z checks if variable is empty or missing
```

**Output:**

```
./greet_arg.sh Neha   →  Hello, Neha!
./greet_arg.sh        →  Usage: ./greet_arg.sh <name>
```

**Script: args_demo.sh**

```bash
#!/bin/bash
echo "Script Name     : $0"
echo "Total Arguments : $#"
echo "All Arguments   : $@"
```

```bash
# Run:
./args_demo.sh DevOps Linux AWS Docker
```

**Output:**

```
Script Name     : ./args_demo.sh
Total Arguments : 4
All Arguments   : DevOps Linux AWS Docker
```

---

### Task 4: Install Packages via Script

**Script: install_packages.sh**

```bash
#!/bin/bash
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root: sudo ./install_packages.sh"
  exit 1
fi

PACKAGES="nginx curl wget"
for PKG in $PACKAGES
do
  if rpm -q $PKG &>/dev/null; then
    echo "[$PKG] Already installed - Skipping"
  else
    echo "[$PKG] Not found - Installing..."
    yum install -y $PKG &>/dev/null
    echo "[$PKG] Installed Successfully"
  fi
done
```

**Commands Explained:**

| Command | Meaning |
|---------|---------|
| `rpm -q packagename` | check if package is installed (Amazon Linux) |
| `dpkg -s packagename` | check if package is installed (Ubuntu) |
| `yum install -y pkg` | install package silently |
| `&>/dev/null` | hide all command output |
| `$EUID` | current user ID (0 = root) |

**Output:**

```
[nginx] Installed Successfully
[curl] Already installed - Skipping
[wget] Already installed - Skipping
```

---

### Task 5: Error Handling

**What is Error Handling?**
- When a command fails, handle it properly instead of crashing

**`set -e`:**
- Add at top of script
- If ANY command fails, script stops immediately

**Operators:**

```bash
||  (OR)   →  run second command only if FIRST FAILS
&&  (AND)  →  run second command only if FIRST SUCCEEDS

mkdir /tmp/test || echo "Already exists"
cd /tmp/test && echo "Moved successfully"
```

**Script: safe_script.sh**

```bash
#!/bin/bash
set -e
mkdir /tmp/devops-test || echo "Directory already exists, continuing..."
cd /tmp/devops-test && echo "Moved into /tmp/devops-test"
touch devops.txt && echo "File devops.txt created"
echo "All steps completed successfully!"
```

**Output (first run):**

```
Moved into /tmp/devops-test
File devops.txt created
All steps completed successfully!
```

**Output (second run):**

```
Directory already exists, continuing...
Moved into /tmp/devops-test
File devops.txt created
All steps completed successfully!
```

**Root Check:**

```bash
if [ "$EUID" -ne 0 ]; then
  echo "Run as root: sudo ./script.sh"
  exit 1
fi
```

---

### Day 17 Practice Script: day17_practice.sh

```bash
#!/bin/bash
echo "========================================"
echo "       Day-17 Shell Scripting Lab       "
echo "========================================"

# For Loop - List
for FRUIT in Apple Mango Banana Orange Grapes
do
  echo "Fruit: $FRUIT"
done

# For Loop - Numbers
for NUM in $(seq 1 10)
do
  echo "Number: $NUM"
done

# While Loop - Countdown
read -p "Enter a number to countdown: " COUNT
while [ $COUNT -ge 0 ]
do
  echo "Countdown: $COUNT"
  COUNT=$((COUNT - 1))
done
echo "Done!"

# Arguments
echo "Script Name     : $0"
echo "Total Arguments : $#"
echo "All Arguments   : $@"
echo "1st Argument    : $1"
echo "2nd Argument    : $2"

# Argument check
if [ -z "$1" ]; then
  echo "No name given! Usage: ./day17_practice.sh <name> <role>"
else
  echo "Hello $1! Your role is: $2"
fi

# Package check
for PKG in nginx curl wget git
do
  if rpm -q $PKG &>/dev/null; then
    echo "[$PKG] Already Installed"
  else
    echo "[$PKG] Not Installed"
  fi
done

# Error handling
mkdir /tmp/day17-test || echo "Directory already exists"
cd /tmp/day17-test && echo "Moved into /tmp/day17-test"
touch practice.txt && echo "File practice.txt created"

echo "========================================"
echo "   Day-17 Practice Complete!            "
echo "========================================"
```

---

### Day 17 — Scripts Created

| Script | Purpose |
|--------|---------|
| `for_loop.sh` | for loop with list |
| `count.sh` | for loop with numbers |
| `countdown.sh` | while loop countdown |
| `greet_arg.sh` | argument check |
| `args_demo.sh` | all argument variables |
| `install_packages.sh` | package install with loop |
| `safe_script.sh` | error handling |
| `day17_practice.sh` | full practice script |

### Day 17 — Key Learnings

1. For loop repeats for each item in list
2. While loop repeats while condition is true
3. `$1` `$2` `$#` `$@` are special variables for arguments
4. `set -e` stops script immediately on any error
5. `||` handles failure, `&&` runs only on success
6. Always check if script runs as root for system tasks

---

## Complete Cheatsheet — Day 16 & Day 17

| Concept | Syntax | Meaning |
|---------|--------|---------|
| Shebang | `#!/bin/bash` | Use bash interpreter |
| Variable | `NAME="value"` | Store a value |
| Print variable | `echo "$NAME"` | Print value |
| User input | `read -p "msg" VAR` | Take user input |
| If condition | `if [ condition ]; then` | Make a decision |
| End if | `fi` | Close if block |
| For loop | `for x in list; do` | Repeat for each item |
| Number range | `$(seq 1 10)` | Generate 1 to 10 |
| While loop | `while [ condition ]; do` | Repeat while true |
| End loop | `done` | Close loop |
| Arithmetic | `$((NUM - 1))` | Math in bash |
| Script name | `$0` | Name of script |
| First argument | `$1` | First value passed |
| Second argument | `$2` | Second value passed |
| All arguments | `$@` | All values passed |
| Argument count | `$#` | How many arguments |
| Empty check | `[ -z "$1" ]` | Is variable empty? |
| File exists | `[ -f "file" ]` | Does file exist? |
| Root user check | `[ "$EUID" -ne 0 ]` | Is user root? |
| Stop on error | `set -e` | Exit on any failure |
| On failure | `cmd \|\| echo "failed"` | Handle failure |
| On success | `cmd && echo "done"` | Run if success |
| Hide output | `&>/dev/null` | Suppress all output |
| Check pkg | `rpm -q pkgname` | Is package installed? |
| Install pkg | `yum install -y pkg` | Install on Amazon Linux |
| Give permission | `chmod +x script.sh` | Make script executable |
| Run script | `./script.sh` | Execute the script |

---



---

## Linux Commands Practiced

```bash
mkdir -p /path/folder           # create directory (with parents)
ls                              # list files
pwd                             # print current directory
cd /path                        # change directory
touch filename.txt              # create empty file
cat filename.txt                # read file content
cp file1 file2                  # copy file
mv file1 file2                  # rename or move file
rm -rf folder                   # delete folder and contents
chmod 755 file                  # set file permissions
find /path -name "*.txt"        # find files by name
grep "word" file                # search word inside file
hostname                        # show server name
whoami                          # show current user
df -h                           # disk usage
free -m                         # memory usage
uptime                          # how long server is running
ps aux                          # show running processes
tar -czf archive.tar.gz /path   # create compressed archive
sudo yum install -y pkg         # install package
systemctl is-active sshd        # check if service is running
rpm -q packagename              # check if package is installed
```

---

