# 06 - Sbin Admin: Scheduled Jobs and Logs

Scenario: the same server, no documentation. What runs on a schedule, and what has the machine been logging?

1. Which scheduler is active on Ubuntu, and why can't `inactive` for `crond` separate "stopped" from "not installed"?

`systemctl is-active cron crond atd` showed that `cron` is running, while `crond` and `atd` are inactive. Ubuntu uses the service name `cron`, whereas Rocky uses `crond`, so `inactive` alone does not establish whether `crond` is stopped or not installed. I did not test `systemctl status crond` to distinguish between those two possibilities.

2. What did `crontab -l` show, and what can it not show?

`crontab -l` returned `no crontab for ubuntulab`, so my account has no personal jobs. It does not show root's crontab or the unreadable `/var/spool/cron`. `/etc/cron.d` contained `anacron`, `e2scrub_all` and `sysstat`, but the listing came from `ls /etc/cron.d /etc/cron.daily | head -n 12`, so it was cut at 12 lines. I did not test root's crontab or inspect the contents of the individual `/etc/cron.d` files.

3. Name two timers with their last and next times.

`sysstat-collect.timer` last ran Sat 2026-11-07 at 04:40:21 CST and was next due at 04:50:00 CST. `apt-daily-upgrade.timer` last ran Fri 2026-11-06 at 06:53:54 CST and was next due Sat 2026-11-07 at 06:39:27 CST. So `sysstat-collect` fires far more often, about every ten minutes against about once a day. I did not test the complete timer list; `head -n 8` limited the output, so additional timers may exist.

4. Why could I read the journal without `sudo`?

`id -nG | grep` showed membership in `adm` (and `lpadmin`, which matched only because "adm" is inside it). As a normal user I could read `journalctl -p err -b`, and `journalctl --disk-usage` printed 530.0M. I think `adm` is the reason, but I have not verified that group membership is the only one. I did not test journal access from an account without `adm`.

5. Nine of about twenty error lines were `gdm-password`. What can I say?

`grep -c gdm-password` printed 9 and `wc -l` printed 20, which may include a boot header line. The lines named my own account: `auth could not identify password for [ubuntulab]` and `conversation failed`, on Nov 6 and Nov 7. They fit failed or abandoned prompts at the login screen, but I can't tell a wrong password from a screen that timed out. I did not look at the other lines or at `btmp`.

6. What did `/var/crash` hold?

One file, `_usr_lib_systemd_systemd-resolved.991.crash`, 756804 bytes, `-rw-r-----` owned by `systemd-resolve`, group `whoopsie`, dated Nov 4 04:29. My `id` shows no `whoopsie` group, so I probably can't read it. I did not try. `systemd-resolved` was `active` when I checked, and I did not find out why it crashed.
