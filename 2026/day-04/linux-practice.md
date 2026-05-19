# Day 04 - Linux Practice: Processes and Services

## Process Checks

### 1. Check Running Processes

```bash
ps aux | head
```

**Observation:**  
Displays currently running processes and resource usage.

---

### 2. Monitor Live Processes

```bash
top
```

**Observation:**  
Shows real-time CPU and memory usage.

---

## Service Checks

### 3. Check SSH Service Status

```bash
systemctl status ssh
```

**Observation:**  
Verified SSH service is active and running.

---

### 4. List Running Services

```bash
systemctl list-units --type=service --state=running
```

**Observation:**  
Listed all active running services.

---

## Log Checks

### 5. View SSH Service Logs

```bash
journalctl -u ssh
```

**Observation:**  
Checked SSH startup and service logs.

---

### 6. View Recent System Logs

```bash
tail -n 10 /var/log/syslog
```

**Observation:**  
Reviewed recent system events and warnings.

---

## Mini Troubleshooting Workflow

### Scenario
SSH service troubleshooting.

### Step 1: Check Service Status

```bash
systemctl status ssh
```

### Step 2: Restart SSH Service

```bash
sudo systemctl restart ssh
```

### Step 3: Check Logs

```bash
journalctl -u ssh -n 10
```

### Step 4: Verify Service Status

```bash
systemctl is-active ssh
```

### Result

SSH service is active and functioning properly.

---

## Key Learnings

- Practiced Linux process monitoring
- Learned service management using `systemctl`
- Explored logs using `journalctl` and `tail`
- Understood a basic troubleshooting workflow

---
