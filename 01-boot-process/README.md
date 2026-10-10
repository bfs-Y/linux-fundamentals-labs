# 01 - Boot Process

I ran this module on the Ubuntu 24.04 VM, with a few checks on the Fedora
host. It was mostly reading logs to see what happened during boot, plus
one small, reversible change to the boot settings.

## What I covered

- The boot order: firmware, GRUB, kernel, initramfs, systemd, login.
- `dmesg` against `journalctl -b`. `dmesg` reads the kernel's own buffer,
  which starts when the kernel does. The journal can only hold what
  arrived after systemd started, so it imports the kernel messages a bit
  later. On my VM that was one second. `dmesg` needed `sudo`, because the
  kernel restricts who can read that buffer. Its timestamps are seconds
  since the kernel started, and `dmesg -T` turns them into dates.
- How the root filesystem is named. The kernel command line points at it
  by UUID, not by a name like `/dev/vda2`, because those names can change
  from one boot to the next. `blkid` showed the same UUID that `dmesg` did.
  It also showed that a partition has its own ID (PARTUUID), separate from
  the ID of the filesystem on it. My VM uses `vda`, my Fedora host uses
  `nvme0n1p`.
- Reading errors without panicking. `journalctl -p err` showed errors on
  a machine that had booted fine, all from desktop services. Long lines
  looked cut off at a `>`, but that was the pager, and `--no-pager` showed
  the full text.
- Changing the kernel command line the safe way. I edited
  `/etc/default/grub`, ran `update-grub`, and checked the result in
  `/boot/grub/grub.cfg` before rebooting. Then I put it back.
- A real problem I hit by accident. After the second reboot, SSH said
  "Connection refused". The VM was running, and the cause turned out to be
  that `openssh-server` wasn't installed.

## What's in this folder

- `test-log.md`: the commands I ran and what they printed.
- `break/`: `01-grub-verbosity-change.sh` removes `quiet splash` from the
  boot settings. `02-missing-sshd.sh` removes the SSH server, so it cuts
  off remote access. Only run it if you can still reach the VM's console.
- `fix/`: `01-revert-grub-verbosity.sh` and `02-restore-sshd.sh`.
- `postmortem/`: a short write-up for each break.
- `drills/`: questions with answers.
