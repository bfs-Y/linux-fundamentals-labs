# 06 - Sbin Admin: Processes and Services

Scenario: the same server, no documentation. What is running, and which of it is risky to stop?

1. `ps -e | wc -l` printed 236 on Ubuntu. Why is that not the number of processes, and where does `ps` get its data?

It includes the header line, so there were 235 processes. `strace` showed `ps` opening `/proc/1/stat`, `/proc/1/status` and `/proc/1/cmdline`, so the data comes from `/proc`. The 1182 from the trace was lines mentioning `/proc/<number>`, not processes. On Rocky `ps -e | wc -l` printed 250.

2. Firefox was PID 5357 with parent 1917. How did I check `ps` against the kernel's own files?

`/proc/5357/status` printed `PPid: 1917`, and `ps` listed 1917 as `gnome-shell`. `ps` reads `/proc` too, so this is the same source seen twice and shows the two views agree. I did not test that `ps` takes `%MEM` from `VmRSS`.

3. `ss -ltnp` showed an empty `Process` column without `sudo`. What can an empty result mean, and which was it?

Nothing there, the wrong place, or not allowed to look. It was not allowed: with `sudo` the same command showed `nginx` on port 80, `systemd` on 22, `systemd-resolve` on 53 and `cupsd` on 631. I did not test how `ss` finds the owner.

4. Port 22 was held by `systemd`, pid 1, on Ubuntu. What does that say about `ssh` being `inactive`?

`systemctl is-active` printed `inactive` for `ssh` and `active` for `ssh.socket`, and `sudo ss -ltnp` showed `systemd` pid 1 holding port 22. So systemd owns the listener and `ssh.service` isn't running. I think it starts the service when a connection arrives, but I never opened a connection to watch it, so that part is from memory. On Rocky `sshd` and `crond` were both `active`.

5. Why did `list-dependencies --reverse` not prove nginx is safe to stop?

It showed only `multi-user.target` and `graphical.target` pulling nginx in, so no other unit depends on it. Systemd can't see a browser, a script or another machine calling port 80. Port 80 was open on all addresses, held by nginx, and I did not check what it serves.

6. On Rocky `dnf-makecache.service` is failed. What caused it?

The journal said `Curl error (6)` and `Could not resolve host: mirrors.rockylinux.org` at 22:47:26 EST, so it was a name lookup failure. A timer started it, not a person. I did not test `getent ahosts mirrors.rockylinux.org`, and I did not check whether Rocky has a working connection now.
