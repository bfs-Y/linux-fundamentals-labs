# 01 — Boot Process: Drill (with answers)

---

**1. `journalctl -b -p err` shows several error-priority lines on a VM
that's clearly running fine — you've been SSH'd into it for hours. Does
the presence of these lines mean the boot failed?**

No. Severity level (`err`) is not the same claim as "boot failed."
`-p err` only filters by priority — it says nothing about whether the
failing component was on the critical boot path or just a non-essential
service (audio daemon, login manager cosmetics) failing quietly and
harmlessly. This came directly out of a real check tonight: every `err`
line on a fully healthy VM traced back to rtkit-daemon, gdm3, and
pam_unix — desktop noise, not boot-critical failures.

---

**2. `dmesg -T` and `journalctl -b` both claim to show "the boot log," but
one of them can show messages from earlier in the boot sequence than the
other. Which one, and why?**

`dmesg` can go earlier. It reads the kernel's own in-memory ring buffer,
which starts filling the instant the kernel itself begins running —
before initramfs, before systemd, before any conventional logging
service exists. `journalctl -b` depends on journald, which is a systemd
component — it cannot have recorded anything from before systemd started,
by definition. Confirmed directly: `dmesg -T`'s earliest timestamp for a
given boot was one full second earlier than `journalctl -b`'s import of
the same kernel message — proof journald captured it retroactively, not
live.

---

**3. `ssh user@host` returns `Connection refused`. A different attempt
against a different host returns a hang with no response at all
(timeout). Are these the same category of problem?**

No — genuinely different signals. `Connection refused` means a packet
reached that host on that port, and something actively rejected it —
meaning the host is reachable, but nothing is listening on that specific
port. A timeout means no response came back at all — could be a firewall
silently dropping the packet, the host being down, or a routing problem.
Refused points you toward "check what's supposed to be listening";
timeout points you toward "check reachability and firewalls" first.

---

**4. A VM shows no output in the hypervisor's graphical console window
after a reboot. Does that mean the VM failed to boot?**

Not necessarily. The graphical console rendering and the guest OS
actually running are two separate systems — one can fail while the other
works fine. The correct next step isn't to assume failure, it's to check
independently from the host side: is the VM's process even still running
(`virsh list --all`), does it have a live network address
(`virsh domifaddr`), and is it actively consuming CPU over time
(`virsh dominfo`, checked twice, comparing CPU time). All three
confirmed "alive" in a real incident where the console had simply failed
to render — the actual root cause was elsewhere entirely.

---

**5. Right after a planned change and reboot, a new unrelated symptom
shows up (SSH refused). What's the reasoning trap here, and how do you
avoid it?**

The trap is assuming the most recent change caused the new symptom,
just because they're close in time. In a real incident, "SSH refused"
turned out to be caused by openssh-server never having been installed at
all — completely unrelated to a GRUB edit and reboot that happened
moments earlier. The fix: let the specific evidence (refused, not
timeout; VM confirmed alive and fully booted via console) rule out
categories of cause methodically, rather than defaulting to blaming
whatever you touched most recently.
