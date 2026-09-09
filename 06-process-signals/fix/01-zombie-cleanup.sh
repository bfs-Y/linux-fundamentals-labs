#!/bin/bash
# Diagnose and fix zombie process accumulation

echo "=== Step 1: Find zombie processes ==="
ps -eo pid,ppid,state,cmd | awk '$3 ~ /Z/'

echo ""
echo "=== Step 2: Identify zombie parents ==="
ps -eo pid,ppid,state,cmd | awk '$3 ~ /Z/ {print $2}' | sort | uniq -c | sort -rn

echo ""
echo "=== Step 3: Check what each parent is ==="
ps -eo pid,ppid,state,cmd | awk '$3 ~ /Z/ {print $2}' | sort -u | while read ppid; do
    echo "Parent PID $ppid:"
    cat /proc/$ppid/status 2>/dev/null | grep -E 'Name|State'
    echo ""
done

echo "=== Step 4: Check if parent is reaping ==="
echo "Run manually: sudo strace -p PARENT_PID -e trace=wait4"
echo "Silence = broken. No wait4 calls = root cause confirmed."

echo ""
echo "=== Fix Options ==="
echo "1. Docker: docker run --init ..."
echo "2. Dockerfile: ENTRYPOINT [\"/usr/bin/tini\", \"--\", \"your-app\"]"
echo "3. Kill parent to force reparenting to init (last resort)"
