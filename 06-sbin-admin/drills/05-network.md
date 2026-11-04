# 06 - Sbin Admin: Interfaces, Routes and Listening Ports

Scenario: the same server, no documentation. How is it connected, and what is reachable?

1. `ip route` on both VMs showed a `default` line. What does it say, and where did the route come from?

Both showed `default via 192.168.122.1 dev enp1s0 proto dhcp`, with source `192.168.122.28` on Rocky and `192.168.122.174` on Ubuntu. Traffic with no more specific route goes to that gateway, and `proto dhcp` says the route came from DHCP.

2. Ubuntu's `/etc/resolv.conf` names `127.0.0.53` and Rocky's names `192.168.122.1`. What did `ls -l` and `resolvectl status` add on Ubuntu?

`ls -l` showed `/etc/resolv.conf -> ../run/systemd/resolve/stub-resolv.conf`, and `resolvectl status` showed `Current DNS Server: 192.168.122.1`. So the stub forwards to the same server Rocky's NetworkManager-generated file names directly. I did not test where `192.168.122.1` gets its answers.

3. `dnf-makecache` failed with "Could not resolve host", yet `getent ahosts mirrors.rockylinux.org` worked later. What can I conclude?

The journal showed `Curl error (6)` at 22:47:26 EST, and later `getent ahosts` returned `199.232.194.132`. So the failure was transient. I can't say what was wrong at 22:47. I did not rerun `dnf makecache`, so I did not show that a download works now.

4. `ss -ltn` showed port 9090 with no owner, and `sudo ss -ltnp` showed `systemd`. What can an empty owner column mean?

Nothing there, the wrong place, or not allowed to look. It was not allowed: without `sudo` the column was empty, and with it `ss` showed `systemd`, pid 1, fd 79 on 9090. `systemctl is-active cockpit.socket` printed `active`, but I did not show that this socket holds that exact listener.

5. Port 22 is held by `systemd` on Ubuntu and by `sshd` on Rocky. What does that tell me?

On Ubuntu `ssh` was `inactive`, `ssh.socket` was `active`, and `systemd` pid 1 held the port. On Rocky `sshd` pid 1179 held it directly. The two VMs start SSH differently. Rocky's 9090 is also held by `systemd`, so Rocky uses socket activation too. I did not open a connection to watch a service start.

6. A listener on `0.0.0.0` exists. Why isn't that proof it's reachable from another machine?

It only says the socket accepts connections on all IPv4 addresses. A firewall, routing or network isolation can still block it. `firewalld` was running on Rocky and I did not check its rules, so I did not test reachability from another machine.
