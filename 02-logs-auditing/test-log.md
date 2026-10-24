# Module 02 - Test Log

Run on Ubuntu 24.04 (ubuntulab) and Rocky 10 (rockylab), Oct 7-8 2026.
Output is pasted as it came out. "..." means I cut a long line.

## 1. Does the journal stay on disk?

Ubuntu:
$ ls -ld /var/log/journal
drwxr-sr-x+ 3 root systemd-journal 4096 Jul  7 10:15 /var/log/journal

Rocky:
$ ls -ld /var/log/journal
ls: cannot access '/var/log/journal': No such file or directory

Ubuntu has the folder, so its journal survives reboots. Rocky didn't have
it, so its journal only lived in RAM. The `+` on Ubuntu's listing is an
ACL. Rocky's listing ended in `.` once the folder existed, which is an
SELinux label. Later, ls -ldZ showed drwxr-sr-x+ with the label var_log_t, so an ACL had been added by then (section 4 shows the entries on the journal file).

## 2. Making Rocky keep its journal

$ sudo systemd-tmpfiles --create --prefix /var/log/journal
(no output, and the folder still didn't exist)
$ cat /usr/lib/tmpfiles.d/systemd-journald.conf
cat: /usr/lib/tmpfiles.d/systemd-journald.conf: No such file or directory

I guessed that filename. Searching by path later found the rules:

$ grep -n 'journal' /usr/lib/tmpfiles.d/systemd.conf
27:z /var/log/journal 2755 root systemd-journal - -
28:z /var/log/journal/%m 2755 root systemd-journal - -
29:z /var/log/journal/%m/system.journal 0640 root systemd-journal - -
30:a+ /var/log/journal    - - - - d:group::r-x,d:group:adm:r-x,d:group:wheel:r-x,group::r-x,group:adm:r-x,group:wheel:r-x
31:a+ /var/log/journal/%m - - - - d:group:adm:r-x,d:group:wheel:r-x,group:adm:r-x,group:wheel:r-x
32:a+ /var/log/journal/%m/system.journal - - - - group:adm:r--,group:wheel:r--

Every line for /var/log/journal starts with z or a+. As far as I know
those only adjust a path that already exists, so with no folder the
command had nothing to do. I first wrote here that Rocky ships no rule.
That was wrong. The rules exist, and none I found creates the folder.

I made the folder by hand:

$ sudo mkdir -p /var/log/journal
$ sudo chgrp systemd-journal /var/log/journal
$ sudo chmod 2755 /var/log/journal
$ ls -ld /var/log/journal
drwxr-sr-x. 2 root systemd-journal 6 Oct  7 02:49 /var/log/journal

$ sudo systemctl restart systemd-journald
$ journalctl --flush
Failed to connect to Varlink socket: Permission denied
(this one had no sudo)
$ sudo journalctl --flush
$ ls -l /var/log/journal/
drwxr-sr-x. 2 root systemd-journal 53 Oct  7 03:05 2a31258ae87e4ba79cfbff69801d879a
$ journalctl --disk-usage
Archived and active journals take up 8M in the file system.

The long folder name is the machine ID.

## 3. Reboot test: does a log entry survive?

Ubuntu:
$ sudo journalctl --header --no-pager | grep 'File path'
(files under /var/log/journal/02bd91ae00594185b369f9c7ce5d8123/:
system.journal, user-1000.journal, and many archived .journal and
.journal~ files)
$ sudo journalctl --disk-usage
Archived and active journals take up 420.0M in the file system.
$ echo "TOPIC2-PERSISTENCE-TEST-$(date +%s)" | sudo tee /tmp/topic2-marker
TOPIC2-PERSISTENCE-TEST-1791438359
$ logger -p user.notice "TOPIC2-PERSISTENCE-TEST-1791438359"
$ journalctl -b --no-pager | grep 'TOPIC2-PERSISTENCE-TEST-1791438359'
Oct 08 00:47:23 ubuntulab-Standard-PC-Q35-ICH9-2009 ubuntulab[8225]: TOPIC2-PERSISTENCE-TEST-1791438359
$ journalctl -b --show-cursor --no-pager | tail -1
(the cursor contained b=efb5da6281f847f98d7af7c6e21e9522, the boot ID)
$ sudo reboot
$ journalctl --list-boots --no-pager | tail -3
-1 efb5da6281f847f98d7af7c6e21e9522 ...
 0 73263e14ca504ac08bda91b3331cd892 ...
$ journalctl -b -1 --no-pager | grep 'TOPIC2-PERSISTENCE-TEST-1791438359'
Oct 08 00:47:23 ubuntulab-Standard-PC-Q35-ICH9-2009 ubuntulab[8225]: TOPIC2-PERSISTENCE-TEST-1791438359

Rocky:
$ sudo journalctl --header --no-pager | grep 'File path'
File path: /var/log/journal/2a31258ae87e4ba79cfbff69801d879a/system.journal
File path: /var/log/journal/2a31258ae87e4ba79cfbff69801d879a/user-1000.journal
$ logger -p user.notice "TOPIC2-ROCKY-PERSISTENCE-TEST-$(date +%s)"
(marker: TOPIC2-ROCKY-PERSISTENCE-TEST-1791440721)
$ journalctl -b --no-pager | grep 'TOPIC2-ROCKY-PERSISTENCE-TEST'
Oct 08 02:25:21 rockylab bfs[10788]: TOPIC2-ROCKY-PERSISTENCE-TEST-1791440721
$ sudo journalctl --list-boots --no-pager
0 8bb9c0b7365e48f58976301a4d6417ac ...
$ sudo reboot
$ sudo journalctl --list-boots --no-pager
-1 8bb9c0b7365e48f58976301a4d6417ac ...
 0 6ca5f36ce6e74510888224070c4ea3a8 ...
$ sudo journalctl -b -1 --no-pager | grep 'TOPIC2-ROCKY-PERSISTENCE-TEST-1791440721'
Oct 08 02:25:21 rockylab bfs[10788]: TOPIC2-ROCKY-PERSISTENCE-TEST-1791440721

Both boxes kept the entry across a reboot. Both reboots were a normal
`sudo reboot`, so this says nothing about a crash or power loss.

## 4. Searches that came back empty

Boot counts. The number includes the header line, so subtract 1.

Ubuntu:
$ journalctl --list-boots --no-pager | wc -l
47
$ journalctl --list-boots --no-pager | sed -n '2p'
-45 c856439ac2b84a679f36c29ae042763b Tue 2026-07-07 10:15:31 CDT Tue 2026-07-07 10:21:22 CDT

Rocky:
$ journalctl --list-boots --no-pager | wc -l
2
$ journalctl --list-boots --no-pager | sed -n '2p'
  0 8bb9c0b7365e48f58976301a4d6417ac Wed 2026-10-07 03:05:40 EDT Thu 2026-10-08 00:30:45 EDT

Ubuntu has 46 boots. Rocky had 1, because its journal was in RAM until I
made it persistent.

A Rocky search with no results:
$ journalctl -b --since "2026-10-07 02:30" --until "2026-10-07 03:05" --no-pager
-- No entries --
$ uptime -s; date; timedatectl | grep 'Time zone'
2026-10-07 01:19:50
Thu Oct  8 12:36:27 AM EDT 2026
                Time zone: America/New_York (EDT, -0400)

This boot started at 01:19:50, so the window was inside it. I first
thought the entries had been lost. They hadn't:

$ sudo journalctl --header --no-pager | grep -E 'File path|Head realtime'
File path: /var/log/journal/2a31258ae87e4ba79cfbff69801d879a/system.journal
Head realtime timestamp: Wed 2026-10-07 01:19:52 EDT (65d3943cde314)
File path: /var/log/journal/2a31258ae87e4ba79cfbff69801d879a/user-1000.journal
Head realtime timestamp: Wed 2026-10-07 03:05:40 EDT (65d3abe333c49)
$ sudo journalctl -b --since "2026-10-07 02:30" --until "2026-10-07 03:05" --no-pager | wc -l
300
$ id
uid=1000(bfs) gid=1000(bfs) groups=1000(bfs),10(wheel) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023

The system journal starts at 01:19:52, so the data was there all along.
Without sudo I only saw my own user journal, which starts at 03:05:40.
At the time, bfs was in wheel and not in adm or systemd-journal.

Later, on Rocky:
$ getfacl /var/log/journal/*/system.journal
# file: var/log/journal/2a31258ae87e4ba79cfbff69801d879a/system.journal
# owner: root
# group: systemd-journal
user::rw-
group::r-x			#effective:r--
group:adm:r--
group:wheel:r--
mask::r--
other::---
$ journalctl -b --no-pager | wc -l
2959
$ sudo journalctl -b --no-pager | wc -l
2988

The journal file now has ACL entries for adm and wheel, and a plain
journalctl shows nearly the same count as sudo. I don't know when those
entries appeared, so I can't say they were missing on Oct 7.

Ubuntu, same check:
$ id
uid=1000(ubuntulab) gid=1000(ubuntulab) groups=1000(ubuntulab),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),100(users),114(lpadmin)
$ sudo journalctl --list-boots --no-pager | wc -l
47

ubuntulab is in adm, so it reads everything without sudo (47 either way).
On Rocky, sudo didn't change the boot count (still 2).

The ssh unit name:
$ journalctl -u ssh -n 3 --no-pager
Sep 21 09:00:42 ubuntulab-Standard-PC-Q35-ICH9-2009 sshd[3724]: Received signal 15; terminating.
Sep 21 09:00:42 ubuntulab-Standard-PC-Q35-ICH9-2009 systemd[1]: ssh.service: Deactivated successfully.
Sep 21 09:00:42 ubuntulab-Standard-PC-Q35-ICH9-2009 systemd[1]: Stopped ssh.service - OpenBSD Secure Shell server.
$ journalctl -u sshd -n 3 --no-pager
-- No entries --
$ systemctl is-active ssh
inactive
$ systemctl is-active ssh.socket
active

`-u` matches the unit name (ssh.service), not the process name (sshd).
On Ubuntu the ssh service only starts when something connects, because
ssh.socket listens on port 22. So "inactive" is normal there.


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

### Rocky crash test (2026-10-23)
- logger marker CRASHTEST-ROCKY, sync, then virsh destroy rocky10 (snapshot pre-crash first).
- After boot: marker found in journalctl -b -1 (01:30:53, last second of that boot).
- last -x: reboot at 01:31 with no preceding shutdown line.
- .journal~ count after crash: 4 (no count taken before, so the crash's contribution is unknown).
- Rocky .journal~ files dated 2026-10-23: system@...journal~ 01:29 (24 MiB, larger than the usual 8 MiB, cause not checked) and user-1000@...journal~ 01:30. The other two (2026-10-08) predate the crash.

### Rocky root write at "100%" full (2026-10-24)
- Loop fs ext4 (mkfs.ext4), 1 KiB blocks. After fill: stat -f Free: 1024, Available: 0. Root append: "No space left on device", on both a new file (app.log, 0 bytes created) and the existing filler.bin. Free inodes 12811, so not an inode problem.
- /sys/fs/ext4/loop0/reserved_clusters = 1024, equal to the Free figure.
- echo 0 > reserved_clusters, then root append: exit 0, free 1024 -> 1023.
- Two reserves: root reserve (2560 blocks, tune2fs) and the kernel's reserved_clusters. Root cannot use the second.
- Not checked: Ubuntu's reserved_clusters value and why its root write succeeded.
