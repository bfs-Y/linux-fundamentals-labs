# 02 — Logs and Auditing

Log literacy module. Covers where logs live, why a query can come back
empty when something did happen, and what silently stops logging or
deletes evidence. Run on Ubuntu 24.04 and Rocky 10, because their
defaults differ.

## Must-cover topics

- Two logging pipelines: journald (binary, indexed, read with
  `journalctl`) and rsyslog (plain text under `/var/log`), and which one
  to check first
- Persistent vs volatile journal storage: `/var/log/journal` existing is
  the state evidence, and a marker written with `logger` that survives a
  reboot (`journalctl -b -1`) is the behavioral proof. Ubuntu was
  persistent and Rocky volatile out of the box on these VMs
- Why a query returns nothing: wrong time window or timezone, wrong boot,
  wrong source or unit (`-u ssh` vs `-u sshd`), logging broken, or no
  permission to read the data
- Disk exhaustion on a log filesystem: loud failure from `dd`, ext4's 5%
  root reserve, and `df` (unprivileged view) vs `stat -f` (live) vs
  `tune2fs -l` (can be stale while mounted)
- Log rotation: a rename keeps the inode, `postrotate` sends SIGHUP so the
  daemon reopens its file, and `rotate N` silently deletes the oldest
  copy on rotation N+1
- Boot and time-window queries: `--list-boots`, `-b`, `--since` and
  `--until`

## Structure

- `test-log.md` — dated transcript of commands run and real output
- `break/` — reproducible, self-inflicted faults
  - `01-loop-filesystem-full.sh`
  - `02-rotation-deletes-evidence.sh`
- `fix/` — one repair per break script
  - `01-reclaim-space.sh`
  - `02-safe-rotation-config.sh`
- `postmortem/` — root cause, detection method, time-to-resolution, one
  change, per incident
  - `01-loop-filesystem-full.md`
  - `02-rotation-deletes-evidence.md`
  - `03-empty-query-no-read-permission.md`
- `drills/` — cold scenario questions with answers

Both break scripts run against a throwaway loop filesystem or a directory
under `/tmp`, never against the real `/var/log`.

## Open items

- Crash test, Ubuntu (one run): wrote a `logger` marker, ran `sync`, then
  hard powered off the VM with `virsh destroy`. After boot, the marker was
  in `journalctl -b -1`, and the `.journal~` count rose from 22 to 24. The
  two new files are dated 2026-10-17 03:22 and 03:24. `last -x` showed a
  `reboot` with no preceding `shutdown`. This ties `~` files to unclean
  stops. Not tested: a write with no `sync`, on either box. Rocky was crash-tested once with the same result: the marker survived and two new `.journal~` files appeared (one 24 MiB, cause not checked).
- On Rocky, a root-level append to a full loop filesystem failed even
  though `stat -f` showed free blocks in the reserve. Journal or metadata
  overhead is a hypothesis; it was not proven.
