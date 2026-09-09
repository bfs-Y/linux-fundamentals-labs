# /sbin - System Administration Tools

Admin commands that usually need root. Core tools for managing users, network, filesystems, and services.

## The Split

/bin - Regular user commands (ls, cat, grep)
/sbin - System admin commands (useradd, ifconfig, fsck)

Both available in emergency shell. Both critical for recovery.

## What's in /sbin

**User Management:**
- useradd, userdel, usermod
- groupadd, groupdel
- passwd (sometimes here, sometimes /bin)

**Network:**
- ip, ifconfig, route
- iptables, ip6tables
- arp

**Filesystem:**
- mkfs, mkfs.ext4, mkfs.vfat
- fsck, fsck.ext4
- blkid, lsblk
- mount, umount (sometimes in /bin)

**System:**
- reboot, halt, poweroff, shutdown
- init, runlevel
- modprobe, insmod, rmmod

**Services:**
- service (older systems)
- systemctl links here on some distros

## Why These Need Root

User management: Modify /etc/passwd, /etc/shadow
Network config: Change system network state
Filesystem: Format disks, check filesystems (destructive)
System control: Reboot, load kernel modules

Regular users can't do these. Too much power.

## What We're Testing

- Creating and managing users
- Basic network configuration
- Filesystem operations
- Understanding when /sbin tools are needed vs /bin

## Out of Scope

- Advanced networking (separate module later)
- Systemd internals
- Kernel module development
- Complex firewall rules

Focus: Basic /sbin tool usage for system admin tasks.

## Known Gaps

- Limited iptables coverage (just basics)
- Does not cover all filesystem types
- Assumes systemd-based system
