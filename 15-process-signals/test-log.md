# Test Log — 15 Process Signals

This log tracks what was tested, what worked, what broke,
and what was learned across all sessions for this module.

---

## Zombie processes

Built a zombie deliberately using Python fork(). Confirmed it shows
up in ps with Z state and holds a PID but uses zero memory. Verified
the parent was sleeping and not calling wait() — exactly the broken
behavior that causes zombie accumulation in production.

Tried kill -9 on the zombie. Nothing happened. You cannot kill what
is already dead. Only the parent calling wait() cleans it up.

The cleanup script correctly identifies zombie parents and points to
strace as confirmation. The strace step needs sudo — worth noting for
environments with restricted privilege.

---

## Signal handling and trap

Built a backup script from scratch that handles SIGTERM, SIGINT and
EXIT. First attempt had a double-fire bug — EXIT triggered cleanup,
which called exit 1, which triggered EXIT again. Fixed by resetting
the trap as the first line inside the cleanup function.

Tested three scenarios:
- Killed mid-run — cleanup fired, temp file deleted, exit 1
- Normal completion — no cleanup message, exit 0
- SIGKILL — trap never fired, file left on disk

The SIGKILL test is the important one. No trap in the world stops
SIGKILL. That is why it is last resort only.

---

## ulimit and fork bombs

Set ulimit -u 50 on both terminals before running the fork bomb.
The bomb hit the limit immediately and died. System survived.
Without that limit it would have exhausted all PIDs and locked
the machine — including SSH access.

Applied permanent limits via /etc/security/limits.conf and PAM.
Changes require logout/login to activate. Verified the PAM line
was correctly added to /etc/pam.d/common-session.

---

## SIGHUP and nginx reload

Changed worker_connections in nginx.conf from 768 to 1024.
Sent SIGHUP to the master process using kill -1 $(cat /run/nginx.pid).
Master PID stayed the same. Workers got new PIDs. Config applied.
Zero downtime. Zero dropped connections.

This is the difference between a rolling reload and a hard restart.
In production with live traffic, this distinction matters enormously.

---

## nohup, tmux and job control

Tested all three methods of surviving terminal death:

nohup protects a process before it starts. Output goes to nohup.out.
Process TTY changes from pts/0 to ? after terminal closes.
No way to reattach — you are flying blind.

tmux gives you a persistent session you can walk in and out of.
Detach with Ctrl+b d. Reattach with tmux attach -t NAME.
Work keeps running exactly as you left it. Full visibility.

disown is emergency rescue. Process already running, SSH about to drop.
Remove it from the shell job table and it survives terminal death.
Like nohup — no reattach, but the process lives.

Job control tested hands-on — fg, bg, jobs, Ctrl+z, disown.
Ctrl+z sends SIGTSTP and freezes the process. bg sends SIGCONT
to resume it in the background. The difference between SIGSTOP
and SIGTSTP — SIGTSTP can be caught, SIGSTOP cannot.

---

## Process masquerading attack

Planted /bin/sleep disguised as sshd in /tmp/.hidden/ and ran it.
The attack worked immediately — /tmp has no noexec by default.
Any unprivileged user can drop and execute a binary there.

Three things gave it away during investigation:
Wrong path — real sshd lives in /usr/sbin not /tmp.
Wrong user — real sshd runs as root, this ran as training.
Wrong parent — real sshd is spawned by systemd, this came from bash.

The detect script flags processes running from /tmp and catches
sshd running as a non-root user. The hardening script locks /tmp
with noexec, nosuid and nodev. Once remounted, the attack fails
at launch — the binary simply cannot execute from /tmp.
