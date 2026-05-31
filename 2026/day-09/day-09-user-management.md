## DAY 09 — User & Group Management

### What it is:
Create users, create groups, assign users to groups, set shared directories.

### Key Commands:
```bash
# Users
sudo useradd -m tokyo           # create user with home dir
sudo passwd tokyo               # set password
sudo userdel tokyo              # delete user
cat /etc/passwd                 # list all users
id tokyo                        # check user info

# Groups
sudo groupadd developers        # create group
sudo groupdel developers        # delete group
cat /etc/group                  # list all groups

# Assign user to group
sudo usermod -aG developers tokyo   # add tokyo to developers
sudo usermod -aG admins,developers berlin  # add to multiple groups
groups tokyo                    # check which groups user is in

# Shared directory
sudo mkdir -p /opt/dev-project
sudo chgrp developers /opt/dev-project
sudo chmod 775 /opt/dev-project

# Test as another user
sudo -u tokyo touch /opt/dev-project/test.txt
```

### Practice Output:
```
id tokyo  → uid=1001(tokyo) gid=1001(tokyo) groups=1001(tokyo),1005(developers)
id berlin → uid=1002(berlin) gid=1002(berlin) groups=1002(berlin),1005(developers),1006(admins)
```

---
