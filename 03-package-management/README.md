# 03 — Package Management

Holds, version locks, and exact-version dependency pins. Covers why an
install fails when the package you asked for isn't the cause, and how to
prove which package is. Run on Ubuntu 24.04 (apt/dpkg) and Rocky 10
(dnf/rpm), because the hold mechanisms differ.

## Must-cover topics

- Two layers: dpkg/rpm install single files and record them in a local
  database; apt/dnf read repo metadata and solve dependencies
- Ownership queries: `dpkg -S` matches the recorded path literally, so
  `/bin/ls` finds nothing when `/bin` is a symlink to `usr/bin`; `rpm -qf`
  answered for both paths
- Where state lives: `/var/lib/dpkg/status` (plain text, holds are a word
  in the Status line) vs `rpmdb.sqlite` (binary SQLite)
- Holds and locks: `apt-mark hold` is built in; dnf needs the versionlock
  plugin and stores locks in `/etc/dnf/plugins/versionlock.list`
- A hold only breaks something when the held package is behind what
  another package requires with an exact `=` pin
- `held broken packages` also appears with no hold at all, so run
  `apt-mark showhold` first; an empty result means a version-pin conflict
  or repo problem
- `apt install pkg=version` overrides a hold
- Who and when: the `status` mtime is just the last dpkg run; the sudo
  journal gives the user and time

## Structure

- `test-log.md` — dated transcript of commands run and real output
- `break/` — reproducible faults (not yet run end to end)
  - `01-held-nginx-common.sh`
  - `02-versionlock-hplip.sh`
- `fix/` — one repair per break script
  - `01-release-nginx-common.sh`
  - `02-delete-versionlock.sh`
- `drills/` — cold-recall questions with answers from my own evidence
  - `01-held-packages-scenario.md`
- `postmortem/` — root cause, detection, and handover notes
  - `01-held-dependency-pin.md`

The break scripts change real packages (they downgrade nginx or hplip
and place a hold or lock). Run them on a snapshot, not on a box you care
about.

## Open items

- The break and fix scripts have not been run end to end.
- Why `rpm -qf /bin/ls` resolves the symlink and `dpkg -S` doesn't was
  observed, not proven.
- On Rocky, the lock file header time (02:36:09) and the sudo journal
  time (02:35:28) differ by about 40 seconds. Cause not checked.
- `exclude=` in dnf.conf can produce the same "filtered out by exclude
  filtering" message. Not tested.
- The sudo journal only shows a hold if it went through sudo. A hold
  placed from a root shell was not tested.
- `libgs` joined the ghostscript upgrade without appearing in the error.
  Why was not checked.
