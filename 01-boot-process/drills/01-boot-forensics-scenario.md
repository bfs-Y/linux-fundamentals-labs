# 01 - Boot Process: Drill

**1. `journalctl -b -p err` shows errors on a VM I've been logged into for
hours. Did the boot fail?**

No. `-p err` only filters by severity. On my VM, every error came from
desktop services (rtkit, gdm3, pam_unix), not from anything the boot
needed. I look at which service the errors come from before I decide
anything is broken.

**2. `dmesg` and `journalctl -b` both show the boot. Which one goes back
further, and why?**

`dmesg`. It reads the kernel's own buffer, which starts when the kernel
starts. The journal is written by journald, part of systemd, which starts
later. It imports the kernel messages once it's running. On my VM the same
first kernel line was one second later in `journalctl -b` than in
`dmesg -T`.

**3. SSH says "Connection refused" on one host and just hangs on another.
Are those the same problem?**

No. "Refused" means my packet reached the host and something rejected it,
usually because nothing is listening on that port. A hang means nothing
answered, which points to a firewall, a host that's down, or a routing
problem. On my VM, "refused" led me to check whether anything was
listening on port 22.

**4. After a reboot, the VM's window in virt-manager is blank. Is the VM
dead?**

Not necessarily. From the host I checked `virsh list --all` (running),
`virsh domifaddr` (it had an IP), and `virsh dominfo` twice (CPU time went
from 1530.6s to 1530.8s, so it wasn't frozen). I never found out why the
window was blank. It showed the desktop after a shutdown and start.

**5. Something new breaks right after I made a change. Did the change cause
it?**

Not necessarily. After I put `quiet splash` back and rebooted, SSH was
refused, and I assumed the reboot had broken something. The real reason
was that `openssh-server` had never been installed. Timing is a reason to
look at the change, but I still have to check what's actually wrong.
