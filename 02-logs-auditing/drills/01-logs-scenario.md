# 02 - Logs and Auditing: Drill

**1. You search the journal for a time when the machine was definitely
running and get `-- No entries --`. What are the possible reasons, and
what do you check first?**

Five reasons: wrong time window or timezone, wrong boot, wrong unit or
source, logging itself broken, or you aren't allowed to read the data.
First check: run `journalctl -n 20` with no filters, then run the same
search with `sudo` and look at `id`. On Rocky, my search showed nothing
without `sudo` and 300 lines with it. The journal was fine.

**2. `journalctl -u sshd` shows nothing, but SSH works. Why?**

On Ubuntu the unit is called `ssh.service`. `-u` matches the unit name,
not the process name, so `-u ssh` shows the entries and `-u sshd` shows
nothing. Ubuntu also starts ssh only when something connects, because
`ssh.socket` listens on port 22. So `systemctl is-active ssh` can say
`inactive` while `ssh.socket` says `active`.

**3. How do you know a journal survives a reboot, and which proof is
stronger?**

Two proofs. `/var/log/journal` existing shows the setup. Writing a marker
with `logger`, rebooting, and finding it with `journalctl -b -1` shows
what actually happened, so it's stronger. My test used a clean
`sudo reboot`, so it says nothing about a crash or power loss.

**4. `df` shows 100% used and 0 available. Did logging stop at that
point?**

Not necessarily. `df` shows what a normal user can use, and ext4 holds
back 5% for root. On Ubuntu, a root write still worked at 100%. On Rocky
the same write failed even though `stat -f` showed free blocks, and I
didn't find out why. Trust `stat -f` for the current state. `tune2fs -l`
reads the superblock on disk and can be out of date while the filesystem
is mounted.

**5. A log was rotated, but the program is still writing to the old file
and the new log stays empty. Why, and what fixes it?**

Rotation renames the file and the inode stays the same. The program holds
the file open by inode, so it keeps writing to the renamed file until it
gets SIGHUP and reopens its logs. Ubuntu's rsyslog config does this in
`postrotate` with `systemctl kill -s HUP rsyslog.service`. Separate
problem: `rotate N` deletes the oldest copy on rotation N+1 with no
warning, so choose N by how long it takes to notice an incident.
