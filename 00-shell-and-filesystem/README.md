# 00 — Shell, Text, and Filesystem

Foundation module. Covers how Bash resolves a command before running it,
and how Linux actually represents "files and folders" underneath the
abstraction — not command trivia, the mechanism.

## Must-cover topics

- Command resolution order: alias > function > builtin > $PATH external
  binary, and the tools that expose it (`type -a`, `which`, `command -v`)
- PATH mechanics: how it's searched, what an empty component actually
  means (cwd, not "nowhere"), and how recovery works when it's broken
- Inodes: what one actually is, hard links vs symlinks, and what "deleting
  a file" really does at the filesystem level
- `find` + `xargs` interaction, and the whitespace-splitting failure mode

## Structure

- `test-log.md` — dated transcript of commands run and real output
- `break/` — reproducible, self-inflicted faults
  - `01-xargs-whitespace-bug.sh`
  - `02-path-corruption.sh` (must be `source`d, not run with `bash`)
- `fix/` — diagnosis-and-repair scripts, one per break script
  - `01-fix-xargs-whitespace.sh`
  - `02-restore-path.sh` (must be `source`d)
- `postmortem/` — root cause, detection method, time-to-resolution, one
  change, per incident
  - `01-xargs-whitespace.md`
  - `02-path-corruption.md`
