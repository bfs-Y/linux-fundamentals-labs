# Postmortem: cron job could not find its config

Date: 2026-10-22. Ubuntu 24.04. Not run on Rocky.

A cron job ran `cat app.conf`. By hand, from the config's folder, it worked. Under cron it ran, but the file wasn't there: cron starts the job in the account's home folder, so the relative path pointed at nothing. The cron log showed `CMD (cat app.conf)` and "No MTA installed, discarding output", so the error text was thrown away and the log gave no sign of failure.

The fix script showed the cause by running the command from the account's home, which gave "No such file or directory". The fix was an absolute path, with the job's output redirected to a file so the next failure shows up somewhere.

For whoever takes over: never use relative paths in cron, and redirect output. A job that "ran" in the log may still have failed. Check where its stdout and stderr go.
