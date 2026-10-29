# 05 - Users and Sudo: Drill

1. An engineer was added to a group two hours ago, `id <user>` shows it, and they still can't connect. Why?

A process keeps the groups it started with. In my lab `id labreader` read the database and listed `labdb`, but the running loop's `Groups:` line in `/proc/<pid>/status` stayed `1001` and it kept logging "denied". A fresh `sudo -u` read worked. Restarting the process gave `Groups: 1001 1002`. Same on Ubuntu and Rocky. I did not test a service restarted through systemd.

2. Which of `id` and `/proc/<pid>/status` shows the live process, and which reads the database?

`/proc/<pid>/status` is what the kernel checks for that process. `id labreader` looked the user up in the account database. In the lab they disagreed until the process restarted.

3. What does `usermod -G sudo user` do, and what is the correct command?

Without `-a` it replaces all supplementary groups. `drilluser` went from `audio,video` to `sudo` only, lost access to a `video` file, and gained sudo. The right command is `usermod -aG`. The fix removed sudo and restored `audio,video`. Tested on Ubuntu only, since Rocky's group is `wheel`.

4. What is the difference between `sudo -u root`, `sudo -i`, `su` and `su -`?

`sudo -u root` and `sudo -i` both gave `HOME=/root`, but only `-i` moved the working directory to `/root`. Plain `su labreader` set `HOME` but kept my directory, and on Rocky it also kept my `PATH`. `su -` gave the target's directory and `PATH`. Same pattern on both boxes, except `PATH` only differed on Rocky because Ubuntu had nothing custom.

5. `su root` failed on Ubuntu and worked on Rocky, while `sudo -i` worked on both. What does that tell you?

Root's password is locked on Ubuntu, so `su root` gave "Authentication failure" (who are you). `sudo -i` checks my own password and the sudo group (what may I do). On Rocky root has a password, so `su root` worked.

6. A sudoers rule passes `visudo -c`, but the user is still refused. What do you check?

The path. `visudo` checks syntax, not meaning. A rule naming `/opt/nonexistent/systemctl` parsed OK, `sudo -l -U` listed it, and the real command gave "a password is required". Fix with `command -v`, validate with `visudo -cf`, then run the exact command as the user.

7. The correct rule allows `systemctl status ssh`, but the same command with `--no-pager` is refused. Why?

Sudoers matches the argument list exactly. `status ssh` matched, `--no-pager status ssh` did not.

8. A deploy script creates `/etc/app.conf` as root. The `app` account, in group `app`, is refused, and `ls -l` shows `-rw-r-----  root  root`. First two commands and the smallest fix?

`ls -l` for owner, group and mode, then `id app` to compare the account's groups. The file is `root:root 640`, so the group is wrong. The smallest fix is `chgrp app` on the file, which gives `root:app 640`: readable, not writable, owner still root. This is the same fix as 04's config-ownership break. I did not run this exact scenario in 05.

9. On Rocky my fix script could not find a sudoers drop-in that existed. Why?

`/etc/sudoers.d` is root-only there, so a test as a normal user failed. Using `sudo test` fixed it.

10. `getent passwd user` and `grep user /etc/passwd` matched. When would they differ?

For an account that is not local, for example from LDAP or SSSD. I did not test that.
