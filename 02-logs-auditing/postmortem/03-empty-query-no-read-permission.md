# Postmortem - empty journal search on Rocky

**What caused it:** on Oct 7 a plain `journalctl` search as `bfs` for
02:30 to 03:05 returned `-- No entries --`. At the time `bfs` was in
`wheel` and not in `adm` or `systemd-journal`. Without `sudo`, I only saw
my own user journal, which started at 03:05:40.

**How I found it:** the first guess was that the entries had been lost.
That was wrong. `sudo journalctl --header` showed `system.journal` starting
at 01:19:52, the start of the boot. Running the same search with `sudo`
returned 300 lines.

**How it was fixed:** nothing was broken, so nothing needed fixing. I read
the journal with `sudo`.

**What I found later:** Rocky's journal folder and file now have ACL
entries that give `wheel` and `adm` read access (`getfacl` on
`/var/log/journal/*/system.journal`), and a plain `journalctl -b` shows
nearly the same number of lines as `sudo` (2959 against 2988). The rules
that set those entries are on lines 27 to 32 of
`/usr/lib/tmpfiles.d/systemd.conf`. I don't know when the entries
appeared. Rocky has rebooted since Oct 7, and my guess is that a boot
applied the rules, but I never tested that. So I can't say whether `bfs`
was blocked on Oct 7 because the entry didn't exist yet.

**What I'd do differently:** when a search is empty for a time I know the
machine was running, run it with `sudo` before deciding the logs are
missing. Checking `id` isn't enough, because read access can come from an
ACL entry, and `getfacl` on the journal file is what shows it. On Ubuntu,
`ubuntulab` is in `adm` and the journal folder's ACL has an `adm` entry
(I only checked the folder), so the same search worked without `sudo`,
and I never noticed the difference until Rocky showed it.
