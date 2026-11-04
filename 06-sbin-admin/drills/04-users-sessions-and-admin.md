# 06 - Sbin Admin: Users, Sessions and Admin Activity

Scenario: the same server, no documentation. Who is on it, who can administer it, and what did they do recently?

1. `who` printed two lines on Ubuntu but `w` and `uptime` said `1 user`. What did each line show?

`who` listed `seat0 (login screen)` and `tty2`, both from 2026-11-02 10:00. `w` showed one session, `tty2`, running `gnome-session-binary`. I did not test why `seat0` gets its own line.

2. `last` and `who` read different files. Which, and who can read them?

`strace` showed `last` opening `/var/log/wtmp` and `who` opening `/var/run/utmp`. `ls -l` showed `-rw-rw-r-- root utmp` on both, 80256 and 2304 bytes, so a normal user can read them.

3. `id` and `getent group sudo` agreed on Ubuntu. When could they disagree?

Today `id` showed `27(sudo)` and `getent group sudo` printed `sudo:x:27:ubuntulab`, so they agreed. In 05 they disagreed after a group was added to a running process. I did not test a group change after login in 06.

4. `cat /etc/sudoers` was denied but `sudo -l` answered. What does that say about a denied or empty result?

`/etc/sudoers` was `-r--r-----` root:root, `cat` printed "Permission denied", and `sudo -l` still printed `(ALL : ALL) ALL` for `ubuntulab`. An empty or denied result can mean nothing there, the wrong place, or not allowed to look. This was not allowed. `sudo -l` never said the rule comes from the `sudo` group, so I did not test that link.

5. How do the admin group and `secure_path` differ between the two VMs?

Ubuntu has `sudo` (GID 27) and `secure_path` with `/usr/local/sbin`, `/usr/local/bin` and `/snap/bin` as well as the standard folders. Rocky has `wheel` (GID 10) and `secure_path=/sbin:/bin:/usr/sbin:/usr/bin`. Each group had one member in `getent`. Rocky's `sudo -l` printed `(ALL) ALL` and Ubuntu's printed `(ALL : ALL) ALL`.

6. `getent passwd | awk` listed three accounts with a shell on Ubuntu. Why is `sync` there?

The output showed `sync 4 /bin/sync`. My filter excluded only `nologin` and `false`, so `sync` passed. A shell field alone doesn't make it a login account. I did not run `getent passwd sync` or check its password status, and I did not run the account filter on Rocky.
