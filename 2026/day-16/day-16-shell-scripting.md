# Complete DevOps Study Notes

### Setup Commands

```bash
sudo su -                          # switch to root user
sudo mkdir -p /root/Learning       # create Learning directory
sudo yum install -y git            # install git
git --version                      # check git version installed: 2.50.1
```

### Git Clone

```bash
git clone https://github.com/Nehasahu20/90DaysOfDevOps repos
# clones the full repository into a folder called repos
```

---

## Day 16 — Shell Scripting Basics

**What is Shell Scripting?**
- A shell script is a file with `.sh` extension
- It contains Linux commands written in a file
- Instead of typing commands one by one, run them all at once
- Example: `hello.sh`, `variables.sh`, `greet.sh`

---

### Task 1: Shebang + echo

**What is Shebang?**
- `#!/bin/bash` is the first line of every shell script
- It tells the OS which interpreter to use
- Without it, script may fail on some systems

**Script: hello.sh**

```bash
#!/bin/bash
echo "Hello, DevOps!"
```

**How to Create and Run:**

```bash
vi hello.sh            # open editor
chmod +x hello.sh      # give execute permission
./hello.sh             # run the script
```

**Output:**

```
Hello, DevOps!
```

> **Note:** Always include shebang — it is best practice. Without it, on systems using `zsh` or `sh`, the script may fail.

---

### Task 2: Variables

**What is a Variable?**
- A variable stores a value (text, number) that you can reuse
- Think of it as a box that holds a value

**Rules:**

```bash
NAME="Neha"    # CORRECT — no spaces around =
NAME = "Neha"  # WRONG
```

**Script: variables.sh**

```bash
#!/bin/bash
NAME="Neha"
ROLE="DevOps Engineer"
echo "Hello, I am $NAME and I am a $ROLE"
```

**Output:**

```
Hello, I am Neha and I am a DevOps Engineer
```

**Double Quotes vs Single Quotes:**

```bash
echo "My name is $NAME"   # Output: My name is Neha   (variable expanded)
echo 'My name is $NAME'   # Output: My name is $NAME  (plain text)
```

---

### Task 3: User Input with `read`

**What is `read`?**
- Captures input from user while script is running
- User types something and it gets stored in a variable

**Syntax:**

```bash
read -p "Enter your name: " NAME
# -p means show a prompt message
```

**Script: greet.sh**

```bash
#!/bin/bash
read -p "Enter your name: " NAME
read -p "Enter your favourite tool: " TOOL
echo "Hello $NAME, your favourite tool is $TOOL"
```

**Output (when user types Neha and Docker):**

```
Hello Neha, your favourite tool is Docker
```

---

### Task 4: IF-ELSE Conditions

**What is IF-ELSE?**
- Conditions let your script make decisions

**Syntax:**

```bash
if [ condition ]; then
  do something
elif [ condition ]; then
  do something else
else
  default action
fi
```

**Number Comparison Operators:**

| Operator | Meaning | Example |
|----------|---------|---------|
| `-gt` | greater than | `5 -gt 3` → true |
| `-lt` | less than | `3 -lt 5` → true |
| `-ge` | greater or equal | `5 -ge 5` → true |
| `-le` | less or equal | `3 -le 5` → true |
| `-eq` | equal | `5 -eq 5` → true |
| `-ne` | not equal | `5 -ne 3` → true |

**Script: check_number.sh**

```bash
#!/bin/bash
read -p "Enter a number: " NUM
if [ $NUM -gt 0 ]; then
  echo "The number is Positive"
elif [ $NUM -lt 0 ]; then
  echo "The number is Negative"
else
  echo "The number is Zero"
fi
```

**Output:**

```
Input 10  →  The number is Positive
Input -5  →  The number is Negative
Input 0   →  The number is Zero
```

**Script: file_check.sh**

```bash
#!/bin/bash
read -p "Enter filename: " FILENAME
if [ -f "$FILENAME" ]; then
  echo "File EXISTS"
else
  echo "File does NOT exist"
fi
# -f checks if file exists and is a regular file
```

**Script: server_check.sh**

```bash
#!/bin/bash
SERVICE="sshd"
read -p "Do you want to check status? (y/n): " CHOICE
if [ "$CHOICE" = "y" ]; then
  STATUS=$(systemctl is-active $SERVICE)
  if [ "$STATUS" = "active" ]; then
    echo "$SERVICE is ACTIVE and running"
  else
    echo "$SERVICE is NOT active"
  fi
else
  echo "Skipped."
fi
```

---

### Day 16 Practice Script: practice.sh

```bash
#!/bin/bash
echo "=============================="
echo "   Welcome to DevOps Practice "
echo "=============================="
AUTHOR="DevOps Learner"
DAY="Day 16"
echo "Script by: $AUTHOR | Topic: $DAY"

read -p "Enter your name: " NAME
read -p "Enter your age: " AGE

if [ $AGE -lt 18 ]; then
  echo "Hey $NAME! You are a minor."
elif [ $AGE -ge 18 ] && [ $AGE -le 35 ]; then
  echo "Hey $NAME! Perfect age to learn DevOps!"
else
  echo "Hey $NAME! Experience speaks!"
fi

read -p "Enter a filename to check: " FNAME
if [ -f "$FNAME" ]; then
  echo "File $FNAME EXISTS"
else
  echo "File $FNAME does NOT exist"
fi

read -p "Enter a service name (e.g. sshd): " SVC
STATUS=$(systemctl is-active $SVC 2>/dev/null)
if [ "$STATUS" = "active" ]; then
  echo "Service $SVC is RUNNING"
else
  echo "Service $SVC is NOT running"
fi
```

---

### Day 16 — Scripts Created

| Script | Purpose |
|--------|---------|
| `hello.sh` | shebang + echo |
| `variables.sh` | variables + quotes difference |
| `greet.sh` | user input with read |
| `check_number.sh` | if-elif-else with numbers |
| `file_check.sh` | file existence check |
| `server_check.sh` | combining all concepts |
| `practice.sh` | full practice script |

### Day 16 — Key Learnings

1. Always start script with `#!/bin/bash` (shebang)
2. No spaces around `=` when setting variables
3. Double quotes expand variables, single quotes do not
4. `read -p` takes user input at runtime
5. `if-elif-else` is used for making decisions in scripts

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

