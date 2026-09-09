## Objective

Build instinct for reading process state on a live system.
All commands run on a real machine — no simulations.

## Drill 1 — Read process states

ps aux | awk '{print $8}' | sort | uniq -c | sort -rn

Identify how many processes are in each state.
Know what R, S, D, Z mean without looking them up.

## Drill 2 — Inspect a process via /proc

Pick any running PID from ps aux output. Then:

cat /proc/PID/status | grep -E 'Name|State|PPid|Threads'
ls -la /proc/PID/fd

What is the process? Who is its parent? How many file descriptors does it have open?

## Drill 3 — Create and observe a zombie

python3 -c "
import os, time
pid = os.fork()
if pid > 0:
    print('Parent PID:', os.getpid())
    time.sleep(600)
else:
    os._exit(0)
" &

ps --ppid PARENT_PID
cat /proc/ZOMBIE_PID/status | grep -E 'Name|State|PPid'

Confirm: FDSize is 0. State is Z. Parent is sleeping, not calling wait().

## Drill 4 — Watch parent reaping with strace

sudo strace -p SHELL_PID -e trace=wait4

In another terminal run any command. Watch wait4 complete with child PID.
Compare to a broken parent — silence where wait4 calls should be.

## Key questions to answer

- Why can't you kill a zombie with kill -9?
- What happens to the system when PIDs exhaust?
- What is the difference between S and D state?
- How do you find which parent is leaking zombies?
