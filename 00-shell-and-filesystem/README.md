# 00 - Shell, Text, and Filesystem

This was my first module. I ran most of it on Ubuntu 24.04 and Rocky 10,
with a couple of checks on Fedora. The main thing I learned is that the
shell does a lot of lookup work before a command runs, and that a file
and its name are not the same thing.

## What I covered

- How bash decides what to run. The order is alias, then function, then
  builtin, then a program found through `$PATH`. `type -a` shows every
  match. On Fedora, `which` turned out to be an alias that feeds my
  aliases and functions into `/usr/bin/which`, because a separate program
  can't read the shell's memory. Rocky ships `/usr/bin/alias` as a real
  file and Ubuntu doesn't.
- How `$PATH` works. When I set it to an empty string, `ls` failed with
  "No such file or directory", not "not found". An empty entry in
  `$PATH` means "look in the current directory", so bash searched there
  and found nothing. Builtins like `echo` kept working. `chmod` didn't,
  because it's a program too.
- Inodes. A hard link is a second name for the same inode, so deleting
  one name left the data alone. A symlink has its own inode and only
  stores a path, so it broke when I deleted its target.
- The `find | xargs rm` problem. A file with a space in its name got split
  into two bad arguments, so the file survived. `find -print0 | xargs -0`
  fixed it.

## What's in this folder

- `test-log.md`: the commands I ran and what they printed.
- `break/`: two scripts, `01-xargs-whitespace-bug.sh` and
  `02-path-corruption.sh`. The second one has to be run with `source`, not
  `bash`, or the broken `$PATH` only lasts inside the script.
- `fix/`: a repair for each break, `01-fix-xargs-whitespace.sh` and
  `02-restore-path.sh` (also run with `source`).
- `postmortem/`: a short write-up for each break.
- `drills/`: questions with answers.
