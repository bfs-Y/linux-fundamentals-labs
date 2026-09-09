## Objective

Understand and apply resource limits to prevent fork bombs,
PID exhaustion, and file descriptor exhaustion.

## Drill 1 — Inspect current limits

ulimit -a

Identify the three limits that matter most in production:
- max user processes (-u)
- open files (-n)
- core file size (-c)

Check PID ceiling:
cat /proc/sys/kernel/pid_max

## Drill 2 — Controlled fork bomb

Set a safe process limit first:
ulimit -u 50

Confirm:
ulimit -u

Run the fork bomb:
:(){ :|:& };:

Observe: bash reports "fork: Resource temporarily unavailable"
System survives because ulimit stopped it at 50 processes.

Without ulimit — this exhausts all PIDs and locks the system.

## Drill 3 — File descriptor exhaustion

Check current open file limit:
ulimit -n

Check how many FDs a running process has open:
ls /proc/PID/fd | wc -l

A web server under load needs thousands of FDs — one per connection.
Default limit of 1024 causes EMFILE errors under traffic.

## Drill 4 — Apply permanent limits

Edit /etc/security/limits.conf:
* soft nofile 65536
* hard nofile 65536
* soft nproc  1024
* hard nproc  2048

Enable PAM to read limits:
grep pam_limits /etc/pam.d/common-session
# if missing:
echo "session required pam_limits.so" | sudo tee -a /etc/pam.d/common-session

Verify after logout/login:
ulimit -n
ulimit -u

## Key questions to answer

 What is the difference between soft and hard limits?
 Why does ulimit -u 50 protect the system from a fork bomb?
 What error do you see when open file limit is exhausted?
 Why do ulimit changes require logout/login to take effect?
 What is the difference between ulimit and cgroups?
