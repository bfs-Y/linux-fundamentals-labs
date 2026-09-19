# Postmortem — GRUB verbosity change (quiet/splash)

**Root cause:** Deliberately removed `quiet splash` from
`GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub` to observe full
verbose boot output instead of the graphical splash screen.

**Detection method:** Verified at every stage before reboot -
`grep`'d the edited source file, then `grep`'d the regenerated
`/boot/grub/grub.cfg` directly (not just the source), confirming the
change propagated through the full `/etc/default/grub` -> `update-grub`
-> `grub.cfg` pipeline. Post-reboot, confirmed live via
`dmesg -T`'s kernel command-line output.

**Time to resolution:** Immediate - planned, reversible change with a
`.bak` backup taken before editing.

**One thing to do differently:** `GRUB_TIMEOUT_STYLE=hidden` and
`GRUB_TIMEOUT=0` on this box mean the boot menu never displays without
holding Shift/Esc during boot - worth changing before relying on
"select the older kernel at GRUB" as a stated recovery path in any
future blast-radius assessment.
