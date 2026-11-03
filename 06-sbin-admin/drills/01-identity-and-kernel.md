# 06 - Sbin Admin: Day 1 Drill (identity and kernel)

Scenario: a server with no GUI and no documentation. Who is this machine and what is it running on?

1. In the `strace` run of `uname -r`, which call asked the kernel and which sent the text to the terminal?

`uname(...) = 0` asked the kernel, and `write(1, "7.0.0-42-generic\n", 17) = 17` sent it to file descriptor 1. The first trace showed no `openat` of `/proc/sys/kernel/osrelease`, so `uname` doesn't read that file. I did not trace `hostnamectl` far enough to see which directory the daemon's `os-release` opens pointed at.

2. Where does file descriptor 1 point?

Wherever the shell set it before the program started. `ls -l /proc/self/fd/1` showed `/dev/pts/0` directly and `pipe:[20557]` when piped into `cat`.

3. `/etc/os-release` is a symlink on both VMs. Where does it point and how did I check the content is the same?

It points to `../usr/lib/os-release`, and `readlink -f` printed `/usr/lib/os-release`. `md5sum` of both paths printed `f8477ebe31c6e56da137eaef4b185242` on Ubuntu.

4. Which field should a script test to tell the distro, and why?

`ID`. On Ubuntu `grep -c debian` printed 1, matching only `ID_LIKE=debian`, while `'^ID=debian$'` printed 0. On Rocky `grep -c fedora` printed 2 (`ID_LIKE` and `LOGO`). I did not run the optional-quote pattern against `ID=ubuntu` on Ubuntu.

5. `/proc/uptime` shows size 0. What does that say about files in `/proc`?

`ls -l` said 0, `wc -c` counted 16, and two `cat`s two seconds apart gave 2580.30 and 2582.30. The content is generated when it is read.

6. What detail of the `ID` lines broke a pattern?

Rocky quotes the value (`ID="rocky"`) and Ubuntu doesn't (`ID=ubuntu`). On Rocky `'^ID=rocky$'` printed 0 and `'^ID="\?rocky"\?$'` printed 1.
