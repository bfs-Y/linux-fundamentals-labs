# 06 - Sbin Admin: Fifteen-Minute Inventory (Ubuntu)

Elapsed: 17 seconds. The timer measured a pasted batch of commands, so it is not a real inventory time.

Identity: `hostname`, `cat /etc/os-release` and `uname -r` showed ubuntulab-Standard-PC-Q35-ICH9-2009, Ubuntu 24.04.5 LTS, kernel 7.0.0-42-generic. `uptime` said up 23 min with 1 user, so the VM had rebooted. I don't know why.

Resources: `nproc` printed 2 and `free -h` showed 3.8Gi RAM with 2.7Gi available. Load was 0.10, 0.03, 0.01. This run did not show swap.

Services: `systemctl list-units` showed 32 running and nothing failed. I don't know whether all of them are needed.

Critical processes: `ps` showed `gnome-shell` as the largest memory user at 9.7%. That shows the biggest, not the critical ones.

Users: `who` showed two entries for ubuntulab, `seat0` and `tty2`, both from 2026-11-13 12:59.

Network: `ip -br addr` showed `enp1s0` UP at 192.168.122.174/24. I don't know whether outside access is restricted.

Listening ports: `ss -ltn` showed 22 and 80 on all addresses, 53 on 127.0.0.53 and 127.0.0.54, and 631 on loopback. I don't know which process owns port 80, because `ss -ltnp` needs `sudo`.

Storage: `df -hT` showed `/` ext4, 40G, 15G used, 23G free, 40%. This run did not show what uses the space.

Scheduled jobs: `systemctl list-timers` showed sysstat-collect, anacron, fwupd-refresh, apt-daily and motd-news, cut at 6 lines. I did not check for cron jobs.

Risks: ports 22 and 80 listen on all addresses, and I did not check a firewall. Stopping gdm would likely end my desktop session, and stopping ssh.socket would cut remote login. I inferred both and did not test them.

Needs more investigation: which process owns port 80 (needs `sudo ss -ltnp`, ask first). The file in /var/crash and its date. Why the VM rebooted, using `journalctl -b -1`.
