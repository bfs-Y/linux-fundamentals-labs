# Test Log - /sbin System Administration

Feb 24, 2026

## Drill 01: Tool Inventory

Ubuntu container. Checked /sbin vs /bin.

Created regular user. Tried useradd as that user.

Got: "Permission denied. cannot lock /etc/passwd"

Proved /sbin tools need root.

Result: PASS

---

## Drill 02: User Management

Created users with useradd -m.

Set passwords with passwd and chpasswd.

Modified shells with usermod -s.

Added users to groups with usermod -aG.

Deleted users with userdel -r (removes home too).

All commands worked. User management clear.

Result: PASS

---

## Drill 03: Filesystem Operations

Created disk image with dd.

Made ext4 filesystem with mkfs.ext4.

Mounted it. Used it. Unmounted it.

Also tried FAT32 with mkfs.vfat.

fsck checked for errors (none found).

Learned: Always unmount before removing or corruption happens.

Result: PASS

---

## Drill 04: Service Management

Used systemctl to start/stop/enable/disable services.

Checked status with systemctl status.

Viewed logs with journalctl -u.

Created simple test.service file.

Learned daemon-reload needed after editing services.

Result: PASS

---

## Drill 05: System Audit

Ran security checks:
- Found users with UID 0 (only root, good)
- Checked for empty passwords (none)
- Listed SUID binaries
- Checked failed services
- Found world-writable files

Created audit.sh script to automate checks.

Learned what red flags to look for.

Result: PASS

---

## 5/5 passed

Key takeaways:
- /sbin tools need root for most operations
- useradd/usermod/userdel manage users
- mkfs/mount/umount handle filesystems
- systemctl controls services on modern Linux
- Regular audits catch security issues

/sbin = admin tools. Different from /bin (user tools) but same emergency shell availability.

## 06-A /bin and /sbin on both VMs (2026-10-30)

I ran this one on the two VMs (Ubuntu 24.04 and Rocky 10).

$ ls -ld /bin /sbin /usr/bin /usr/sbin
Ubuntu:
lrwxrwxrwx 1 root root     7 Apr 22  2024 /bin -> usr/bin
lrwxrwxrwx 1 root root     8 Apr 22  2024 /sbin -> usr/sbin
drwxr-xr-x 2 root root 40960 Oct 27 00:01 /usr/bin
drwxr-xr-x 2 root root 20480 Oct 27 00:01 /usr/sbin
Rocky:
lrwxrwxrwx. 1 root root     7 Apr  1  2025 /bin -> usr/bin
lrwxrwxrwx. 1 root root     8 Apr  1  2025 /sbin -> usr/sbin
dr-xr-xr-x. 2 root root 40960 Oct 29 13:02 /usr/bin
dr-xr-xr-x. 2 root root 16384 Oct 29 13:01 /usr/sbin

/bin and /sbin are symlinks into /usr on both machines.

$ command -v ifconfig ip useradd fsck mkfs.ext4; echo "exit: $?"
Ubuntu:
/usr/sbin/ip
/usr/sbin/useradd
/usr/sbin/fsck
/usr/sbin/mkfs.ext4
exit: 0
Rocky:
/usr/sbin/ifconfig
/usr/sbin/ip
/usr/sbin/useradd
/usr/sbin/fsck
/usr/sbin/mkfs.ext4
exit: 0

ifconfig is there on Rocky and missing on Ubuntu. The exit code was 0 on
Ubuntu even though ifconfig printed nothing, so I can't use the exit code
of command -v to tell if every name was found.

$ echo "$PATH" | tr ':' '\n' | grep -n 'bin'
Ubuntu:
1:/usr/local/sbin
2:/usr/local/bin
3:/usr/sbin
4:/usr/bin
5:/sbin
6:/bin
9:/snap/bin
10:/snap/bin
Rocky:
1:/home/bfs/.local/bin
2:/home/bfs/bin
3:/usr/local/bin
4:/usr/local/sbin
5:/usr/bin
6:/usr/sbin

A regular user's PATH already includes /usr/sbin on both machines.

$ sudo sh -c 'echo "root PATH: $PATH"'
Ubuntu: root PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
Rocky:  root PATH: /sbin:/bin:/usr/sbin:/usr/bin

The PATH under sudo differs between the two distros, and on Rocky it has
no /usr/local folders. I haven't tested what that does to a command saved
in /usr/local/bin.
