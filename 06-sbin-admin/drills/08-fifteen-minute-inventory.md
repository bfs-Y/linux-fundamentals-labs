# 06 - Sbin Admin: Fifteen-Minute Inventory (Rocky)

Drafted from my command output, not written by me alone. I did not time it.

Identity: Rocky Linux 10.2 (Red Quartz), kernel 6.12.0-211.69.1.el10_2.x86_64 (`cat /etc/os-release`, `uname -r`). Up 4 days 18:55 with 1 user (`uptime`).

Resources: 2 CPUs (`nproc`), 3.7Gi RAM with 1.9Gi available (`free -h`). Load 0.16, 0.06, 0.01.

Services: 38 running (`systemctl list-units ... | wc -l`). The failed list printed nothing.

Critical processes: the biggest memory users were `ptyxis` 9.8%, `gnome-shell` for bfs 8.4% and `gnome-software` 6.8% (`ps`). That shows the biggest, not which ones are critical. I did not check that.

Users: `bfs` on `tty2` since 2026-11-02 10:57 (`who`).

Network: `enp1s0` is UP at 192.168.122.28/24 (`ip -br addr`).

Listening ports: 22 on all addresses, 631 on loopback only, 9090 on all addresses (`ss -ltn`). Without sudo the owners are hidden. On Day 5, `sudo ss -ltnp` showed `systemd` pid 1 on 9090.

Storage: `/` is xfs, 35G, 17% used, and `/boot` is 960M, 58% used (`df -hT`).

Scheduled jobs: timers `fwupd-refresh`, `dnf-makecache`, `logrotate`, `plocate-updatedb` and `raid-check`, with the list cut at 6 lines. `/etc/cron.d` holds `0hourly`. I did not read root's crontab.

Risks: stopping `cockpit.socket` would close the 9090 web port, and stopping `sshd` would cut remote login. I inferred both and did not test them. This is a desktop VM, so stopping `gdm` would likely end the session I'm in.

Needs more investigation: whether `dnf-makecache` is really fixed. The failed list is empty and its timer last ran 04:37 EST, but I did not rerun it. Why `df` and `du` differ by about 0.8G on `/`. What Cockpit serves, and whether `firewalld` lets other machines reach 9090.
