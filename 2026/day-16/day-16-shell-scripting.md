
============================================================
   COMPLETE DEVOPS STUDY NOTES
   Date: 27 May 2026
   Topics: Git + Day 16 + Day 17 Shell Scripting
============================================================


============================================================
  SESSION START - SERVER SETUP
============================================================

SERVER DETAILS:
  Server  : AWS EC2 Amazon Linux 2023
  User    : ec2-user
  Connect : ssh -i neha-aws.pem ec2-user@ec2-43-205-177-48.ap-south-1.compute.amazonaws.com

COMMANDS USED TO SETUP:
  sudo su -                          switch to root user
  sudo mkdir -p /root/Learning       create Learning directory
  sudo yum install -y git            install git
  git --version                      check git version installed: 2.50.1

GIT CLONE COMMAND:
  git clone https://github.com/Nehasahu20/90DaysOfDevOps repos
  (clones the full repository into a folder called repos)


============================================================
  DAY 16 - SHELL SCRIPTING BASICS
============================================================

WHAT IS SHELL SCRIPTING?
  - A shell script is a file with .sh extension
  - It contains Linux commands written in a file
  - Instead of typing commands one by one, run them all at once
  - Example: hello.sh, variables.sh, greet.sh


------------------------------------------------------------
TASK 1: SHEBANG + echo
------------------------------------------------------------

WHAT IS SHEBANG?
  #!/bin/bash is the first line of every shell script
  It tells the OS which interpreter (program) to use
  Without it, script may fail on some systems

SCRIPT: hello.sh
  #!/bin/bash
  echo "Hello, DevOps!"

HOW TO CREATE AND RUN:
  vi hello.sh            open editor
  chmod +x hello.sh      give execute permission
  ./hello.sh             run the script

OUTPUT:
  Hello, DevOps!

WHAT IF SHEBANG IS REMOVED?
  On Amazon Linux it still works because default shell is bash
  But on other systems (zsh, sh) it may fail or behave differently
  ALWAYS include shebang -- it is best practice


------------------------------------------------------------
TASK 2: VARIABLES
------------------------------------------------------------

WHAT IS A VARIABLE?
  A variable stores a value (text, number) that you can reuse
  Think of it as a box that holds a value

RULES:
  No spaces around = sign
  NAME="Neha"   --> CORRECT
  NAME = "Neha" --> WRONG

HOW TO USE:
  NAME="Neha"
  echo $NAME     prints: Neha

SCRIPT: variables.sh
  #!/bin/bash
  NAME="Neha"
  ROLE="DevOps Engineer"
  echo "Hello, I am $NAME and I am a $ROLE"

OUTPUT:
  Hello, I am Neha and I am a DevOps Engineer

DOUBLE QUOTES vs SINGLE QUOTES:
  "double quotes"  --> variable IS expanded --> shows actual value
  'single quotes'  --> variable NOT expanded --> shows as plain text

  echo "My name is $NAME"   OUTPUT: My name is Neha
  echo 'My name is $NAME'   OUTPUT: My name is $NAME


------------------------------------------------------------
TASK 3: USER INPUT WITH read
------------------------------------------------------------

WHAT IS read?
  read command captures input from user while script is running
  User types something and it gets stored in a variable

SYNTAX:
  read -p "Enter your name: " NAME
  -p means show a prompt message

SCRIPT: greet.sh
  #!/bin/bash
  read -p "Enter your name: " NAME
  read -p "Enter your favourite tool: " TOOL
  echo "Hello $NAME, your favourite tool is $TOOL"

OUTPUT (when user types Neha and Docker):
  Hello Neha, your favourite tool is Docker


------------------------------------------------------------
TASK 4: IF-ELSE CONDITIONS
------------------------------------------------------------

WHAT IS IF-ELSE?
  Conditions let your script make decisions
  If this is true --> do this
  Else --> do something else

SYNTAX:
  if [ condition ]; then
    do something
  elif [ condition ]; then
    do something else
  else
    default action
  fi

NUMBER COMPARISON OPERATORS:
  -gt    greater than       (example: 5 -gt 3 is true)
  -lt    less than          (example: 3 -lt 5 is true)
  -ge    greater or equal   (example: 5 -ge 5 is true)
  -le    less or equal      (example: 3 -le 5 is true)
  -eq    equal              (example: 5 -eq 5 is true)5:23 PM 5/31/2026
  -ne    not equal          (example: 5 -ne 3 is true)

SCRIPT: check_number.sh
  #!/bin/bash
  read -p "Enter a number: " NUM
  if [ $NUM -gt 0 ]; then
    echo "The number is Positive"
  elif [ $NUM -lt 0 ]; then
    echo "The number is Negative"
  else
    echo "The number is Zero"
  fi

OUTPUT:
  Input 10  --> The number is Positive
  Input -5  --> The number is Negative
  Input 0   --> The number is Zero

SCRIPT: file_check.sh
  #!/bin/bash
  read -p "Enter filename: " FILENAME
  if [ -f "$FILENAME" ]; then
    echo "File EXISTS"
  else
    echo "File does NOT exist"
  fi
  NOTE: -f checks if file exists and is a regular file

SCRIPT: server_check.sh
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


------------------------------------------------------------
DAY 16 PRACTICE SCRIPT: practice.sh
------------------------------------------------------------

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


------------------------------------------------------------
DAY 16 - ALL SCRIPTS CREATED
------------------------------------------------------------
  hello.sh         --> shebang + echo
  variables.sh     --> variables + quotes difference
  greet.sh         --> user input with read
  check_number.sh  --> if-elif-else with numbers
  file_check.sh    --> file existence check
  server_check.sh  --> combining all concepts
  practice.sh      --> full practice script

DAY 16 - KEY LEARNINGS
  1. Always start script with #!/bin/bash (shebang)
  2. No spaces around = when setting variables
  3. Double quotes expand variables, single quotes do not
  4. read -p takes user input at runtime
  5. if-elif-else is used for making decisions in scripts




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


============================================================
  END OF COMPLETE STUDY NOTES
  Keep Learning! #90DaysOfDevOps #DevOpsKaJosh
============================================================
