# Test Log — 15 Process Signals

## 01-zombie-factory.sh
- Status: tested
- Zombies visible in ps output with Z state
- Parent PIDs confirmed with ps --ppid

## 01-zombie-cleanup.sh
- Status: tested
- Correctly identifies zombie parents
- strace confirmation step requires sudo

## 02-trap-template.sh
- Status: tested
- SIGTERM triggers cleanup, temp file removed
- Normal completion exits 0, no cleanup message
- Double-trap bug fixed with trap - reset inside cleanup

## 01-ulimit-hardening.sh
- Status: tested
- limits.conf updated correctly
- PAM configured
- Requires logout/login to activate
- Verified with ulimit -u and ulimit -n
