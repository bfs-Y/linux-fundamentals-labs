# Postmortem — xargs whitespace-splitting bug

**Root cause:** `xargs` splits its input on whitespace by default. A
filename containing a space (`/tmp/my file.log`) was torn into two separate
arguments at the space boundary, so `rm` received two bogus paths instead
of the one real one.

**Detection method:** Manual verification with `ls /tmp/my*.log` after the
"cleanup" ran — the file was still present despite `rm` executing with no
apparent early failure.

**Time to resolution:** Immediate once the whitespace-splitting mechanism
was understood; root cause was reasoned out from first principles, not
looked up.

**One thing to do differently:** Always use `find -print0 | xargs -0` when
piping filenames into `xargs`, since a null byte can never legally appear
in a filename and is the only delimiter guaranteed not to collide with the
data.
