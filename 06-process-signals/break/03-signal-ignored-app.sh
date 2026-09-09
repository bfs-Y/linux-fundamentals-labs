#!/bin/bash
# Simulates a daemon that ignores SIGTERM — forces SIGKILL
# Demonstrates why poorly written daemons cause dirty shutdowns

python3 -c "
import signal, time, os

signal.signal(signal.SIGTERM, signal.SIG_IGN)
signal.signal(signal.SIGHUP, signal.SIG_IGN)

print('PID:', os.getpid())
print('Ignoring SIGTERM and SIGHUP — send SIGKILL to stop')

while True:
    time.sleep(1)
" 
