#!/bin/bash
# Creates 10 zombie processes deliberately for inspection

echo "Spawning zombie processes..."

for i in $(seq 1 10); do
    python3 -c "
import os
pid = os.fork()
if pid > 0:
    import time
    time.sleep(300)
else:
    os._exit(0)
" &
    echo "Spawned zombie parent PID: $!"
done

echo ""
echo "Zombie processes created. Inspect with:"
echo "  ps -eo pid,ppid,state,cmd | awk '\$3 ~ /Z/'"
echo ""
echo "Press Ctrl+C to clean up"
wait
