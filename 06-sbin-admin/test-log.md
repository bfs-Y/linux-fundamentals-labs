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
