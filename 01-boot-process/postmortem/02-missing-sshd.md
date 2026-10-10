# Postmortem - SSH refused after a reboot

**What caused it:** `openssh-server` was never installed on this VM.
That had nothing to do with the GRUB change. It only showed up because I
tried to SSH in right after the reboot.

**How I found it:** I blamed the reboot first, and that was wrong. From
the host: `virsh list --all` showed the VM running, `virsh domifaddr` gave
its IP, and `virsh dominfo` run twice showed the CPU time going up
(1530.6s to 1530.8s), so it wasn't frozen. The virt-manager window was
blank and `virsh console` showed nothing. After a shutdown and start,
`virt-viewer` showed the desktop. The SSH error was "Connection
refused", not a timeout, which means something answered and nothing was
listening on port 22. Inside the VM, `systemctl status ssh` said the unit
doesn't exist and `dpkg -l | grep openssh-server` printed nothing.

**How it was fixed:** `sudo apt install openssh-server`. `ssh.service`
stayed inactive, which is normal here, because `ssh.socket` listens on
port 22 and starts the service when someone connects. SSH from the host
worked afterwards.

**What I'd do differently:** a new problem right after a change isn't
proof the change caused it. "Connection refused" should have sent me to
check whether anything listens on port 22 before I spent time on whether
the VM crashed.
