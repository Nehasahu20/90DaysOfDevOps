# Linux Troubleshooting Runbook

## Target Service / Process

**Service Chosen:** SSH (`ssh.service`)

Purpose: Verify service health, check logs, inspect CPU/memory, disk, and network status.

---

# 1. Environment Basics

### Check System Information

```bash
uname -a
```

**Observation:**  
Verified Linux kernel version and system architecture.

---

```bash
lsb_release -a
```

**Observation:**  
Confirmed Ubuntu distribution and release version.

---

# 2. Filesystem Sanity Checks

### Create Temporary Demo Folder

```bash
mkdir /tmp/runbook-demo
```

**Observation:**  
Temporary troubleshooting directory created successfully.

---

### Copy and Verify File

```bash
cp /etc/hosts /tmp/runbook-demo/hosts-copy
ls -l /tmp/runbook-demo
```

**Observation:**  
Verified file copy operation and checked file permissions.

---

# 3. Snapshot: CPU & Memory

### Monitor Live Resource Usage

```bash
top
```

**Observation:**  
CPU usage remained stable and memory usage was low.

---

### Check Memory Usage

```bash
free -h
```

**Observation:**  
System had enough available memory with no swap pressure.

---

# 4. Snapshot: Disk & IO

### Check Disk Space

```bash
df -h
```

**Observation:**  
Disk usage was under safe limits with enough free space available.

---

### Check Log Directory Size

```bash
du -sh /var/log
```

**Observation:**  
Log directory size was normal and not consuming excessive storage.

---

# 5. Snapshot: Network

### Check Listening Ports

```bash
ss -tulpn
```

**Observation:**  
SSH service was listening on port 22.

---

### Test Local Connectivity

```bash
curl -I http://localhost
```

**Observation:**  
Local service responded successfully.

---

# 6. Logs Reviewed

### Review SSH Logs

```bash
journalctl -u ssh -n 50
```

**Observation:**  
No recent SSH errors found in service logs.

---

### Review System Logs

```bash
tail -n 50 /var/log/syslog
```

**Observation:**  
System logs showed normal activity without critical warnings.

---

# 7. Quick Findings

- SSH service is active and running normally
- CPU and memory usage are stable
- Disk space is healthy
- Network port 22 is listening correctly
- No critical errors found in recent logs

---

# 8. If This Worsens (Next Steps)

1. Restart SSH service:
   ```bash
   sudo systemctl restart ssh
   ```

2. Increase logging and monitor logs continuously:
   ```bash
   journalctl -u ssh -f
   ```

3. Collect deeper diagnostics:
   ```bash
   strace -p <PID>
   ```

---

# Resources

- `man top`
- `man ps`
- `man df`
- `man journalctl`
- `man ss`

---
