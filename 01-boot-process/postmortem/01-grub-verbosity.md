# Postmortem - removing quiet splash from the boot settings

**What caused it:** this was on purpose. I took `quiet splash` out of
`GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub` to see a more verbose
boot, then rebooted.

**How I found it:** nothing went wrong, so this is about checking. I saved
a backup with `sed -i.bak`, ran `update-grub`, and grepped
`/boot/grub/grub.cfg` to confirm `quiet splash` was gone before I
rebooted. After the reboot, `dmesg -T` showed a kernel command line that
ended at `ro`.

**How it was fixed:** I copied the `.bak` file back, ran `update-grub`,
confirmed `quiet splash` was in `grub.cfg`, and rebooted. The next boot
showed `quiet splash` again.

**What I'd do differently:** my plan for a bad boot was to pick the older
kernel in the GRUB menu, but this VM has `GRUB_TIMEOUT=0` and a hidden
menu, so I'd have to hold Shift or Esc to even see it. I should have
known that before saying the older kernel was my way out.
