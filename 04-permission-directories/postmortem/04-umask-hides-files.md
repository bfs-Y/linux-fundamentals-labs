# Postmortem: umask 077 hid a new config from its group

Date: 2026-10-22. Ubuntu 24.04.

A script that creates a config for another account ran with umask 077, so the file started at 600. The group was set correctly to `labreader`, but the mode gave the group nothing, so `labreader` got "Permission denied".

I found it because `ls -l` showed the right group and a mode with no group bits. The fix for the existing file was `chmod 640`. A new file made under umask 027 came out `-rw-r-----`, so the next file is right too.

For whoever takes over: `chmod` fixes one file and `umask` fixes what the process creates next. Check the umask of whatever creates the file. A service does not use your terminal's value, and I did not prove what it uses.
