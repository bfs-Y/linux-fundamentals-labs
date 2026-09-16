# 15 — Process Signals

## Problem Statement

Linux processes rely on parent-child contracts enforced by the kernel. When those contracts break — a parent that never calls wait(), a container without a real PID 1, a daemon that ignores SIGTERM — the failure is silent and accumulative. Zombie processes drain PIDs until fork() fails system-wide. Processes that ignore SIGTERM force SIGKILL, skipping cleanup and leaving corrupt state on disk.

## What This Module Covers

 Zombie process creation, accumulation, and diagnosis
 Signal handling in shell scripts — trap, cleanup, exit codes
 ulimit hardening against fork bombs and file descriptor exhaustion
 Docker PID 1 reaping problem — detection and fix

## Threat Model

**In scope:**
 Accidental zombie accumulation from poorly written daemons
 Fork bomb denial of service by unprivileged users
 Data corruption from SIGKILL on processes doing IO
 Container instability from missing init process

**Out of scope:**
 Kernel-level signal exploits requiring CAP_SYS_PTRACE
 cgroups-based resource limiting (see future work)

## Setup

```bash
# Run break scenario
./break/01-zombie-factory.sh

# In second terminal — inspect zombies
ps -eo pid,ppid,state,cmd | awk '$3 ~ /Z/'

# Run cleanup diagnosis
./fix/01-zombie-cleanup.sh

# Apply ulimit hardening (requires root)
sudo ./harden/01-ulimit-hardening.sh
```
