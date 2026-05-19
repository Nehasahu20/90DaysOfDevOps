# Linux Commands Cheat Sheet

A quick-reference guide for commonly used Linux commands with meanings and examples.

---

# 1. Process Management Commands

| Command | Meaning / Purpose | Example |
|---|---|---|
| `ps aux` | Show all running processes | `ps aux` |
| `top` | Real-time system monitoring | `top` |
| `htop` | Better interactive process viewer | `htop` |
| `ps aux \| grep nginx` | Find a specific process | `ps aux \| grep mysql` |
| `kill PID` | Stop a process gracefully | `kill 1234` |
| `kill -9 PID` | Force kill a process | `kill -9 1234` |
| `jobs` | Show background jobs | `jobs` |
| `bg %1` | Run a job in background | `bg %1` |
| `fg %1` | Bring job to foreground | `fg %1` |
| `free -h` | Show memory usage | `free -h` |
| `uptime` | Show system uptime/load | `uptime` |
| `df -h` | Show disk space usage | `df -h` |
| `du -sh folder/` | Show folder size | `du -sh Downloads/` |

---

# 2. File System Commands

## Navigation

| Command | Meaning / Purpose | Example |
|---|---|---|
| `pwd` | Show current directory | `pwd` |
| `ls` | List files and folders | `ls` |
| `ls -la` | Detailed file listing | `ls -la` |
| `cd folder` | Change directory | `cd Documents` |
| `cd ..` | Move one folder back | `cd ..` |
| `clear` | Clear terminal screen | `clear` |

---

## File & Directory Operations

| Command | Meaning / Purpose | Example |
|---|---|---|
| `touch file.txt` | Create a new file | `touch notes.txt` |
| `mkdir folder` | Create a directory | `mkdir project` |
| `rm file.txt` | Delete a file | `rm notes.txt` |
| `rm -rf folder` | Delete folder recursively | `rm -rf oldproject` |
| `cp file1 file2` | Copy file | `cp a.txt b.txt` |
| `mv old new` | Move or rename file | `mv old.txt new.txt` |

---

## File Viewing Commands

| Command | Meaning / Purpose | Example |
|---|---|---|
| `cat file.txt` | Display full file content | `cat notes.txt` |
| `less file.txt` | View large files page-wise | `less server.log` |
| `head file.txt` | Show first 10 lines | `head data.txt` |
| `tail file.txt` | Show last 10 lines | `tail data.txt` |
| `tail -f app.log` | Live log monitoring | `tail -f nginx.log` |

---

## File Permissions

| Command | Meaning / Purpose | Example |
|---|---|---|
| `chmod +x script.sh` | Make file executable | `chmod +x run.sh` |
| `chmod 777 file` | Give full permissions | `chmod 777 test.txt` |
| `chown user:user file` | Change ownership | `chown ubuntu:ubuntu app.txt` |

---

# 3. Networking Troubleshooting Commands

## Connectivity Testing

| Command | Meaning / Purpose | Example |
|---|---|---|
| `ping google.com` | Test internet connectivity | `ping github.com` |
| `curl URL` | Fetch webpage/API response | `curl https://example.com` |
| `wget URL` | Download files | `wget file-link.zip` |

---

## DNS Commands

| Command | Meaning / Purpose | Example |
|---|---|---|
| `nslookup google.com` | Check DNS records | `nslookup openai.com` |
| `dig google.com` | Detailed DNS lookup | `dig github.com` |

---

## Network Information

| Command | Meaning / Purpose | Example |
|---|---|---|
| `ip a` | Show IP addresses | `ip a` |
| `ip route` | Show routing table | `ip route` |
| `hostname -I` | Display local IP | `hostname -I` |

---

## Port & Connection Commands

| Command | Meaning / Purpose | Example |
|---|---|---|
| `netstat -tulnp` | Show open ports | `netstat -tulnp` |
| `ss -tulnp` | Modern port checking tool | `ss -tulnp` |
| `lsof -i :8080` | Check process on a port | `lsof -i :3000` |

---

## Remote Access

| Command | Meaning / Purpose | Example |
|---|---|---|
| `ssh user@ip` | Connect to remote server | `ssh ubuntu@192.168.1.10` |
| `scp file user@ip:/path` | Copy file to server | `scp app.zip ubuntu@server:/tmp` |

---

## Network Diagnostics

| Command | Meaning / Purpose | Example |
|---|---|---|
| `traceroute google.com` | Trace network path | `traceroute github.com` |
| `mtr google.com` | Real-time network diagnostics | `mtr google.com` |

---

# 4. Search & Utility Commands

| Command | Meaning / Purpose | Example |
|---|---|---|
| `find / -name file.txt` | Search for files | `find / -name notes.txt` |
| `locate file.txt` | Quickly locate files | `locate config.php` |
| `grep "text" file` | Search inside file | `grep "error" app.log` |
| `grep -r "TODO" .` | Recursive text search | `grep -r "api" .` |
| `history` | Show command history | `history` |
| `man ls` | Open command manual | `man grep` |

---

# 5. Archive & Compression Commands

| Command | Meaning / Purpose | Example |
|---|---|---|
| `tar -czvf file.tar.gz folder/` | Compress folder | `tar -czvf backup.tar.gz project/` |
| `tar -xzvf file.tar.gz` | Extract compressed file | `tar -xzvf backup.tar.gz` |
| `zip file.zip file.txt` | Create zip archive | `zip notes.zip notes.txt` |
| `unzip file.zip` | Extract zip file | `unzip notes.zip` |

---

# Useful Shortcuts

| Shortcut | Purpose |
|---|---|
| `Ctrl + C` | Stop running command |
| `Ctrl + Z` | Pause current process |
| `Ctrl + R` | Search command history |
| `TAB` | Auto-complete command |
| `clear` | Clear terminal screen |

