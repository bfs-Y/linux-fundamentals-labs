# 01 — Boot Process

Conceptual module. Covers the boot sequence from power-on through login,
and read-only forensics for reconstructing what happened during a boot
from log evidence alone — not adversarial GRUB recovery (that lives in a
harder module later, if built at all).

## Must-cover topics

- The six-stage boot sequence: firmware (UEFI/BIOS) -> bootloader (GRUB)
  -> kernel -> initramfs -> systemd -> login target
- `dmesg` vs `journalctl -b`: different sources (kernel ring buffer vs
  journald), different earliest-possible timestamps, and why
- Kernel command-line parameters (`ro`, `quiet`, `splash`) and where
  they're actually set (`/etc/default/grub` -> `update-grub` ->
  `/boot/grub/grub.cfg`, never edited directly)
- UUID vs device-path (`/dev/sda1`, `/dev/vda2`, `/dev/nvme0n1p*`)
  filesystem identification, and PARTUUID vs UUID
- Reading `-p err` output critically: severity level does not by itself
  mean boot failure

## Structure

- `test-log.md` — dated transcript of commands run and real output
- `break/` — a light, safe kernel-parameter change (removing `quiet
  splash`), reverted cleanly
- `fix/` — the revert, restoring from a `sed -i.bak` backup
- `postmortem/` — root cause, detection, time-to-resolution, one change,
  per incident (including the unplanned SSH/display detour, which
  produced better material than the planned exercise)
- `lab-notes` entries appended to the repo-wide running file

Anki-style drill cards for this module are kept off-repo, not committed
here.
