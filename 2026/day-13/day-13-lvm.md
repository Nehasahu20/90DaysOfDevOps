## DAY 13 — Linux Volume Management (LVM)

### What it is:
Manage storage flexibly — create, extend volumes without stopping the server.

### LVM Architecture:
```
Physical Disk (PV)  →  Volume Group (VG)  →  Logical Volume (LV)
/dev/loop0          →  devops-vg           →  app-data (500MB)
```

### Key Commands:
```bash
# Check storage
lsblk                           # list block devices
df -h                           # disk usage
pvs                             # list physical volumes
vgs                             # list volume groups
lvs                             # list logical volumes

# Create virtual disk (no spare disk)
sudo dd if=/dev/zero of=/root/disk1.img bs=1M count=800
sudo losetup -fP /root/disk1.img
sudo losetup -a                 # check device name eg: /dev/loop0

# Create PV → VG → LV
sudo pvcreate /dev/loop0
sudo vgcreate devops-vg /dev/loop0
sudo lvcreate -L 500M -n app-data devops-vg

# Format & Mount
sudo mkfs.ext4 /dev/devops-vg/app-data
sudo mkdir -p /mnt/app-data
sudo mount /dev/devops-vg/app-data /mnt/app-data
df -h /mnt/app-data

# Extend (LIVE - no downtime!)
sudo lvextend -L +200M /dev/devops-vg/app-data
sudo resize2fs /dev/devops-vg/app-data
df -h /mnt/app-data
```

### Practice Output:
```
Before extend: 459MB available
After extend:  646MB available  ← grew without unmounting!
```

### LVM Flow:
```
dd (virtual disk)
  ↓ pvcreate  → Physical Volume
  ↓ vgcreate  → Volume Group (pool)
  ↓ lvcreate  → Logical Volume
  ↓ mkfs.ext4 → Format
  ↓ mount     → Ready to use
  ↓ lvextend + resize2fs → Extend LIVE
```

---
