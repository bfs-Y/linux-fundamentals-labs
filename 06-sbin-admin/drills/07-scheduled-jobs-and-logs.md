# 06 - Sbin Admin: Scheduled Jobs and Logs

Scenario: the same server, no documentation. What runs on a schedule, and what has the machine been logging?

1. Which scheduler is active on Ubuntu, and why can't `inactive` for `crond` separate "stopped" from "not installed"?

`systemctl is-active cron crond atd` printed `active`, `inactive`, `inactive`, so `cron` runs and `atd` does not. `crond` is the Rocky name, so I think it is not installed on Ubuntu, but the output prints the same word for a stopped unit and a missing one. I did not run `systemctl status crond`.

2. What did `crontab -l` show, and what can it not show?

`no crontab for ubuntulab`, so my account has no personal jobs. It cannot show root's crontab or `/var/spool/cron`, which I can't read. `/etc/cron.d` held `anacron`, `e2scrub_all` and `sysstat`, and I cut that listing at 12 lines.

3. Name two timers with their last and next times.

`sysstat-collect.timer` last ran 04:40:21 and was next due 04:50:00. `apt-daily-upgrade.timer` last ran Fri 06:53:54 and was next due Sat 06:39:27. I cut the list at 8 lines, so there may be more timers.

4. Why could I read the journal without `sudo`?

`journalctl -p err -b` printed entries as a normal user, and `id -nG | grep` printed `adm`. I think my `adm` membership is the reason, but I did not test it by running `journalctl` from an account without `adm`.

5. Nine of about twenty error lines were `gdm-password`. What can I say?

`grep -c gdm-password` printed 9 and `wc -l` printed 20, which may include a boot header line. The lines named my own account: `auth could not identify password for [ubuntulab]` and `conversation failed`, on Nov 6 and Nov 7. They fit failed or abandoned prompts at the login screen, but I can't tell a wrong password from a screen that timed out. I did not look at the other lines or at `btmp`.

6. What did `/var/crash` hold?

One file, `_usr_lib_systemd_systemd-resolved.991.crash`, 756804 bytes, `-rw-r-----` owned by `systemd-resolve`, group `whoopsie`, dated Nov 4 04:29. My `id` shows no `whoopsie` group, so I probably can't read it. I did not try. `systemd-resolved` was `active` when I checked, and I did not find out why it crashed.
