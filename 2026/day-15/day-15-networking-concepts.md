## DAY 15 — DNS, IP, Subnets & Ports

### What it is:


Deep dive into networking building blocks.

### DNS:


```bash
dig google.com              # full DNS lookup
dig google.com +short       # just the IP
nslookup google.com         # alternate

# Record types:
A     → name to IPv4  (google.com → 142.250.x.x)
AAAA  → name to IPv6
CNAME → name alias   (www → google.com)
MX    → mail server
NS    → nameserver
```

### IP Addressing:
```
Private ranges (NOT internet routable):
  10.0.0.0/8          → 10.x.x.x
  172.16.0.0/12       → 172.16.x.x to 172.31.x.x
  192.168.0.0/16      → 192.168.x.x

Public IP  → visible on internet (e.g. 142.250.77.46)
Our server → 172.31.38.193 = PRIVATE (AWS VPC)
```

### CIDR Subnetting:
```
CIDR  Subnet Mask      Total IPs   Usable
/24   255.255.255.0    256         254
/16   255.255.0.0      65,536      65,534
/28   255.255.255.240  16          14
/32   255.255.255.255  1           1 (single host)
```

### Common Ports:
```
22    → SSH      (remote login)
80    → HTTP     (website)
443   → HTTPS    (secure website)
53    → DNS      (name lookup)
21    → FTP      (file transfer)
3306  → MySQL    (database)
5432  → PostgreSQL (database)
6379  → Redis    (cache)
27017 → MongoDB  (NoSQL database)
8080  → HTTP alt (app servers)
```

---

## FULL COMMAND CHEATSHEET (Days 04-15)

```bash
# PROCESSES
ps aux                      # all processes
ps aux --sort=-%cpu         # by CPU
ps aux --sort=-%mem         # by memory
kill -9 <PID>               # force kill process

# SERVICES
systemctl status sshd       # check service
systemctl start/stop/restart sshd
systemctl enable/disable sshd
journalctl -u sshd -n 50    # service logs

# FILES
touch file.txt              # create empty file
echo "text" > file.txt      # write to file
echo "text" >> file.txt     # append to file
cat file.txt                # read full file
head -5 file.txt            # first 5 lines
tail -5 file.txt            # last 5 lines
cp file1 file2              # copy
mv file1 file2              # move/rename
rm file.txt                 # delete

# PERMISSIONS
ls -l                       # show permissions
chmod 755 file              # rwxr-xr-x
chmod 644 file              # rw-r--r--
chmod +x file               # add execute
chmod -w file               # remove write
chmod -R 755 dir/           # recursive

# OWNERSHIP
chown user file             # change owner
chgrp group file            # change group
chown user:group file       # change both
chown -R user:group dir/    # recursive

# USERS & GROUPS
useradd -m username         # create user
passwd username             # set password
groupadd groupname          # create group
usermod -aG group user      # add to group
id username                 # check user/groups
cat /etc/passwd             # list users
cat /etc/group              # list groups

# DISK & MEMORY
df -h                       # disk usage
du -sh /path                # folder size
free -h                     # memory usage
lsblk                       # block devices

# LVM
pvcreate /dev/loop0         # create physical volume
vgcreate vg-name /dev/loop0 # create volume group
lvcreate -L 500M -n lv-name vg-name  # create logical volume
mkfs.ext4 /dev/vg/lv        # format
mount /dev/vg/lv /mnt/path  # mount
lvextend -L +200M /dev/vg/lv  # extend
resize2fs /dev/vg/lv        # resize filesystem

# NETWORKING
hostname -I                 # your IP
ping -c 4 google.com        # reachability
traceroute google.com       # path
ss -tulpn                   # open ports
dig google.com              # DNS lookup
curl -I https://url         # HTTP check
netstat -an                 # connections
```

---

## TROUBLESHOOTING QUICK REFERENCE

### Service not starting:
```bash
systemctl status myapp
journalctl -u myapp -n 50
systemctl is-enabled myapp
```

### High CPU:
```bash
top
ps aux --sort=-%cpu | head -10
```

### Disk full:
```bash
df -h
du -sh /var/log/* | sort -h | tail -5
```

### Permission denied:
```bash
ls -l file.sh          # check permissions
chmod +x file.sh       # fix execute
sudo chown user file   # fix ownership
```

### Network issue:
```bash
ping 8.8.8.8           # internet?
ping google.com        # DNS?
curl -I https://url    # HTTP?
ss -tulpn | grep :80   # port open?
```

### Can't connect to DB:
```bash
ping 10.0.1.50              # server reachable?
ss -tulpn | grep 3306       # MySQL running?
# check firewall/security group
```


================================================================================
                     DAY-BY-DAY DESCRIPTION (BASIC TO ADVANCE)
================================================================================

## DAY 04 — Processes & Services

What is a Process?

Every command you run on Linux becomes a process. Even your terminal is a process.

  You type: ls -l
  
  Linux creates a process → runs it → shows output → process dies

What is a Service?

A service is a process that runs in the background all the time (like SSH, Nginx, MySQL).

  ps aux               # see ALL running processes
  ps aux | grep sshd   # find specific process
  systemctl status sshd    # is SSH service running?
  systemctl start sshd     # start it
  systemctl stop sshd      # stop it
  systemctl enable sshd    # auto start on reboot
  journalctl -u sshd -n 50 # last 50 log lines

--------------------------------------------------------------------------------

## DAY 05 — Troubleshooting Drill

What is a Runbook?

A runbook is a checklist you follow when something breaks in production.
Like a doctor checklist — check this, then this, then this.

  Step 1: Check memory    → free -h
  Step 2: Check disk      → df -h
  Step 3: Check CPU       → ps aux --sort=-%cpu | head -5
  Step 4: Check logs      → journalctl -u sshd -n 50
  Step 5: Check network   → ss -tulpn

Real example:
  Server is slow →
    free -h   (memory full? → kill big process)
    df -h     (disk full? → delete old logs)
    top       (CPU 100%? → find which process)

--------------------------------------------------------------------------------

## DAY 06 — File Read & Write

The 3 most important symbols:
  >   = write to file     (OVERWRITES everything!)
  >>  = append to file    (adds to end, SAFE)
  |   = pipe output to another command

  echo "Hello" > file.txt      # create + write
  echo "World" >> file.txt     # add new line
  cat file.txt                 # read full file
  head -3 file.txt             # read first 3 lines
  tail -3 file.txt             # read last 3 lines
  tee file.txt                 # write + show on screen

Remember:
  >  is DANGEROUS  → deletes old content
  >> is SAFE       → keeps old content + adds new

--------------------------------------------------------------------------------

## DAY 07 — Linux Filesystem

Linux has one tree — everything starts from /

  /                 ← root of everything
  ├── etc/          ← ALL config files live here
  ├── var/log/      ← ALL log files live here
  ├── home/         ← user folders (alice, bob)
  ├── root/         ← root user home
  ├── tmp/          ← temp files, cleared on reboot
  ├── bin/          ← basic commands (ls, cp, cat)
  └── opt/          ← extra software you install

  ls /etc | head -10           # see config files
  cat /etc/hostname            # server name
  ls /var/log                  # see all logs
  du -sh /var/log/* | sort -h  # which log is biggest?

Rule: When you see an error, always check /var/log first!

--------------------------------------------------------------------------------

## DAY 08 — Cloud Server + Nginx

What is Nginx?

Nginx is a web server. It listens on port 80/443 and serves web pages to browsers.

  Browser → port 80 → Nginx → shows webpage

  sudo yum install nginx -y    # install
  sudo systemctl start nginx   # start
  sudo systemctl enable nginx  # auto-start on reboot
  sudo tail -f /var/log/nginx/access.log   # visitor logs
  sudo tail -f /var/log/nginx/error.log    # error logs

Don't forget: Open port 80 in AWS Security Group!

--------------------------------------------------------------------------------

## DAY 09 — Users & Groups

Simple analogy:
  Users  = employees  (alice, bob, carol)
  Groups = teams      (developers, admins, hr)

  sudo useradd -m alice        # create user with home folder
  sudo passwd alice            # set password
  sudo groupadd developers     # create group
  sudo usermod -aG developers alice   # add alice to team
  id alice                     # see all groups alice belongs to

  # Create shared folder for team
  sudo mkdir -p /opt/dev-project
  sudo chgrp developers /opt/dev-project
  sudo chmod 775 /opt/dev-project

--------------------------------------------------------------------------------

## DAY 10 — File Permissions (chmod)

Think of it like a lock on a door:
  r = can READ the file
  w = can WRITE/edit the file
  x = can EXECUTE/run the file

Format:
  -rwxr-xr--
   ||| ||| └── Others  → r only
   ||| └─────  Group   → r+x
   └─────────  Owner   → r+w+x

Number system:
  r=4, w=2, x=1
  755 = owner(7=rwx) group(5=rx) others(5=rx)
  644 = owner(6=rw)  group(4=r)  others(4=r)

  chmod +x script.sh     # make executable
  chmod 755 script.sh    # rwxr-xr-x
  chmod 644 notes.txt    # rw-r--r--
  chmod 400 key.pem      # r-------- (SSH key)

--------------------------------------------------------------------------------

## DAY 11 — File Ownership (chown & chgrp)

Difference:
  Permissions = WHAT you can do  (read/write/execute)
  Ownership   = WHO owns it      (which user/group)

  ls -l file.txt
  # -rw-r--r--  1  root  root  file.txt
  #                 |     └── Group owner
  #                 └──────── User owner

  sudo chown alice file.txt             # change owner
  sudo chgrp developers file.txt        # change group
  sudo chown alice:developers file.txt  # change both
  sudo chown -R alice:dev mydir/        # change entire folder

Rule: User and group MUST exist before you can assign them!

--------------------------------------------------------------------------------

## DAY 12 — Revision Day

Quick self-check commands:
  ps aux | head -5             # processes
  systemctl status sshd        # service
  free -h && df -h             # memory + disk
  ls -l && chmod 755 file      # permissions
  id alice && groups alice     # user groups
  journalctl -u sshd -n 10    # logs

Top 5 commands for incidents:
  1. ps aux         → what is running?
  2. df -h          → is disk full?
  3. free -h        → is memory full?
  4. journalctl     → what do logs say?
  5. systemctl      → is service running?

--------------------------------------------------------------------------------

## DAY 13 — LVM Storage

What is LVM?
LVM = Logical Volume Manager.
Resize disk storage without stopping the server!

3 layers:
  Physical Volume (PV) = actual hard disk
  Volume Group (VG)    = pool of disks combined
  Logical Volume (LV)  = usable partition from pool

  # Create virtual disk
  sudo dd if=/dev/zero of=/root/disk1.img bs=1M count=800
  sudo losetup -fP /root/disk1.img

  # Build LVM: PV → VG → LV
  sudo pvcreate /dev/loop0
  sudo vgcreate devops-vg /dev/loop0
  sudo lvcreate -L 500M -n app-data devops-vg

  # Format and use
  sudo mkfs.ext4 /dev/devops-vg/app-data
  sudo mount /dev/devops-vg/app-data /mnt/app-data

  # Extend LIVE (no downtime!)
  sudo lvextend -L +200M /dev/devops-vg/app-data
  sudo resize2fs /dev/devops-vg/app-data

--------------------------------------------------------------------------------

## DAY 14 — Networking Fundamentals

Simple networking flow:
  You type google.com
      ↓ DNS converts name to IP
      ↓ TCP connects to IP on port 443
      ↓ HTTP sends "give me the page"
      ↓ Google sends back HTML

  hostname -I                   # your IP address
  ping -c 4 google.com          # is it reachable?
  traceroute google.com         # show every hop/router
  ss -tulpn                     # what ports are open?
  dig google.com                # DNS lookup
  curl -I https://google.com    # HTTP status check
  netstat -an | grep ESTAB      # active connections

HTTP Status Codes:
  200 = OK (success)
  301 = Redirect
  403 = Forbidden
  404 = Not Found
  500 = Server Error

--------------------------------------------------------------------------------

## DAY 15 — DNS, IP, Subnets & Ports

DNS = Phone book of the internet
  google.com → asks DNS → gets 142.250.77.46 → connects

IP Types:
  Private (inside network, NOT internet visible)
    → 10.x.x.x
    → 172.16.x.x to 172.31.x.x
    → 192.168.x.x
  Public → everything else (visible on internet)

Subnetting:
  /24  → 254 usable IPs  (small office)
  /16  → 65,534 IPs      (large company)
  /28  → 14 IPs          (tiny network)

Important Ports:
  22    → SSH      (remote login)
  80    → HTTP     (website)
  443   → HTTPS    (secure website)
  53    → DNS      (name lookup)
  3306  → MySQL    (database)
  6379  → Redis    (cache)
  27017 → MongoDB  (NoSQL)

--------------------------------------------------------------------------------

## OVERALL SUMMARY

  Day 04 → See what is running on Linux
  Day 05 → Troubleshoot like a DevOps engineer
  Day 06 → Read and write files
  Day 07 → Know where everything lives in Linux
  Day 08 → Deploy a web server on cloud
  Day 09 → Manage users and teams
  Day 10 → Control who can read/write/run files
  Day 11 → Control who owns files
  Day 12 → Revision of all above
  Day 13 → Manage disk storage flexibly
  Day 14 → Check and troubleshoot network
  Day 15 → Understand DNS, IPs, ports deeply

================================================================================
