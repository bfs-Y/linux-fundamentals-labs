# Lab Notes — cross-module patterns and open threads

## 2026-09-17 — Module 00

- Command resolution order proven empirically: alias > function > builtin >
  $PATH external binary. `type -a` is the single tool that exposes every
  layer at once; `which`/`command -v` only show the final external-binary
  answer and can miss an intervening alias or function.
- An empty $PATH component means "search cwd," not "search nowhere" — a
  real, non-obvious gotcha worth carrying into later modules (09 services,
  14 cron) where environment differs from an interactive shell's.
- find's default scope in /tmp picks up systemd private-tmp dirs you don't
  own, producing unrelated Permission denied noise — scope find more
  tightly (-maxdepth, or a dedicated test dir) in future break scripts
  instead of running loose against shared directories like /tmp.
- Two wrong hypotheses were tested and killed with evidence (stale hash;
  then confirmed empty-PATH-searches-cwd) before landing on the real
  mechanism — worth remembering as a model for future debugging: cheap
  hypotheses first, killed fast by a single command, not defended.

## 2026-09-18 — Module 01

- dmesg reads the kernel's in-memory ring buffer directly (exists from the
  instant the kernel starts); journalctl -b depends on journald, a systemd
  component that can't run before systemd does. Proven with a 1-second gap
  between dmesg -T's and journalctl -b's timestamps for the same event —
  journald imports the kernel buffer retroactively, doesn't capture it live.
- journalctl's pager (less) truncates long lines with a trailing '>' — not
  the data itself being cut. --no-pager (or piping to cat) shows full text.
  Cost real time misreading truncated error messages before catching this.
- -p err severity does not mean boot failure. A fully healthy, successfully
  booted VM can show err-level noise from non-critical services (rtkit,
  gdm, pam) all night — read source/context before concluding anything's
  actually broken.
- UUID (filesystem identity, stamped at format time) vs PARTUUID (partition
  table slot identity) vs device path (/dev/sda1, /dev/vda2, /dev/nvme0n1p*
  — kernel-assigned, position-dependent, can shift between boots) confirmed
  as three genuinely separate identifiers on the same disk, across two
  different machines.
- Real incident: "Connection refused" vs a timeout are meaningfully
  different signals — refused means something reachable actively rejected
  the connection (nothing listening on that port); a timeout would mean no
  response at all. Worth internalizing as an immediate diagnostic fork,
  not just noise to work around.
- Don't default to blaming the most recent change (a reboot, a config edit)
  when a new symptom shows up at the same time — nearly misattributed a
  pre-existing missing-openssh-server gap to a GRUB revert that had nothing
  to do with it. virsh (list --all, domifaddr, dominfo, console) let the
  actual state get confirmed from the host side before ever touching the
  guest, which is the reusable pattern for this class of incident.
- Ubuntu uses socket activation for sshd by default: ssh.socket listens on
  22 and only starts ssh.service on first connection — ssh.service showing
  inactive (dead) is expected, not a fault, as long as ssh.socket is
  active (listening).

## 2026-10-08 - Module 02

- An empty search can mean five things, not four. The new one was
  permission. On Rocky my user could only read its own journal, so a
  search for a time the machine was running showed nothing. I first
  decided the entries were lost, and `journalctl --header` proved that
  wrong. Next time: run it with `sudo` and check `id` before blaming the
  logs.
- To prove the journal persists, check the folder and also reboot with a
  `logger` marker and find it with `journalctl -b -1`. The folder shows
  the setup and the marker shows the result.
- `df` at 100% is what a normal user sees. `stat -f` is the live number
  and `tune2fs -l` can be stale on a mounted filesystem. Don't use
  `tune2fs` free-block numbers during an incident.
- `rotate N` deletes the oldest copy silently on rotation N+1. A missing
  log line can mean it was never written or that rotation removed it.
- Ubuntu and Rocky differ again: Ubuntu keeps the journal by default and
  Rocky didn't, Ubuntu's journal folder has an ACL (`+`) and Rocky's has
  an SELinux label (`.`), and `ubuntulab` is in `adm` while `bfs` is only
  in `wheel`. Check each box instead of assuming.
- Still open: why the root write failed on Rocky with free blocks left,
  what the `.journal~` files on Ubuntu mean, and what a crash does to the
  journal.
