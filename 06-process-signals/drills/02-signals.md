## Objective

Build instinct for signal behavior on live processes.
Know when to use each signal and what the consequences are.

## Drill 1 — Observe default signal behavior

Run a process and send different signals. Observe the difference.

terminal 1:
sleep 100

terminal 2:
kill -15 PID    # SIGTERM — observe output in terminal 1
kill -2 PID     # SIGINT  — same as Ctrl+C
kill -9 PID     # SIGKILL — last resort

Note: what prints in terminal 1 for each signal?

## Drill 2 — Build a process that catches SIGTERM

python3 -c "
import signal, time, os

def handle(signum, frame):
    print('Caught signal', signum, '— cleaning up')
    exit(0)

signal.signal(signal.SIGTERM, handle)
print('PID:', os.getpid())
while True:
    time.sleep(1)
"

Send SIGTERM. Observe custom handler running.
Then try SIGKILL. Observe — handler never runs.

## Drill 3 — Build a process that ignores SIGTERM

python3 -c "
import signal, time, os
signal.signal(signal.SIGTERM, signal.SIG_IGN)
print('PID:', os.getpid())
while True:
    time.sleep(1)
"

Send SIGTERM — nothing happens.
Send SIGKILL — process dies. No cleanup.
This is what a badly written daemon looks like.

## Drill 4 — SIGHUP daemon reload

sudo kill -1 $(cat /run/nginx.pid)
ps aux | grep nginx | grep worker

Master PID unchanged. Workers replaced with new PIDs.
Config reloaded. Zero connections dropped.

## Key questions to answer

- What is the correct order when killing a process?
- Why is SIGKILL dangerous on a process doing IO?
- What signal can never be caught or ignored?
- Why do daemons use SIGHUP for config reload?
- What happens to active connections when you SIGKILL nginx?
