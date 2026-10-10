
## 5. Filling a small filesystem (loop device, so the real disk is safe)

Ubuntu:
$ sudo fallocate -l 50M /tmp/logtest.img
$ sudo mkfs.ext4 /tmp/logtest.img
$ sudo mkdir -p /mnt/logtest
$ sudo mount -o loop /tmp/logtest.img /mnt/logtest
$ df -h /mnt/logtest
/dev/loop20      43M   24K   40M   1% /mnt/logtest

$ dd if=/dev/zero of=/mnt/logtest/filler.bin bs=1M count=35
dd: failed to open '/mnt/logtest/filler.bin': Permission denied
$ ls -ld /mnt/logtest
drwxr-xr-x 3 root root 4096 Oct  7 03:05 /mnt/logtest
(a fresh filesystem is owned by root, so I needed sudo)

$ sudo dd if=/dev/zero of=/mnt/logtest/filler.bin bs=1M count=35
35+0 records in
35+0 records out
36700160 bytes (37 MB, 35 MiB) copied, 0.0165561 s, 2.2 GB/s
$ df -h /mnt/logtest
/dev/loop20      43M   36M  4.4M  90% /mnt/logtest

$ sudo dd if=/dev/zero of=/mnt/logtest/filler2.bin bs=1M count=10
dd: error writing '/mnt/logtest/filler2.bin': No space left on device
7+0 records in
6+0 records out
6291456 bytes (6.3 MB, 6.0 MiB) copied, 0.00314147 s, 2.0 GB/s
$ df -h /mnt/logtest
/dev/loop20      43M   42M     0 100% /mnt/logtest

dd fails loudly. The 7 in / 6 out shows the last block was cut short.

$ echo "test log entry at $(date)" >> /mnt/logtest/app.log
bash: /mnt/logtest/app.log: Permission denied
$ sudo bash -c 'echo "test log entry at $(date)" >> /mnt/logtest/app.log'
$ echo "exit status: $?"
exit status: 0
$ cat /mnt/logtest/app.log
test log entry at Wed Oct  7 03:13:14 AM CDT 2026
$ df -h /mnt/logtest
/dev/loop20      43M   42M     0 100% /mnt/logtest

df said 0 available, and root could still write. (I used bash -c because
with plain sudo echo the >> would still run as my user.)

$ sudo tune2fs -l /dev/loop20 | grep -E 'Reserved block count|Reserved block percentage|Block count|Block size'
Block count:              12800
Reserved block count:     640
Block size:               4096

640 / 12800 = 5%. ext4 holds that back for root.

Rocky, same steps:
$ sudo mkfs.ext4 /tmp/logtest.img
mke2fs 1.47.1 (20-May-2024)
Creating filesystem with 51200 1k blocks and 12824 inodes
$ df -h /mnt/logtest
/dev/loop0       42M   14K   39M   1% /mnt/logtest
$ sudo tune2fs -l /dev/loop0 | grep -E 'Reserved block count|Block count|Block size'
Block count:              51200
Reserved block count:     2560
Block size:               1024

2560 / 51200 = 5%. Block sizes differ (4096 vs 1024) but both reserve
the same amount: 640 x 4096 = 2560 x 1024 = 2,621,440 bytes (about 2.5 MiB).

$ sudo dd if=/dev/zero of=/mnt/logtest/filler.bin bs=1M count=37
37+0 records in
37+0 records out
38797312 bytes (39 MB, 37 MiB) copied, 0.0305519 s, 1.3 GB/s
$ df -h /mnt/logtest
/dev/loop0       42M   38M  1.4M  97% /mnt/logtest

$ sudo dd if=/dev/zero of=/mnt/logtest/filler2.bin bs=1M count=5
dd: error writing '/mnt/logtest/filler2.bin': No space left on device
4+0 records in
3+0 records out
4018176 bytes (4.0 MB, 3.8 MiB) copied, 0.00407981 s, 985 MB/s
$ df -h /mnt/logtest
/dev/loop0       42M   41M     0 100% /mnt/logtest

$ sudo bash -c 'echo "test log entry at $(date)" >> /mnt/logtest/app.log'
bash: line 1: echo: write error: No space left on device
$ echo "exit status: $?"
exit status: 1

This is different from Ubuntu. The same root write failed here.

$ stat -f /mnt/logtest
Blocks: Total: 42851      Free: 1024       Available: 0
Inodes: Total: 12824      Free: 12810
$ sudo tune2fs -l /dev/loop0 | grep -E 'Block count|Free blocks|Reserved block count|Block size'
Block count:              51200
Reserved block count:     2560
Free blocks:              42837
Block size:               1024
$ stat -f -c 'block_size=%S free=%f available=%a' /mnt/logtest
block_size=1024 free=1024 available=0

stat -f says 1024 blocks free (1 MiB) and 0 available. tune2fs says
42837 free blocks, which is far off. tune2fs reads the superblock on disk
and can be stale while the filesystem is mounted, so I trust stat -f.

The root write failed with about 1 MiB free. I think ext4 needs a bit of
extra space for its own bookkeeping (journal, inode update), but I did
not prove that.

## 6. Log rotation (Ubuntu only)

$ cat /etc/logrotate.d/rsyslog
/var/log/syslog
/var/log/mail.log
/var/log/kern.log
/var/log/auth.log
/var/log/user.log
/var/log/cron.log
{
	rotate 4
	weekly
	missingok
	notifempty
	compress
	delaycompress
	sharedscripts
	postrotate
		/usr/lib/rsyslog/rsyslog-rotate
	endscript
}
$ cat /usr/lib/rsyslog/rsyslog-rotate
#!/bin/sh

if [ -d /run/systemd/system ]; then
    systemctl kill -s HUP rsyslog.service
fi

A rename keeps the inode, so rsyslog keeps writing into the renamed file
until it gets SIGHUP and reopens its log files.

Test in /tmp/rotatelab with my own config (rotate 1, missingok):
$ ls -li
1704006 -rw-rw-r-- 1 ubuntulab ubuntulab 77 Oct  7 22:47 app.log
1704007 -rw-rw-r-- 1 ubuntulab ubuntulab 54 Oct  7 22:47 rotate.conf

$ /usr/sbin/logrotate -s /tmp/rotatelab/state -f /tmp/rotatelab/rotate.conf
$ ls -li
1704006 -rw-rw-r-- 1 ubuntulab ubuntulab 77 Oct  7 22:47 app.log.1
1704007 -rw-rw-r-- 1 ubuntulab ubuntulab 54 Oct  7 22:47 rotate.conf
1704009 -rw-r----- 1 ubuntulab ubuntulab 73 Oct  7 23:13 state

app.log.1 kept inode 1704006, so rotation was a rename. There was no
new app.log because my config had no create line.

$ echo '03:00 normal operation' >> app.log
$ /usr/sbin/logrotate -s /tmp/rotatelab/state -f /tmp/rotatelab/rotate.conf
$ ls -li
1704008 -rw-rw-r-- 1 ubuntulab ubuntulab 23 Oct  7 23:22 app.log.1
1704007 -rw-rw-r-- 1 ubuntulab ubuntulab 54 Oct  7 22:47 rotate.conf
1704006 -rw-r----- 1 ubuntulab ubuntulab 72 Oct  7 23:22 state
$ cat app.log.1
03:00 normal operation
$ grep INCIDENT app.log.1 || echo "INCIDENT line: not found"
INCIDENT line: not found

The second rotation deleted the file with the INCIDENT line, with no
warning. The freed inode 1704006 became the state file.

Fixed config (rotate-fixed.conf):
/tmp/rotatelab/app.log {
    rotate 4
    weekly
    missingok
    notifempty
    create
    compress
    delaycompress
}

Five forced rotations, starting from a file with the INCIDENT line
(listing trimmed to the rotated copies):
--- after rotation 1 ---
1704010 app.log 0 bytes
1704006 app.log.1 77 bytes
app.log.1                       (INCIDENT is here)
--- after rotation 2 ---
1704008 app.log.2.gz 77 bytes
app.log.2.gz                    (INCIDENT is here, new inode after gzip)
--- after rotation 3 ---
1704008 app.log.3.gz 77 bytes
app.log.3.gz
--- after rotation 4 ---
1704008 app.log.4.gz 77 bytes
app.log.4.gz
--- after rotation 5 ---
INCIDENT: gone

With rotate 4 the data survived 4 rotations and was deleted on the 5th.
create made a new empty app.log after every rotation.

## 7. Cleanup (both boxes)

$ sudo umount /mnt/logtest
$ sudo rmdir /mnt/logtest
$ sudo rm -f /tmp/logtest.img
$ rm -rf /tmp/rotatelab
$ df -h | grep logtest || echo "no logtest mounts left"
no logtest mounts left
