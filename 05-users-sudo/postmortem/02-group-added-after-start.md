# Postmortem: user added to a group, running process still denied

Date: 2026-10-28. Ubuntu 24.04 and Rocky 10.

`labreader` was added to group `labdb` with `usermod -aG`, and `db.conf` was `root:labdb 640`. `id labreader` listed `1002(labdb)`, and a fresh `sudo -u labreader cat` read the file. A loop that was already running as `labreader` kept logging "denied".

A process keeps the groups it started with. The script's output showed it: the loop's `Groups:` line in `/proc/<pid>/status` stayed `1001` before and after the change, while `id` read the database and showed the new group. This was identical on both distros.

The fix was to stop the loop and start it again. The new process showed `Groups: 1001 1002` and logged "ok".

For whoever takes over: when someone says "I was added to the group and it still fails", compare `id <user>` with `/proc/<pid>/status` of the failing process. A new login or a restart of the service picks up the group. The file and the group were never wrong.

Not tested: a real service restarted through systemd, and whether `newgrp` or `sg` helps an existing shell.
