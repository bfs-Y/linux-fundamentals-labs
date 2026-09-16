# Drill 03: Filesystem Operations

Time: 10 minutes

## What You're Doing

Using /sbin tools to work with filesystems and disks.

## Start Container with Privileges
```bash
docker run -it --rm --privileged ubuntu:22.04 /bin/bash
apt update && apt install -y e2fsprogs dosfstools
```

Need --privileged for disk operations.

## Check Available Disks
```bash
lsblk
```

Shows block devices (disks and partitions).
```bash
blkid
```

Shows disk UUIDs and filesystem types.

## Create a Test Disk Image

Can't format real disks in container. Make a file that acts like a disk:
```bash
dd if=/dev/zero of=/tmp/test.img bs=1M count=100
```

Creates 100MB file filled with zeros.

Check it:
```bash
ls -lh /tmp/test.img
```

Should show ~100M.

## Create Filesystem on It

Make ext4 filesystem:
```bash
mkfs.ext4 /tmp/test.img
```

Shows output about creating filesystem.

Check what filesystem type it is:
```bash
file /tmp/test.img
```

Shows: "Linux rev 1.0 ext4 filesystem"

## Mount It

Create mount point:
```bash
mkdir /mnt/test
```

Mount the image:
```bash
mount /tmp/test.img /mnt/test
```

Verify:
```bash
df -h | grep test
mount | grep test
```

Shows it's mounted at /mnt/test.

## Use It
```bash
cd /mnt/test
echo "test data" > file.txt
ls -la
cat file.txt
```

Works like a normal directory. But it's actually on the disk image.

## Unmount
```bash
cd /
umount /mnt/test
```

Check:
```bash
mount | grep test
```

Should show nothing (unmounted).

## Check Filesystem
```bash
fsck /tmp/test.img
```

Checks filesystem for errors. Should show clean.

## Create Different Filesystem Type

Make FAT32 (like USB drives):
```bash
dd if=/dev/zero of=/tmp/usb.img bs=1M count=50
mkfs.vfat /tmp/usb.img
```

Mount it:
```bash
mkdir /mnt/usb
mount /tmp/usb.img /mnt/usb
df -h | grep usb
```

Different filesystem type, same mount process.

## Disk Space Check
```bash
df -h
```

Shows all mounted filesystems and space usage.
```bash
du -sh /var
```

Shows how much space /var uses.

## Cleanup
```bash
umount /mnt/test
umount /mnt/usb
rm /tmp/test.img /tmp/usb.img
exit
```

## Key Commands
```
lsblk              # List disks
blkid              # Show disk UUIDs
mkfs.ext4 device   # Create ext4 filesystem
mkfs.vfat device   # Create FAT filesystem
mount device dir   # Mount filesystem
umount dir         # Unmount filesystem
fsck device        # Check filesystem
df -h              # Show disk space
```

## Real World Usage

Check disk before mounting:
```bash
lsblk
blkid /dev/sdb1
```

Mount USB drive:
```bash
mount /dev/sdb1 /mnt/usb
```

Safely unmount:
```bash
umount /mnt/usb
```

Check for errors:
```bash
fsck /dev/sdb1
```

## Key Lesson

/sbin filesystem tools let you format, mount, and manage disks.

Always unmount before removing drives or filesystem corruption can happen.
