## Objective

Use strace and lsof together to diagnose a slow or suspicious
process without touching the application code.

## Scenario

A Python web app is slow. No errors in logs. CPU and memory normal.
You suspect it is stuck waiting on something.

## Drill 1 — Attach strace to a live process

Start a test server:
python3 -m http.server 8080 &

Attach strace:
sudo strace -p PID

Watch for 10 seconds. What system call repeats?
What is the process waiting for?

## Drill 2 — Filter strace to specific calls

Watch only network and wait calls:
sudo strace -p PID -e trace=network
sudo strace -p PID -e trace=poll,select,read,write

Send a request while watching:
curl http://localhost:8080/

What new system calls appear when a request arrives?
What is the lifecycle of one HTTP connection in system calls?

## Drill 3 — Cross-reference with lsof

Get file descriptors:
ls -la /proc/PID/fd
lsof -p PID

Find fd=3 in strace output. What is fd=3 in lsof?
Find any unexpected libraries in mem entries.
LD_PRELOAD attacks show up here as unexpected .so files.

## Drill 4 — Find a stuck process

If a process is slow — attach strace and look for:
read(FD, ...) hanging with no return
poll() or select() waiting forever
write() blocked on a slow connection

Cross reference the FD number with lsof to identify
which file, socket, or database connection is the bottleneck.

## Key questions

- What is the difference between strace and lsof?
- What does poll() = 0 (Timeout) tell you?
- What does accept4() tell you?
- How do you spot an LD_PRELOAD attack using lsof?
- Why does strace require sudo on most systems?
