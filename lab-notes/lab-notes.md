# Lab Notes - patterns and open threads

## 2026-09-17 - Module 00

- bash looks for a command in this order: alias, function, builtin, then
  a program found through `$PATH`. `type -a` shows every match. `which`
  and `command -v` only give the final answer and can miss an alias.
- An empty `$PATH` entry means "look in the current directory", not "look
  nowhere". I want to remember this for the later modules (services,
  cron), where the environment isn't the one in my terminal.
- My `find` over `/tmp` also searched systemd folders I don't own and
  printed permission errors. Next time I'll use a test folder or
  `-maxdepth`.
- I tried a stale command cache first when `$PATH` broke. `hash` was
  empty, so that was wrong. A dummy `ls` in the current directory showed
  what was really happening. A cheap test that can prove a guess wrong in
  one command beats defending the guess.

## 2026-09-18 - Module 01

- `dmesg` reads the kernel's own buffer. The journal can only hold what
  came after systemd started, so it imports the kernel messages later. On
  my VM that was one second.
- journalctl's pager cuts long lines with a `>`. The data isn't cut, and
  `--no-pager` shows all of it.
- `-p err` doesn't mean the boot failed. My healthy VM had errors from
  desktop services all night.
- A UUID is the ID of a filesystem and a PARTUUID is the ID of a
  partition. Names like `/dev/sda1` can change between boots. I saw
  `sd`, `vd` and `nvme0n1p` names on different machines.
- "Connection refused" and a timeout are different problems. Refused
  means something answered and nothing was listening.
- A new problem right after a change isn't proof the change caused it. I
  nearly blamed a GRUB revert for an SSH server that was never installed.
  `virsh` let me check the VM from the host before I touched the guest.
- Ubuntu starts ssh through a socket. `ssh.socket` listens on port 22 and
  starts `ssh.service` when someone connects, so `inactive` on the
  service is normal.

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

## 2026-10-17 - Module 03

- A hold or lock only hurts when something else needs a different version of the held package. With no gap between installed and candidate, the hold is invisible. That's why one can sit there for months and then break a deploy.
- "held broken packages" also showed up when no hold was involved. I ran `apt-mark showhold` after the error and got nothing, and the cause was a version pin in both directions. I'll check `showhold` first from now on.
- `dpkg -S /bin/ls` finds nothing on Ubuntu because /bin is a symlink and dpkg matches the recorded path literally. `rpm -qf` resolves it. Same question, different lookup.
- The status file's mtime is just the last dpkg run. Who and when came from the sudo journal.
- I pasted template blanks (`VERSION`, `____`) into the terminal twice. sudo logged them. Read before pasting.
- I ran a Rocky block on the Ubuntu box. Check the prompt first.
