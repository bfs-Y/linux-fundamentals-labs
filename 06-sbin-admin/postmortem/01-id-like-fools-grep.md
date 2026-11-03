# Postmortem: a plain grep of os-release took the family list for the machine's identity

Date: 2026-11-03, run on Ubuntu 24.04.5 and Rocky Linux 10.2.

A script that asks "is this Debian?" with `grep debian /etc/os-release` gets the wrong answer on Ubuntu. The file has `ID=ubuntu` and `ID_LIKE=debian`, and grep only matches text, so the family line counted as the machine's identity. On Ubuntu `grep -c debian` printed 1 and the only match was line 7, `ID_LIKE=debian`. The anchored test `^ID=debian$` printed 0.

Rocky showed the same trap with more matches. `grep -c fedora` printed 2: line 5, `ID_LIKE="rhel centos fedora"`, and line 10, `LOGO="fedora-logo-icon"`. So a match can come from a line that has nothing to do with the distro's name. The `ID` line was `ID="rocky"`, and the anchored test `^ID=fedora$` printed 0, so Rocky is correctly not Fedora.

The fix script tests the `ID` line only. On Ubuntu it printed `ID line: ID=ubuntu` and `Right test: ID equals debian -> 0`. On Rocky it printed `ID line: ID="rocky"` and `Right test: ID equals fedora -> 0`. Both runs removed `/tmp/oslab`, and `ls -d /tmp/oslab` said "No such file or directory".

Rocky quotes the value and Ubuntu doesn't. On the real Rocky file, `'^ID="\?rocky"\?$'` printed 1 and `'^ID=rocky$'` printed 0, so a test without the optional quotes misses a line that is there.

The break script's last line said "the matching line is only the family list". On Rocky that was false, because one of the two matches was `LOGO=`. The script counts matches and never checks which lines they were.

I did not test the optional-quote pattern against `ID=ubuntu` on Ubuntu. I did not test a machine that really is the distro being tested, so I haven't shown the test says yes when it should. I only touched a copy under `/tmp`, never `/etc/os-release`.

For whoever takes over: test the `ID` field, not the whole file, and allow for quotes around the value. Run `grep -n` first to see which lines a pattern really matches.
