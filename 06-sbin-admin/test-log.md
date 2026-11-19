## 06-A ID_LIKE fools a plain grep (Ubuntu, 2026-11-07)
- Break copied /etc/os-release to /tmp/oslab and ran grep -c debian on the copy: 1. grep -n showed the only match was line 7, ID_LIKE=debian.
- Fix ran the anchored ID test: ID line ID=ubuntu, "ID equals debian" -> 0. /tmp/oslab was removed, ls -d said no such file.
- Not tested: the optional-quote pattern against ID=ubuntu.

## 06-A ID_LIKE fools a plain grep (Rocky, 2026-11-07)
- Break: grep -c fedora gave 2. Lines 5 (ID_LIKE="rhel centos fedora") and 10 (LOGO="fedora-logo-icon"). The RESULT line claimed the only match was the family list, which was false: one match was LOGO.
- Fix: ID line ID="rocky", "ID equals fedora" -> 0. /tmp/oslab removed.
- On the real file, '^ID="\?rocky"\?$' printed 1 and '^ID=rocky$' printed 0. Rocky quotes the value, Ubuntu doesn't.
- Changed the RESULT wording to "that word also appears in lines that are not the ID field". Rerun on Rocky (date not recorded) printed the new wording and it was true.
- Not tested: a machine that really is the distro being tested, so I haven't seen the test say yes.

## 06-B identity and kernel (Ubuntu and Rocky, date not recorded)
- strace of uname -r: one uname() call, then write(1, "7.0.0-42-generic\n", 17) = 17. No openat of /proc/sys/kernel/osrelease, though cat of that file printed the same string.
- ls -l /proc/self/fd/1 gave /dev/pts/0 run directly and pipe:[20557] through | cat.
- /etc/os-release is a symlink to ../usr/lib/os-release on both VMs. md5sum of both paths matched on Ubuntu (f8477ebe...). Not run on Rocky.
- Rocky is 10.2 (Red Quartz), ID="rocky", ID_LIKE="rhel centos fedora", kernel 6.12.0-211.69.1.el10_2.x86_64. Ubuntu is 24.04.5, ID=ubuntu, ID_LIKE=debian.
- strace -f on hostnamectl, filtered for os-release, printed nothing. The daemon systemd-hostnamed (pid 3287) is a separate process; attached with sudo it opened os-release with relative paths (openat(12, "os-release")). Which directory fd 12 pointed at: not shown.

## 06-C CPU, memory and /proc (Ubuntu and Rocky, date not recorded)
- nproc 2 on both. Ubuntu lscpu: Intel Atom (Denverton), 40 bit addresses. Rocky lscpu: i7-10850H, 39 bit. I didn't look at the libvirt settings, so I don't know why they differ.
- free -h: Ubuntu 3.8Gi total, 2.6Gi available; Rocky 3.7Gi total, 2.0Gi available. lsmem: Ubuntu 4G, Rocky 4.3G against MemTotal 3873932 kB. Not found out why Rocky's gap is bigger.
- strace of lscpu filtered for /proc and /sys missed cpuinfo. Unfiltered it showed openat(4, "cpuinfo"), a relative open. I read fd 4 as /proc from the earlier openat of /proc; the trace doesn't print it.
- ls -l /proc/uptime: size 0. wc -c: 16. Two cats 2 s apart: 2580.30 then 2582.30. Second number grew 9.94 in 5 s on 2 CPUs, which fits idle time summed over CPUs. The file has no label. Not tested under load.
- dmesg on Rocky: my grep printed nothing; bare dmesg said "Operation not permitted".

## 06-D processes and services (Ubuntu and Rocky, date not recorded)
- ps -e | wc -l: Ubuntu 236, Rocky 250. Both include the header line. strace showed ps opening /proc/1/stat, status and cmdline.
- Firefox pid 5357: /proc/5357/status said PPid 1917, and ps listed 1917 as gnome-shell. ps reads /proc too, so this shows two views agreeing, not an independent check.
- systemctl list-units --state=running: Ubuntu 32, Rocky 38 by wc -l. Failed: Ubuntu 0, Rocky 1 (dnf-makecache.service).
- Ubuntu: ssh inactive, ssh.socket active. sudo ss -ltnp showed systemd pid 1 on port 22, nginx on 80, systemd-resolve on 53, cupsd on 631. Without sudo the Process column was empty.
- Rocky: sshd holds 22. systemd pid 1 holds 9090 and cockpit.socket is active. Not tested: that this socket holds that exact listener.
- list-dependencies --reverse: nginx (Ubuntu) and sshd (Rocky) are pulled in only by multi-user.target and graphical.target. That doesn't show they are safe to stop.
- dnf-makecache journal: Curl error (6), could not resolve mirrors.rockylinux.org. Later getent ahosts returned 199.232.194.132, so I only know it was transient. I did not rerun dnf makecache.

## 06-E users, sessions and admin (Ubuntu and Rocky, date not recorded)
- who on Ubuntu: seat0 (login screen) and tty2, both 2026-11-02 10:00; w and uptime said 1 user. I did not test why seat0 gets its own line.
- strace: last opens /var/log/wtmp and who opens /var/run/utmp. Both are -rw-rw-r-- root utmp, so a normal user can read them.
- id and getent group agree: Ubuntu 27(sudo) with sudo:x:27:ubuntulab, Rocky 10(wheel) with wheel:x:10:bfs.
- cat /etc/sudoers: Permission denied on both. sudo -l still answered: Ubuntu (ALL : ALL) ALL, Rocky (ALL) ALL. secure_path differs: Ubuntu has /usr/local and /snap/bin, Rocky doesn't.
- getent passwd | awk listed root, sync and ubuntulab as accounts with a shell. sync is there only because my filter excluded just nologin and false. I did not run getent passwd sync.

## 06-F interfaces, routes and listening ports (Ubuntu and Rocky, date not recorded)
- ip route on both: default via 192.168.122.1 dev enp1s0 proto dhcp. Rocky is 192.168.122.28, Ubuntu 192.168.122.174.
- resolv.conf: Rocky says "Generated by NetworkManager" and names 192.168.122.1. Ubuntu names 127.0.0.53, is a symlink to ../run/systemd/resolve/stub-resolv.conf, and resolvectl status showed Current DNS Server 192.168.122.1.
- getent ahosts mirrors.rockylinux.org returned 199.232.194.132 on both. ping -c 1 to 192.168.122.1 from Rocky: 0% loss, 0.099 ms. I did not test where 192.168.122.1 gets its answers.
- ss -ltn on Rocky: 22 on all addresses, 631 on loopback, 9090 on all addresses. No port 80 or 53. Not tested: whether firewalld lets other machines reach 9090.

## 06-G storage, mounts and disk use (Ubuntu and Rocky, date not recorded)
- lsblk -e7: Ubuntu vda 40G, vda1 1M, vda2 40G on /. Rocky vda 40G, vda1 1M, vda2 1G on /boot, vda3 39G with rl-root 35G on / and rl-swap 4G. ext4 on Ubuntu came from df -hT, not lsblk.
- Ubuntu df said 15G used. The top-level du I printed added up to about 10.8G because tail -n 8 cut off /swap.img (3.9G). That brings it to about 14.7G. I did not account for the last 0.3G.
- swapon --show: Ubuntu /swap.img (file, 3.8G), Rocky /dev/dm-1 (partition, 4G). ls -l /dev/mapper showed rl-swap -> ../dm-1. Swap used dropped to 0B on both since an earlier run, and I did not find out why.
- Bare du on Ubuntu printed at least six refusals under /etc and /root was refused too. They were not the cause. Not tested: what is inside the refused folders.
- /var was 5.5G, /var/lib 4.8G, /var/lib/snapd 4.5G. /var/log and /var/cache changed between runs.
- Rocky df said 5.8G used on / and du said 5.0G. Not found out why.

## 06-H scheduled jobs and logs (Ubuntu, date not recorded)
- systemctl is-active cron crond atd: active, inactive, inactive. crond is the Rocky name, so inactive can't tell stopped from not installed. I did not run systemctl status crond.
- crontab -l: no crontab for ubuntulab. list-timers showed sysstat-collect (last Sat 04:40:21 CST, next 04:50:00) and apt-daily-upgrade (last Fri 06:53:54, next Sat 06:39:27). I cut the list at 8 lines.
- journalctl -p err -b worked without sudo and id showed adm. I did not test it from an account without adm. --disk-usage said 530.0M.
- 20 lines of errors, 9 from gdm-password naming [ubuntulab]. I can't tell a wrong password from a screen that timed out. I did not look at btmp or the other lines.
- /var/crash held _usr_lib_systemd_systemd-resolved.991.crash, 756804 bytes, -rw-r----- systemd-resolve:whoopsie, dated Nov 4 04:29. My id has no whoopsie group, so I can't read it. I did not try, and I did not find out why it crashed.

## 06-I fifteen-minute inventory (Ubuntu, 2026-11-13 and later)
- First batch of commands ran in 17 seconds because I pasted them together, so that is not a time. The later run left the terminal open about 30 hours. Neither is a real inventory time.
- Second run: nproc 2, free -h 3.8Gi with 2.6Gi available, uptime up 3 days 11:31, 34 services running, failed list empty, gnome-shell largest at 10.0%, update-manager at 13.0% CPU.
- df -hT showed a second ext4 mount, /dev/loop22, 90M, at /var/tmp/automation-labs/mnt. I don't know what it is for.
- First report named commands that were not in that run (swap, getent passwd, /var/crash, KVM). The second report names only commands from its own run.
- Not done: a real timed run with a stopwatch.
