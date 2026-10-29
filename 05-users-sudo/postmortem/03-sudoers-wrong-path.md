# Postmortem: sudoers rule passed visudo but did nothing

Date: 2026-10-28 (Ubuntu), 2026-10-29 (Rocky).

`labreader` was given one command through a drop-in, `/etc/sudoers.d/labreader`, but the rule named `/opt/nonexistent/systemctl`. `visudo -c` said "parsed OK" and `sudo -l -U labreader` listed the rule, yet running the real command gave "sudo: a password is required".

visudo checks syntax, not whether the path exists. The script's output showed this on both distros.

The fix was to find the real path with `command -v systemctl` (`/usr/bin/systemctl` on both), validate the new rule with `visudo -cf` before installing it, then test it. `status ssh` was allowed and `restart ssh` was refused.

Two traps came out of it. Sudoers matches arguments exactly: adding `--no-pager` made the same rule refuse. And on Rocky `/etc/sudoers.d` is root-only, so my first fix script, which tested the file as a normal user, could not see the rule. It now uses `sudo test`.

For whoever takes over: validate a rule with `visudo -cf` before installing it, then run the exact command as the target user, and use `sudo -l` to check what a user may run. Never edit `/etc/sudoers` directly.

Not tested: a wildcard rule overriding a later rule, and the `sshd` unit name on Rocky (the rule says `ssh`).
