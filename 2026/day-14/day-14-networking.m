# DAY 14 — Networking Fundamentals

### What it is:

Core networking commands every DevOps engineer uses for troubleshooting.

### OSI Model (Simple):

```text
Layer 7 - Application   → HTTP, HTTPS, DNS, SSH
Layer 4 - Transport     → TCP (reliable), UDP (fast)
Layer 3 - Network       → IP address routing
Layer 1 - Physical      → Cable, WiFi
```

### Key Commands:

```bash
hostname -I                     # your IP address
ip addr show                    # full network interface info

ping -c 4 google.com            # check if host reachable
traceroute google.com           # show full path to destination

ss -tulpn                       # all open ports + services
netstat -an | head              # all connections snapshot

dig google.com                  # DNS lookup
nslookup google.com             # alternate DNS lookup

curl -I https://google.com      # HTTP header check
```

### Practice Output:

```text
Server IP: 172.31.38.193 (private - AWS)
ping google.com → 0% loss, 2.33ms latency
Port 22 → sshd (SSH) listening
dig → google.com = 142.250.143.101
curl -I → HTTP/2 301 redirect
```

### Troubleshooting Order:

```text
1. ping 8.8.8.8        → internet working?
2. ping google.com     → DNS working?
3. curl -I https://url → website working?
4. ss -tulpn           → port open?
5. traceroute url      → where breaking?
```
