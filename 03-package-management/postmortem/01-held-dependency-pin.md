# Postmortem: apt install nginx blocked by a held package

Date: 2026-10-17. Ubuntu 24.04. I reproduced the same failure on Rocky 10 with dnf versionlock.

`apt install nginx` failed, and at first glance nginx looked like the problem. It wasn't. nginx 1.24.0-2ubuntu7.18 depends on `nginx-common (= 1.24.0-2ubuntu7.18)`, an exact version, and nginx-common was held at 1.24.0-2ubuntu7. apt won't change a held package, so no valid answer existed and it gave up.

I found it by running `apt-mark showhold`, which named nginx-common. Then `apt-cache policy nginx-common` showed Installed ubuntu7 and Candidate .18. That gap is what a hold looks like from the outside. The dpkg status file can't say who placed the hold or when. The sudo log can: `journalctl _COMM=sudo` showed ubuntulab ran `apt-mark hold nginx-common` at 01:30:21.

The fix was `apt-mark unhold nginx-common`, then `apt install nginx`. Result: 2 upgraded, 0 removed.

For whoever takes over: run `apt-mark showhold` first. "held broken packages" is apt's general give-up message, and I got it once with no hold at all, so an empty `showhold` means the problem is a version pin or the repos. Read the transaction list before you answer y. On Rocky the same failure says "filtered out by exclude filtering", and the lock lives in `/etc/dnf/plugins/versionlock.list`.
