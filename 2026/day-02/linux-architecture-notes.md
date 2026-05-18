 # Day 02 – Linux Architecture, Processes, and systemd

## Task

Today’s goal is to understand how Linux works internally and how different components communicate with each other.

This note covers:
- Core components of Linux
- Process management
- Role of systemd
- Important Linux commands used daily in DevOps

---

# 1. Core Components of Linux

## Kernel
The kernel is the core part of the Linux operating system.

It is responsible for:
- Managing CPU and memory
- Handling hardware devices
- Managing running processes
- Connecting software with hardware

Without the kernel, applications cannot communicate with the system hardware.

---

## User Space
User space is where users interact with applications and commands.

Examples:
- Terminal
- Browser
- VS Code
- Shell scripts

- Application running in user space request services from kernel ewhenever they need hardware access.



## systemd (init system)
systemd is the first process started during linux boot.

Process ID of systemd:
'''bash
PId 1
- 
  Main responsibilities:
Starting system services
Managing background processes
Restarting failed services
Handling boot operations
systemd is very important in modern Linux systems.
2. Process Management in Linux
What is a Process?
A process is simply a running program.
Every process has:
PID (Process ID)
Memory allocation
Process state
Common Process States
Running
The process is actively executing.
Sleeping
The process is waiting for input or resources.
Stopped
The process has been paused.
Zombie
The process has completed execution but still exists temporarily in the process table.



Why This Matters in DevOps
Linux is the foundation of most production servers and cloud environments.
Understanding Linux processes and systemd helps DevOps engineers to:
Troubleshoot server issues
Debug failed services
Monitor CPU and memory usage
Analyze logs efficiently
Manage servers confidently
This knowledge is essential for working in real production environments
