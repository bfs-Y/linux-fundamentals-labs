# 05 - Users and Sudo

I ran this module on Ubuntu 24.04 and Rocky 10 with a test account called
`labreader`. The main thing I learned: what `id` prints is not always what
a process that is already running can do, and sudo can accept a rule that
will never match anything.

## What I covered

- Baseline. `id`, `groups` and `/proc/self/status` agreed on my own
  account, and `getent passwd` matched `/etc/passwd` for a local account.
  I didn't test an SSSD or LDAP account. `/etc/shadow` is root:shadow 640
  and `cat` was denied.
- A group added after a process started. After `usermod -aG`, `id
  labreader` and a fresh `sudo -u labreader` showed the new group, and a
  loop that was already running kept getting "denied". Restarting it
  fixed it. On Ubuntu, plain `groups` in a shell that started before the
  change printed the old groups, and `groups labreader` printed the new
  ones.
- `usermod -G` without `-a` replaces the supplementary groups instead of
  adding one. The admin group is `sudo` on Ubuntu and `wheel` on Rocky,
  so the script picks whichever exists. It dropped `audio` and `video`
  the same way on both.
- `su` against `sudo`. `sudo -i` starts in `/root` and `sudo -u root`
  keeps my folder. `su labreader` keeps my folder, and `su - labreader`
  goes to the account's home. On Rocky, `su` without `-` also kept my
  `PATH`, and `su -` used labreader's own. On Ubuntu, root's password is
  locked, so `su root` failed with an authentication failure while
  `sudo -i` worked. On Rocky, root has a password.
- A sudoers rule that did nothing. `visudo -c` said "parsed OK" for a
  rule naming `/opt/nonexistent/systemctl`, because it checks the syntax
  and not whether the path exists. Sudo matches arguments exactly, so
  adding `--no-pager` made the same rule refuse. On Rocky,
  `/etc/sudoers.d` is root-only, so a plain `[ -f ]` test couldn't see
  the rule, and the scripts use `sudo test`.

## What's in this folder

- `test-log.md`: the commands I ran and what they printed.
- `break/`: `01-usermod-missing-a-flag.sh`, `02-group-added-after-start.sh`
  and `03-sudoers-wrong-path.sh`.
- `fix/`: one repair for each break, with the same numbers.
- `postmortem/`: a write-up for each of the three.
- `drills/`: questions with answers.

## Not finished

- I didn't test a wildcard rule overriding a later rule, or the `sshd`
  unit name on Rocky (the rule says `ssh`).
- I didn't check whether a profile changes `PATH` under `su`.
- On Rocky, `userdel` refused right after `su labreader` and worked a few
  seconds later. `loginctl terminate-user` said the user wasn't logged
  in, and I don't know what ended the process.
