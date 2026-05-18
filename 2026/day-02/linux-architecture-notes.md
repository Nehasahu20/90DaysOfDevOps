# Day 2  Linux Architecture Notes

## Core Components of Linux

### 1. Kernel
- Core part of Linux OS
- Manages CPU, memory, devices, and processes
- Works as a bridge between hardware and software

### 2. User Space
- Area where user applications run
- Examples: browser, terminal, editors
- Cannot directly access hardware

### 3. init/systemd
- First process started during boot
- Manages services and background processes
- Used to start, stop, and monitor services

---

# Process Management

## What is a Process?
- A running program is called a process
- Every process has a unique PID (Process ID)

## Process States
- Running → currently executing
- Sleeping → waiting for input/resource
- Stopped → paused process
- Zombie → completed but still listed

## Useful Commands
- ps → show running processes
- top → real-time process monitoring
- kill → stop a process
- systemctl status nginx → check service status
- journalctl -u nginx → view service logs

---

# Why systemd Matters
- Starts services automatically during boot
- Restarts failed services
- Helps manage logs and system services
- Important for troubleshooting in DevOps
