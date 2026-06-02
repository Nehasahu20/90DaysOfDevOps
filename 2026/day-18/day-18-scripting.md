
## Day 18 — Shell Scripting: Functions & Intermediate Concepts

### What You Learn
- Write reusable functions
- Use strict mode `set -euo pipefail`
- Use local variables inside functions

---

### Task 1 — Basic Functions

```bash
#!/bin/bash

greet() {
  echo "Hello, $1!"
}

add() {
  echo "Sum: $(($1 + $2))"
}

# Read from console
read -p "Enter your name: " NAME
read -p "Enter first number: " NUM1
read -p "Enter second number: " NUM2

greet "$NAME"
add "$NUM1" "$NUM2"
```

**Practice:**
```bash
bash functions.sh
# Enter your name: Neha
# Enter first number: 10
# Enter second number: 20
# Hello, Neha!
# Sum: 30
```

---

### Task 2 — Functions with Return Values

```bash
#!/bin/bash

check_disk() {
  echo "--- Disk Usage ---"
  df -h /
}

check_memory() {
  echo "--- Memory Usage ---"
  free -h
}

check_disk
check_memory
```

**Practice:**
```bash
bash disk_check.sh
df -h /
free -h
```

---

### Task 3 — Strict Mode `set -euo pipefail`

```bash
#!/bin/bash
set -euo pipefail
```

| Flag | What it does |
|------|-------------|
| `set -e` | Stop script if any command fails |
| `set -u` | Stop if undefined variable is used |
| `set -o pipefail` | Stop if any command in a pipe fails |

**Practice:**
```bash
# Test set -e
cat << 'EOF' > strict_demo.sh
#!/bin/bash
set -e
echo "Step 1"
cat /file_not_exist      # fails here
echo "Step 2 — never runs"
EOF
bash strict_demo.sh

# Test set -u
cat << 'EOF' > strict_demo.sh
#!/bin/bash
set -u
echo "$UNDEFINED_VAR"   # crashes: unbound variable
EOF
bash strict_demo.sh
```

---

### Task 4 — Local Variables

```bash
#!/bin/bash

func1() {
  local X="inside_only"
  echo "Inside function: $X"
}

func1
echo "Outside function: ${X:-not visible}"
```

**Practice:**
```bash
bash local_demo.sh
# Inside function: inside_only
# Outside function: not visible
```

---

### Task 5 — System Info Reporter

```bash
#!/bin/bash
set -euo pipefail

host_info()   { echo "=== Host ==="; hostname; }
uptime_info() { echo "=== Uptime ==="; uptime; }
disk_info()   { echo "=== Disk ==="; df -h /; }
mem_info()    { echo "=== Memory ==="; free -h; }
cpu_info()    { echo "=== Top 5 CPU ==="; ps aux --sort=-%cpu | head -6; }

main() {
  host_info
  uptime_info
  disk_info
  mem_info
  cpu_info
}

main
```

**Practice:**
```bash
bash system_info.sh
```

---

### Day 18 — Key Learnings

1. Function syntax: `function_name() { ... }`
2. Pass args to functions: `greet "Neha"` → access as `$1` inside
3. `local` keeps variables inside the function only
4. `set -euo pipefail` at top makes every script safe

---



