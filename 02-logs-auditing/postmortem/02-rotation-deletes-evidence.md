# Postmortem - log rotation deleted the evidence

**What caused it:** my test config said `rotate 1` and had no `create`
line. After the second rotation the file with the 02:14 INCIDENT line was
deleted, and no error or warning was shown.

**How I found it:** `grep INCIDENT` found nothing in the directory. The
log looked like it had never recorded the event, but it had. Rotation
removed it.

**How it was fixed:** `rotate 4`, `weekly`, `compress`, `delaycompress`
and `create`. In the test the INCIDENT line survived four rotations and
was deleted on the fifth. `create` also gave me a fresh empty `app.log`
after every rotation, which `rotate 1` didn't.

**What I'd do differently:** pick the rotate count from how long it takes
someone to notice and investigate an incident, plus some margin. A
missing line in the logs can mean it was never written or that rotation
deleted it, so check the retention settings before trusting an empty
search.
