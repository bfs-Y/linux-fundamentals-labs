# 06 - Sbin Admin: Fifteen-Minute Inventory (Ubuntu)

Time: not measured. The terminal was left open for about 30 hours, so the elapsed figure is not an inventory time.

Identity: `hostnamectl` showed ubuntulab-Standard-PC-Q35-ICH9-2009, Ubuntu 24.04.5 LTS, x86-64, virtualization `kvm`, hardware vendor QEMU. `uname -r` printed 7.0.0-42-generic.

Resources: `nproc` printed 2. `free -h` showed 3.8Gi RAM, 1.2Gi used, 2.6Gi available, and 3.8Gi swap with 624Ki used. `uptime` said up 3 days 11:31 with load 0.16, 0.07, 0.02.

Services: 34 running (`systemctl list-units ... | wc -l`). The `--state=failed` query printed nothing. I don't know why the count rose from 32, and `systemctl --failed` would confirm the failed result.

Critical processes: `ps` showed `gnome-shell` as the largest memory user at 10.0%, then `update-manager` at 5.1% memory and 13.0% CPU. That is one snapshot, so I don't know whether the CPU use was sustained.

Users: `who` showed two entries for ubuntulab, `seat0` and `tty2`, both from 2026-11-13 12:59. I don't know why that doesn't obviously agree with the uptime.

Network: `ip -br addr` showed `enp1s0` UP at 192.168.122.174/24 and `lo` at 127.0.0.1/8.

Listening ports: `ss -ltn` showed 22 and 80 on all addresses (IPv4 and IPv6), and 53 and 631 on loopback only. The usual uses are SSH, HTTP, DNS and CUPS, but I did not check which process holds any of them, because `ss -ltn` shows no owner.

Storage: `df -hT` showed `/dev/vda2` ext4, 40G, 15G used, 23G free, 40%. It also showed `/dev/loop22`, ext4, 90M, at /var/tmp/automation-labs/mnt. I don't know what it is for.

Scheduled jobs: `systemctl list-timers` listed 15 timers. The names were cut off in the terminal, but the prefixes match sysstat-collect, fwupd-refresh, anacron, motd-news and apt-daily, plus logrotate, fstrim and man-db. `crontab -l` printed `no crontab for ubuntulab`.

Risks: ports 22 and 80 listen on all addresses and I did not check a firewall. `update-manager` was at 13% CPU. The loop mount's purpose is unknown. I infer, and did not test, that stopping gdm would end my desktop session and stopping ssh.socket would cut remote login.

Needs more investigation: the 32 to 34 service change, `systemctl --failed`, which process owns port 80 (needs `sudo ss -ltnp`, ask first), why `update-manager` used 13% CPU, what `/dev/loop22` is for, and the `who` login time against the uptime.

Follow-up on 2026-11-20, after a reboot, is in the test-log (section 06-B): port 80 is nginx, there are no failed units on that boot, and the loop mount was gone.
