# Postmortem: apt install nginx blocked by a held dependency

**Date:** 2026-10-17 | **Box:** Ubuntu 24.04 | **Also reproduced on Rocky 10 with dnf versionlock**

`apt install nginx` failed because nginx 1.24.0-2ubuntu7.18 depends on `nginx-common (= 1.24.0-2ubuntu7.18)`, an exact pin, and nginx-common was held at 1.24.0-2ubuntu7. apt may not change a held package, so it had no way to satisfy both and gave up. The package that failed (nginx) was not the package causing it (nginx-common). I found it by running `apt-mark showhold`, which named nginx-common, then `apt-cache policy nginx-common`, which showed Installed ubuntu7 against Candidate .18. That gap is what a hold looks like. `journalctl _COMM=sudo` showed who held it and when (ubuntulab, 01:30:21), which the dpkg status file cannot tell you. The fix was `apt-mark unhold nginx-common` followed by `apt install nginx`: 2 upgraded, 0 removed.

**For whoever takes the shift:** run `apt-mark showhold` before anything else. "held broken packages" is apt's generic give-up message and showed up in my lab even with no hold, so an empty `showhold` means look at version pins and repos instead. Never answer y to a transaction that removes packages without reading the list. On Rocky the same failure reads "filtered out by exclude filtering", and `/etc/dnf/plugins/versionlock.list` is the place to look.
