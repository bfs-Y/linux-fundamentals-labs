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
  permission. On Rocky a plain search for a time the machine was running
  showed nothing, and the same search with `sudo` showed 300 lines. I
  first decided the entries were lost, and `journalctl --header` proved
  that wrong. Later I found ACL entries on the journal file that give
  `wheel` and `adm` read access, and I don't know when they appeared.
  Next time: run it with `sudo`, and check `getfacl` on the file as well
  as `id`, because `id` doesn't show access that comes from an ACL.
- To prove the journal persists, check the folder and also reboot with a
  `logger` marker and find it with `journalctl -b -1`. The folder shows
  the setup and the marker shows the result.
- `df` at 100% is what a normal user sees. `stat -f` is the live number
  and `tune2fs -l` can be stale on a mounted filesystem. Don't use
  `tune2fs` free-block numbers during an incident.
- `rotate N` deletes the oldest copy silently on rotation N+1. A missing
  log line can mean it was never written or that rotation removed it.
- Ubuntu and Rocky differ again: Ubuntu keeps the journal by default and
  Rocky didn't, so I made the folder by hand. Rocky's folder first
  showed `.` (an SELinux label) and later `+` (an ACL), and both
  machines' journal folders give read access to `adm`, and Rocky's also
  to `wheel`. `ubuntulab` is in `adm` and `bfs` is in `wheel`. Check each
  box instead of assuming.
- Still open: why the root write failed on Rocky with free blocks left.

## 2026-10-17 - Module 03

- A hold or lock only hurts when something else needs a different version of the held package. With no gap between installed and candidate, the hold is invisible. That's why one can sit there for months and then break a deploy.
- "held broken packages" also showed up when no hold was involved. I ran `apt-mark showhold` after the error and got nothing, and the cause was a version pin in both directions. I'll check `showhold` first from now on.
- `dpkg -S /bin/ls` finds nothing on Ubuntu because /bin is a symlink and dpkg matches the recorded path literally. `rpm -qf` resolves it. Same question, different lookup.
- The status file's mtime is just the last dpkg run. Who and when came from the sudo journal.
- I pasted template blanks (`VERSION`, `____`) into the terminal twice. sudo logged them. Read before pasting.
- I ran a Rocky block on the Ubuntu box. Check the prompt first.

## 2026-10-22 - Module 04

- Deleting a file removes a name from a directory, so the directory's
  `w` and `x` decide it, not the file's mode. A 555 directory blocked
  `rm` on a 664 file. A 000 file in a 755 directory only gave a
  "write-protected" prompt.
- A folder's `r` lists names and `x` reaches them. With `r` only, `ls`
  printed the name and `ls -l` printed `?` for everything else. With `x`
  only, I could open a file by name but not list the folder. I locked
  myself out by running `chmod 444 .` from inside a folder: without `x`
  even `.` can't be resolved (`stat .` failed). I fixed it from the
  parent with the full path.
- `chown` needs root. `chgrp` works for the owner only to a group they
  belong to. The kernel uses one class only (owner, else group, else
  other), so after the owner changed I lost access through the group
  bits and then through "other".
- Ubuntu's default umask is 0002 and Rocky's is 0022. That is why the
  same chown lab let me append on Ubuntu and not on Rocky. I proved the
  values differ. I don't know why the defaults differ.
- `umask 077` made a new file 600, so the right group still got nothing.
  `chmod 640` fixes the one file, and `027` in the writing script fixes
  the next one, because it gives the group read and keeps everyone else
  out.
- `cp` copies the source mode and then applies the umask. `cp -p` ignores
  the umask and also keeps the mtime. My first test used a umask too
  loose to show this, so I needed a second one with umask 077. A copy of
  an executable keeps its `x` bits.
- `ls -l` doesn't show everything that decides a read. A `+` at the end
  means an ACL, and with an ACL the group column shows the mask, not the
  owning group. `chmod 600` set the mask to `---` and cancelled
  labreader's entry. `getfacl` showed it as `#effective:---`. When an
  `ls -l` line ends in `+`, run `getfacl` before trusting it.
- On Rocky, `mv` into `/dev/shm` kept the SELinux label and `cp` took the
  destination default. I saw it once and did not trace why.
- Cleanup scripts: on Rocky, `sudo -u` can leave a `systemd --user`
  process behind, and `userdel` refuses until it ends. The fix scripts
  now check with `id` that the account is really gone before they say
  "removed". Don't throw away error output in a cleanup script.
- I moved the cron pair to module 14. Cron started the job in the
  account's home folder, so a relative path failed under cron and worked
  by hand, and the error went nowhere (Ubuntu logged "No MTA installed,
  discarding output"). That is the environment, not permissions.
- Mistakes: I pasted template blanks (`VERSION`, `____`) into the
  terminal, ran a Rocky block on the Ubuntu box, and left most guess
  lines empty.
- Still open: why the default umask differs, why `mv` kept the SELinux
  label, and whether breaks 01, 03 and 04 behave the same on Rocky.
