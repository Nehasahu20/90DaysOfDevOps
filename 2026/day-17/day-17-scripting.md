============================================================
  DAY 17 - LOOPS, ARGUMENTS AND ERROR HANDLING
============================================================


------------------------------------------------------------
TASK 1: FOR LOOP
------------------------------------------------------------

WHAT IS FOR LOOP?
  A for loop repeats commands for every item in a list
  Real life example: For every student in class, print their name

SYNTAX:
  for VARIABLE in item1 item2 item3
  do
    echo $VARIABLE
  done

SCRIPT: for_loop.sh
  #!/bin/bash
  for FRUIT in Apple Mango Banana Orange Grapes
  do
    echo "Fruit: $FRUIT"
  done

OUTPUT:
  Fruit: Apple
  Fruit: Mango
  Fruit: Banana
  Fruit: Orange
  Fruit: Grapes

SCRIPT: count.sh (numbers 1 to 10)
  #!/bin/bash
  for NUM in $(seq 1 10)
  do
    echo "Number: $NUM"
  done

  seq 1 10  --> generates numbers from 1 to 10 automatically

OUTPUT:
  Number: 1
  Number: 2
  ... up to ...
  Number: 10


------------------------------------------------------------
TASK 2: WHILE LOOP
------------------------------------------------------------

WHAT IS WHILE LOOP?
  Repeats commands as long as a condition is TRUE
  When condition becomes false, loop stops
  Real life: While there is food on plate, keep eating

SYNTAX:
  while [ condition ]
  do
    commands
  done

SCRIPT: countdown.sh
  #!/bin/bash
  read -p "Enter a number to countdown: " NUM
  while [ $NUM -ge 0 ]
  do
    echo "Countdown: $NUM"
    NUM=$((NUM - 1))
  done
  echo "Done!"

  $((NUM - 1))  --> arithmetic calculation in bash
  -ge           --> greater than or equal to

OUTPUT (input 5):
  Countdown: 5
  Countdown: 4
  Countdown: 3
  Countdown: 2
  Countdown: 1
  Countdown: 0
  Done!


------------------------------------------------------------
TASK 3: COMMAND LINE ARGUMENTS
------------------------------------------------------------

WHAT ARE ARGUMENTS?
  Values you pass to a script when running it
  Example: ./greet.sh Neha DevOps
  Here Neha is argument 1 and DevOps is argument 2

SPECIAL VARIABLES:
  $0   --> script name itself (./greet.sh)
  $1   --> first argument (Neha)
  $2   --> second argument (DevOps)
  $#   --> total count of arguments (2)
  $@   --> all arguments together (Neha DevOps)

SCRIPT: greet_arg.sh
  #!/bin/bash
  if [ -z "$1" ]; then
    echo "Usage: ./greet_arg.sh <name>"
    exit 1
  fi
  echo "Hello, $1!"

  -z  --> checks if variable is empty or missing

OUTPUT:
  ./greet_arg.sh Neha    --> Hello, Neha!
  ./greet_arg.sh         --> Usage: ./greet_arg.sh <name>

SCRIPT: args_demo.sh
  #!/bin/bash
  echo "Script Name     : $0"
  echo "Total Arguments : $#"
  echo "All Arguments   : $@"

  Run: ./args_demo.sh DevOps Linux AWS Docker

OUTPUT:
  Script Name     : ./args_demo.sh
  Total Arguments : 4
  All Arguments   : DevOps Linux AWS Docker


------------------------------------------------------------
TASK 4: INSTALL PACKAGES VIA SCRIPT
------------------------------------------------------------

WHAT IS THIS?
  Use a for loop to automatically check and install packages
  Very useful in DevOps for server setup automation

SCRIPT: install_packages.sh
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

COMMANDS EXPLAINED:
  rpm -q packagename     check if package is installed (Amazon Linux)
  dpkg -s packagename    check if package is installed (Ubuntu)
  yum install -y pkg     install package silently
  &>/dev/null            hide all command output
  $EUID                  current user ID (0 means root)

OUTPUT:
  [nginx] Installed Successfully
  [curl] Already installed - Skipping
  [wget] Already installed - Skipping


------------------------------------------------------------
TASK 5: ERROR HANDLING
------------------------------------------------------------

WHAT IS ERROR HANDLING?
  When a command fails, instead of crashing, handle it properly
  Show a useful message and continue or stop safely

set -e:
  Add this at top of script
  If ANY command fails, script stops immediately
  Prevents running wrong commands after a failure

OPERATORS:
  ||  (OR)   --> Run second command only if FIRST FAILS
  &&  (AND)  --> Run second command only if FIRST SUCCEEDS

EXAMPLES:
  mkdir /tmp/test || echo "Already exists"
  cd /tmp/test && echo "Moved successfully"

SCRIPT: safe_script.sh
  #!/bin/bash
  set -e
  mkdir /tmp/devops-test || echo "Directory already exists, continuing..."
  cd /tmp/devops-test && echo "Moved into /tmp/devops-test"
  touch devops.txt && echo "File devops.txt created"
  echo "All steps completed successfully!"

OUTPUT (first run):
  Moved into /tmp/devops-test
  File devops.txt created
  All steps completed successfully!

OUTPUT (second run - dir already exists):
  Directory already exists, continuing...
  Moved into /tmp/devops-test
  File devops.txt created
  All steps completed successfully!

ROOT CHECK:
  if [ "$EUID" -ne 0 ]; then
    echo "Run as root: sudo ./script.sh"
    exit 1
  fi


------------------------------------------------------------
DAY 17 PRACTICE SCRIPT: day17_practice.sh
------------------------------------------------------------

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


------------------------------------------------------------
DAY 17 - ALL SCRIPTS CREATED
------------------------------------------------------------
  for_loop.sh          --> for loop with list
  count.sh             --> for loop with numbers
  countdown.sh         --> while loop countdown
  greet_arg.sh         --> argument check
  args_demo.sh         --> all argument variables
  install_packages.sh  --> package install with loop
  safe_script.sh       --> error handling
  day17_practice.sh    --> full practice script

DAY 17 - KEY LEARNINGS
  1. For loop repeats for each item in list
  2. While loop repeats while condition is true
  3. $1 $2 $# $@ are special variables for arguments
  4. set -e stops script immediately on any error
  5. || handles failure, && runs only on success
  6. Always check if script runs as root for system tasks


============================================================
   COMPLETE CHEATSHEET - DAY 16 AND DAY 17
============================================================

CONCEPT              SYNTAX                       MEANING
-------------------------------------------------------------
Shebang              #!/bin/bash                  Use bash interpreter
Variable             NAME="value"                 Store a value
Print variable       echo "$NAME"                 Print value
User input           read -p "msg" VAR            Take user input
If condition         if [ condition ]; then        Make a decision
End if               fi                           Close if block
For loop             for x in list; do            Repeat for each item
Number range         $(seq 1 10)                  Generate 1 to 10
While loop           while [ condition ]; do      Repeat while true
End loop             done                         Close loop
Arithmetic           $((NUM - 1))                 Math in bash
Script name          $0                           Name of script
First argument       $1                           First value passed
Second argument      $2                           Second value passed
All arguments        $@                           All values passed
Argument count       $#                           How many arguments
Empty check          [ -z "$1" ]                  Is variable empty?
File exists check    [ -f "file" ]                Does file exist?
Root user check      [ "$EUID" -ne 0 ]            Is user root?
Stop on error        set -e                       Exit on any failure
On failure           cmd || echo "failed"         Handle failure
On success           cmd && echo "done"           Run if success
Hide output          &>/dev/null                  Suppress all output
Check pkg installed  rpm -q pkgname               Is package installed?
Install package      yum install -y pkg           Install on Amazon Linux
Give permission      chmod +x script.sh           Make script executable
Run script           ./script.sh                  Execute the script


============================================================
  GIT COMMANDS USED TODAY
============================================================

  git clone <url> <foldername>    clone a repository
  Example:
  git clone https://github.com/Nehasahu20/90DaysOfDevOps repos

  cat repos/2026/day-16/README.md    read day 16 content
  cat repos/2026/day-17/README.md    read day 17 content


============================================================
  LINUX COMMANDS PRACTICED TODAY
============================================================

  mkdir -p /path/folder      create directory (with parents)
  ls                         list files
  pwd                        print current directory
  cd /path                   change directory
  touch filename.txt         create empty file
  cat filename.txt           read file content
  cp file1 file2             copy file
  mv file1 file2             rename or move file
  rm -rf folder              delete folder and contents
  chmod 755 file             set file permissions
  find /path -name "*.txt"   find files by name
  grep "word" file           search word inside file
  hostname                   show server name
  whoami                     show current user
  df -h                      disk usage
  free -m                    memory usage
  uptime                     how long server is running
  ps aux                     show running processes
  tar -czf archive.tar.gz /path   create compressed archive
  sudo yum install -y pkg    install package
  systemctl is-active sshd   check if service is running
  rpm -q packagename         check if package is installed
