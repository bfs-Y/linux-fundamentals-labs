# Drill 01: /sbin Tool Inventory

Time: 5 minutes

## What You're Doing

Checking what admin tools exist in /sbin and testing which ones need root.

## Start Container
```bash
docker run -it --rm ubuntu:22.04 /bin/bash
```

## Count What's Where
```bash
ls /sbin | wc -l
ls /bin | wc -l
```

/sbin usually has fewer commands than /bin. These are specialized admin tools.

## See What's in /sbin
```bash
ls /sbin
```

Look for familiar ones:
- useradd, usermod, userdel
- ip, ifconfig, route
- fsck, mkfs
- reboot, shutdown

## Test Some Tools as Root
```bash
useradd testuser
id testuser
userdel testuser
```

Works. You're root.

## Create Regular User and Test
```bash
useradd -m normaluser
su - normaluser
```

Now try:
```bash
useradd hacker
```

Should fail: "Permission denied" or "Operation not permitted"

Why? Regular users can't create users. Too dangerous.

Try more:
```bash
reboot
```

Fails. Can't reboot system as regular user.
```bash
/sbin/ip link show
```

This one works. Reading network info doesn't need root.
```bash
/sbin/ip link set eth0 down
```

This fails. Changing network needs root.

## Back to Root
```bash
exit
```

## Check Which /sbin Tools Work Without Root

Some /sbin tools just read info:
```bash
blkid  # Shows disk IDs (might work)
lsblk  # Lists block devices (usually works)
ip link show  # Shows network (works)
```

Others modify system (need root):
```bash
useradd  # Creates users (fails)
mkfs  # Formats disk (fails)
ip link set  # Changes network (fails)
reboot  # Reboots system (fails)
```

## The Pattern

/sbin tools that READ: Often work without root
/sbin tools that WRITE/CHANGE: Need root

## Exit
```bash
exit
```

## Key Lesson

/sbin = system admin tools.

Most need root because they change critical system state.

Some work without root if they just read info.
