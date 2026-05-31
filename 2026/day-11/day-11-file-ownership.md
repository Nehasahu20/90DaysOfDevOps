## DAY 11 — File Ownership (chown & chgrp)

### What it is:
Change who owns a file (user and group ownership).

### Key Commands:
```bash
ls -l file.txt                  # see owner and group
whoami                          # current user

sudo chown alice file.txt           # change owner to alice
sudo chgrp developers file.txt      # change group to developers
sudo chown alice:developers file.txt  # change both together
sudo chown -R alice:devs mydir/     # recursive (all files inside)
sudo chown :newgroup file.txt       # change only group
```

### Practice Output:
```
access-codes.txt → tokyo:vault-team
blueprints.pdf   → berlin:tech-team
escape-plan.txt  → nairobi:vault-team
```

### Rules:
- User must EXIST before chown
- Group must EXIST before chgrp/chown
- Need sudo for chown operations
- -R flag changes everything recursively

---
