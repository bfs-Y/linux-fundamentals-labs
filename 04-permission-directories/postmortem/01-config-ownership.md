# Postmortem: service account refused its own config

Date: 2026-10-22. Ubuntu 24.04.

`/etc/drilltest.conf` was owned by root with mode 600, so the account that had to read it got "Permission denied". `ls -l` showed an ordinary locked-down file, which is why it looks fine at a glance.

I found it by checking the owner, group and mode, then comparing them with the account that runs the service. The fix was `root:labreader` with mode 640. The service account can read the file and cannot write it, and the owner stays root.

For whoever takes over: don't `chmod 644` or `chown` the file to the service. Change the group and add only `r`. Check who runs the service first.
