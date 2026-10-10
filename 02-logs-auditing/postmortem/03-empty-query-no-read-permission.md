# Postmortem - empty journal search on Rocky

**What caused it:** my user `bfs` is in `wheel` but not in a group that
can read the system journal. Without `sudo`, `journalctl` only showed my
own user journal, which started at 03:05:40. The search for 02:30 to
03:05 returned `-- No entries --`.

**How I found it:** the first guess was that the entries had been lost.
That was wrong. `sudo journalctl --header` showed `system.journal` starting
at 01:19:52, the start of the boot. Running the same search with `sudo`
returned 300 lines.

**How it was fixed:** nothing was broken, so nothing needed fixing. I read
the journal with `sudo`.

**What I'd do differently:** when a search is empty for a time you know
the machine was running, run it with `sudo` and check `id` before
deciding the logs are missing. On Ubuntu, `ubuntulab` is in `adm`, so the
same search worked without `sudo`, and I never noticed the difference
until Rocky showed it.
