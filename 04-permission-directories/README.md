# 04 — Permissions and Directories

File operations, mode bits, ownership, umask and ACLs. Covers who is
allowed to do what to a file or directory, why access can fail when the
file's own mode looks right, and why the same steps gave different
results on Ubuntu and Rocky. Run on both, because their default umask
differs.

## Must-cover topics

- `mv` on one filesystem keeps the inode; across filesystems `strace`
  shows `renameat2` fail with EXDEV, then a copy and an unlink. `cp`
  makes a new inode; `cp -p` keeps the mtime
- Deleting removes a name from a directory, so the directory's `w` and
  `x` decide it, not the file's mode. A file at 000 only triggers a
  prompt
- Directory `r` lists names, `x` reaches a known name, and `x` is also
  needed to resolve `.` from inside. At 111 `cat` works and `ls` fails.
  Change a directory's mode from its parent, never with `chmod .` from
  inside
- `chown` is root only. `chgrp` is root, or the owner to a group they
  belong to
- The kernel uses one class only: owner, else group, else other
- Default umask is 0002 on Ubuntu and 0022 on Rocky, which changed the
  result of the same chown lab. Files start from 666, directories from
  777
- On a file with an ACL, `chmod` sets the mask, which caps named-user
  and group entries. `+` in `ls -l` is the tell; `getfacl` shows
  `#effective`
- On Rocky, `mv` kept the SELinux label and `cp` used the destination
  default (one run, mechanism not traced)

## Structure

- `test-log.md` — dated transcript of commands run and real output
- `break/` — reproducible faults, all four run on Ubuntu and Rocky
  - `01-wrong-config-ownership.sh`
  - `02-acl-mask-blocks-reader.sh`
  - `03-directory-execute-removed.sh`
  - `04-umask-hides-new-files.sh`
- `fix/` — one repair per break script
  - `01-correct-config-ownership.sh`
  - `02-restore-reader-access.sh`
  - `03-restore-directory-execute.sh`
  - `04-fix-umask.sh`
- `postmortem/` — root cause, detection and handover, one per break
  - `01-config-ownership.md`
  - `02-acl-mask.md`
  - `03-directory-execute.md`
  - `04-umask-hides-files.md`
- `drills/` — cold scenario questions with answers
  - `01-permissions-scenario.md`

Break scripts create a `labreader` account and files under `/tmp` or
`/etc/drilltest.conf`. Run one pair at a time, on a snapshot.

## Open items

- Breaks 01 to 04 ran on both distros. SELinux contexts on the Rocky break files were not recorded.
- Why `mv` kept the SELinux label across filesystems was not traced.
- A systemd service's umask was not read back; the `systemd-run` test
  sent its output to the journal and was never checked.
- Whether `setfacl` changes the SELinux context was not checked.
- `chmod .` failing inside a 444 directory was explained and tested
  (04-I), but only on Ubuntu.
