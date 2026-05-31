## DAY 10 — File Permissions (chmod)

### What it is:
Understand and change file permissions (read/write/execute) for owner, group, others.

### Permission Format:
```
-rwxr-xr--
 │││ │││ │││
 │││ │││ └── Others (r only)
 │││ └─────  Group  (r+x)
 └─────────  Owner  (r+w+x)

r = read    (4)
w = write   (2)
x = execute (1)
```

### Key Commands:
```bash
ls -l file.txt                  # check permissions
chmod +x script.sh              # add execute for all
chmod -w devops.txt             # remove write for all
chmod 755 script.sh             # rwxr-xr-x
chmod 644 notes.txt             # rw-r--r--
chmod 640 secrets.txt           # rw-r-----
chmod 444 readonly.txt          # r--r--r--
chmod -R 755 myfolder/          # recursive
```

### Common Permission Numbers:
```
777 → rwxrwxrwx (everyone full access - dangerous!)
755 → rwxr-xr-x (owner full, others read+execute)
644 → rw-r--r-- (owner rw, others read only)
640 → rw-r----- (owner rw, group read, others nothing)
600 → rw------- (owner rw only, no one else)
400 → r-------- (read only for owner)
```

### Practice Output:
```
devops.txt  → r--r--r-- (444 = read only)
notes.txt   → rw-r----- (640)
script.sh   → rwxr-xr-x (755 = executable)
project/    → rwxr-xr-x (755 = standard dir)
```

---
