# Module 01 — Test Log

Date: 2026-09-18

## 1. dmesg vs journalctl -b: source and earliest-timestamp comparison

$ dmesg | head -5
dmesg: read kernel buffer failed: Operation not permitted

$ sudo dmesg -T | head -5
[Wed Sep 16 00:01:33 2026] Linux version 7.0.0-31-generic ...
[Wed Sep 16 00:01:33 2026] Command line: BOOT_IMAGE=/boot/vmlinuz-7.0.0-31-generic root=UUID=23bfe93b-9f50-4e87-8024-caf79857ee79 ro quiet splash vt.handoff=7
...

$ journalctl -b | head -3
Sep 16 00:01:34 ubuntulab-Standard-PC-Q35-ICH9-2009 kernel: Linux version 7.0.0-31-generic ...
...

Finding: journalctl -b's imported kernel lines are timestamped 1 second
later than dmesg -T's — confirms journald retroactively imports the kernel
ring buffer after systemd starts, rather than capturing it live.

## 2. dmesg_restrict and privilege requirement

Root cause of "Operation not permitted": kernel.dmesg_restrict gates
ring-buffer access behind CAP_SYSLOG (sudo satisfies this). Rationale:
kernel logs can leak memory addresses (ASLR-defeating) and hardware
fingerprinting detail.

## 3. UUID vs device path, cross-machine

$ sudo blkid   (Ubuntu VM)
/dev/vda2: UUID="23bfe93b-9f50-4e87-8024-caf79857ee79" ... TYPE="ext4"
/dev/vda1: PARTUUID="3afa1159-..." (no UUID/TYPE - EFI/BIOS-boot partition)

$ sudo blkid   (Fedora host)
/dev/nvme0n1p1: UUID="F62D-1D7C" TYPE="vfat" PARTLABEL="EFI System Partition"
/dev/nvme0n1p2: UUID="851b2245-..." TYPE="ext4"
/dev/nvme0n1p3: UUID="8038cf5f-..." TYPE="btrfs" LABEL="fedora"

Finding: UUID's confirmed identical between dmesg's kernel command line
and blkid's independent filesystem read. PARTUUID (partition-table slot)
vs UUID (filesystem identity) confirmed as genuinely separate identifiers
on the same disk. Three distinct device-naming conventions observed:
sd* (SATA/SCSI), vd* (virtio), nvme0n1p* (NVMe).

## 4. journalctl pager truncation

$ journalctl -b -p err
(lines truncated with trailing '>' - pager (less) chopping to terminal
width, not journalctl truncating the data itself)

$ journalctl -b -p err --no-pager
(full untruncated lines) - all findings were non-critical desktop/login
noise (rtkit-daemon, gdm3, pam_unix), none boot-critical. Confirmed:
err-level log presence != boot failure.

## 5. ps -r flag investigation (tooling detour)

$ ps -p 1 -r
    PID TTY      STAT   TIME COMMAND
(no row returned - misleading, not a broken system)

$ ps -p 1
    PID TTY          TIME CMD
      1 ?        00:00:04 systemd
(confirmed -r was an invalid/misused flag combination producing silent
empty output, not evidence of a missing PID 1)

## 6. BREAK: GRUB kernel-parameter change (quiet splash removal)

$ sudo sed -i.bak 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/GRUB_CMDLINE_LINUX_DEFAULT=""/' /etc/default/grub
$ grep GRUB_CMDLINE_LINUX_DEFAULT /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT=""
$ ls -la /etc/default/grub.bak
(backup confirmed present)

$ sudo update-grub
Found linux image: /boot/vmlinuz-7.0.0-31-generic
Found linux image: /boot/vmlinuz-7.0.0-28-generic
...
done

$ sudo grep 'quiet splash' /boot/grub/grub.cfg
(no output - confirmed removed)

Blast radius stated before reboot: verbosity/splash change only, does not
touch root fs, kernel version, or initramfs selection. Recovery path:
select older kernel at GRUB (caveat: GRUB_TIMEOUT=0 + hidden means no
menu window without holding Shift/Esc during boot), or restore from
grub.bak.

$ sudo reboot

## 7. Post-reboot verification

$ uptime
 08:13:29 up 0 min, ...
$ sudo dmesg -T | head -3
[Fri Sep 18 08:12:45 2026] Command line: ... ro
(confirmed: quiet splash genuinely absent from live kernel command line)

## 8. FIX: revert GRUB change

$ sudo cp /etc/default/grub.bak /etc/default/grub
$ grep GRUB_CMDLINE_LINUX_DEFAULT /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
$ sudo update-grub
$ sudo grep 'quiet splash' /boot/grub/grub.cfg
(confirmed present in both kernel entries: 31 and 28)
$ sudo reboot

## 9. UNPLANNED INCIDENT: QEMU display + SSH refused after revert reboot

Symptom: virt-manager graphical console showed no display output after
reboot. SSH to 192.168.122.174 returned "Connection refused."

Diagnostic chain:
$ sudo virsh list --all         -> ubuntu24-lab: running (ruled out crash)
$ sudo virsh domifaddr ubuntu24-lab -> confirmed live IP
$ ssh ubuntulab@192.168.122.174 -> Connection refused (not timeout - port
  reachable, nothing listening)
$ sudo virsh console ubuntu24-lab -> blank (no serial output configured,
  not evidence of a hung system)
$ sudo virsh dominfo ubuntu24-lab (x2, seconds apart) -> CPU time
  1530.6s -> 1530.8s: confirmed VM actively executing, not frozen

$ sudo virsh shutdown ubuntu24-lab -> clean ACPI shutdown succeeded
$ sudo virsh start ubuntu24-lab
$ virt-viewer -> graphical console rendered correctly this time; VM
  confirmed fully booted, GRUB revert confirmed live (ro quiet splash
  vt.handoff=7 present in dmesg)
$ ssh ubuntulab@192.168.122.174 -> still "Connection refused"

Root cause (found from inside the VM via console access):
$ systemctl status ssh -> "Unit ssh.service could not be found"
$ dpkg -l | grep openssh-server -> empty (not installed)

Genuine root cause: openssh-server was never installed on this VM.
Unrelated to the GRUB change, the reboot, or the display issue - a
pre-existing gap that happened to surface at the exact moment SSH access
was needed, initially misread as "reboot broke something."

Fix:
$ sudo apt install openssh-server -y
$ systemctl status ssh.socket -> active (listening), 0.0.0.0:22
(socket activation confirmed - ssh.service itself stays inactive/dead
until a connection triggers it, which is expected, not a fault)

$ ssh ubuntulab@192.168.122.174  -> successful login, confirmed end to end
