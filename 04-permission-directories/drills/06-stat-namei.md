# Drill 06 — stat and namei

Inspect detailed file metadata and trace path permissions.

Commands:
stat /path/to/file
namei -l /path/to/file

What to look for:
- Unexpected ownership (Uid/Gid)
- Permission octal vs symbolic
- Timestamps — Access/Modify/Change
- namei shows which directory in a path blocks access

Example:
stat /etc/shadow
namei -l /etc/shadow
