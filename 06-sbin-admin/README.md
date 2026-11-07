# 06 - Sbin Admin

Drafted from my command output, not written by me alone. I ran this
module on Ubuntu 24.04.5 and Rocky 10.2. It is read-only inventory
work, except one break/fix pair that only touches a copy under /tmp.
The main thing it showed: an empty or short result does not mean
nothing is there. It can also mean "wrong place" or "not allowed to
look", so I run the command bare before I trust it.

## What I covered

- Where answers come from. `strace` showed `uname` making a `uname`
  syscall and `write` sending the text to fd 1, with no open of
  `/proc/sys/kernel/osrelease`. fd 1 pointed at `/dev/pts/0` directly
  and at `pipe:[20557]` through `| cat`. `ps` opened
  `/proc/<pid>/stat`, `status` and `cmdline`. `lscpu` opened `cpuinfo`
  with a relative path, so a filter on full paths missed it at first.
- `/proc` files are not stored data. `ls -l /proc/uptime` said size 0,
  `wc -c` said 16, and two `cat`s two seconds apart gave 2580.30 and
  2582.30. The second number grew by 9.94 in 5 seconds on a 2 CPU VM.
  That fits idle time added up over CPUs, but the file has no label.
- `os-release`. On both VMs `/etc/os-release` is a symlink to
  `../usr/lib/os-release`, and on Ubuntu `md5sum` of both paths matched.
  `grep -c debian` printed 1 on Ubuntu and `grep -c fedora` printed 2 on
  Rocky, both from lines that are not `ID`. Rocky quotes `ID="rocky"`
  and Ubuntu does not, which broke a pattern without optional quotes.
- Empty output. `dmesg` on Rocky printed "Operation not permitted" while
  my `grep` on it printed nothing. `ss -ltn` had an empty owner column
  until I used `sudo`. A `tail -n 8` on `du` hid `/swap.img`, 3.9G,
  which `swapon --show` then showed as Ubuntu's active swap. Rocky's
  swap was `/dev/dm-1`, type partition.
- Services and sockets. On Ubuntu `ssh` was inactive, `ssh.socket` was
  active and `sudo ss -ltnp` showed `systemd` pid 1 on port 22. On
  Rocky `sshd` held port 22 and `systemd` held 9090. Only the targets
  depended on nginx, which did not show it was safe to stop.
- Users and network. `cat /etc/sudoers` was denied on both VMs but
  `sudo -l` answered. Both VMs use gateway 192.168.122.1. Rocky's
  `dnf-makecache` failed with "Could not resolve host" and a later
  `getent ahosts` worked, so I only know it was transient.

## What's in this folder

- `break/01-id-like-fools-grep.sh`, `fix/01-match-id-field-only.sh` and
  `postmortem/01-id-like-fools-grep.md`: one pair, run on both VMs.
- `drills/01` to `08`: one per topic, identity and kernel, CPU and
  memory, processes and services, users and sessions, network, storage,
  scheduled jobs and logs, and the fifteen-minute inventory on Rocky.

## Not finished

- Drills 06, 07 and 08 were drafted by me from my pastes, so they are
  not reps I earned. I did not time any day.
- I did not answer the stale-session cold drill myself.
- I did not run the bin/sbin check again this module. The old test-log
  with that run was deleted, and it is in git history.
- Not found out: why Rocky's `df` and `du` differ by about 0.8G,
  whether `/dev/dm-1` is `rl-swap`, and why `systemd-resolved` crashed
  on Nov 4. I could not read the crash report.
