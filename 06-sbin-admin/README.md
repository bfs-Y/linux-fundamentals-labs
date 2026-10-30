# /sbin - System Administration Tools

Admin commands that usually need root. Core tools for managing users, network, filesystems, and services.

## The Split

On both of my VMs /bin is a symlink to usr/bin and /sbin is a symlink to
usr/sbin, so they are the same folders under two names. The split is a
convention: bin for everyday commands, sbin for admin ones. useradd, fsck
and mkfs.ext4 are in /usr/sbin on both VMs. I haven't tested what is
available in an emergency shell.

## What's in /sbin

**User Management:**
- useradd, userdel, usermod
- groupadd, groupdel
- passwd (sometimes here, sometimes /bin)

**Network:**
- ip, ifconfig, route (ifconfig was in /usr/sbin on Rocky and missing on Ubuntu; I didn't check route)
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
