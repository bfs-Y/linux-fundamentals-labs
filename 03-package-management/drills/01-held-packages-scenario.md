# 03 - Package Management: Drill

1. `apt install foo` fails with `held broken packages`. What is your first command, and what does an empty result tell you?

First command: `apt-mark showhold`. If it names a package, run `apt-cache policy` on it and look for Installed behind Candidate. That gap is what a hold looks like. If it prints nothing, the message isn't about a hold. In my lab I got the identical error before and after `apt-mark unhold`, because the old nginx-common wanted `nginx (< 1.24.0-2ubuntu7.1~)` while nginx .18 was installed. When `showhold` is empty, I read the `Depends:` lines in the error for `=` pins and check the repos.

2. On Rocky, `dnf upgrade` fails with `filtered out by exclude filtering`. Where do you look, and what can the file tell you?

`dnf versionlock list` and `/etc/dnf/plugins/versionlock.list`. The file has an `# Added lock on` header with a timestamp, so it gives when but not who. For who I used `journalctl _COMM=sudo | grep versionlock`, which showed `bfs` at 02:35:28. The header said 02:36:09, so the two sources disagree by about 40 seconds. I didn't work out why. `exclude=` in dnf.conf can produce the same phrase and I didn't test that, so an empty lock file would send me there next.

3. `dpkg -S /bin/ls` finds nothing, but `/bin/ls` runs. Why, and how do you fix the query?

On both of my boxes `/bin` is a symlink to `usr/bin`. The package ships `/usr/bin/ls`, and `dpkg -S` matches the recorded path as written. `dpkg -S "$(readlink -f /bin/ls)"` returned `coreutils`. On Rocky `rpm -qf /bin/ls` answered directly with `coreutils-9.5-8.el10_2.1`. I saw the difference but didn't prove why rpm resolves the symlink and dpkg doesn't.

4. You need to know who held a package and when. Why is `/var/lib/dpkg/status` the wrong place, and what is the right one?

The `status` mtime is the last dpkg transaction, not the hold. Mine read 06:58:48 on Oct 16 because the gnome-shell upgrade rewrote the file. The hold itself went on at 09:22:07 the day before. `journalctl _COMM=sudo | grep apt-mark` showed the command, the user and the time. The limit: the journal only has it if the hold went through sudo and the journal hasn't rotated. A hold placed from a root shell would show up as one `sudo -i` line, but I didn't test that.

5. A dnf lock is on package A, and upgrading B fails. Which command shows that B pins A to an exact version?

`rpm -q --requires B | grep A` for the installed build, and `dnf repoquery --requires B-<new version>` for the new one. The `=` is the pin. On Rocky, ghostscript required `ghostscript-tools-fonts = 10.02.1-16.el10_2.3` while the lock held `.el10_2.1`, so there was no valid answer. I ran this before locking, which is the right order.

6. A hold is in place and `apt install pkg=version` still changes the held package. How?

An explicit version overrides the hold. apt printed `The following held packages will be changed: nginx-common` and went ahead. A hold only stops apt's own resolver choices. That is how I downgraded nginx-common while it was held, then re-held it to build the 03-B incident.
