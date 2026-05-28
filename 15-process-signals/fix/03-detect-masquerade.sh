#!/bin/bash
# Detects processes masquerading as legitimate system binaries
# Looks for suspicious process characteristics

echo "=== Step 1: Find processes running from /tmp ==="
ps aux | awk '$11 ~ /^\/tmp/'

echo ""
echo "=== Step 2: Find processes with suspicious names ==="
for pid in $(ps -eo pid --no-headers); do
    exe=$(readlink /proc/$pid/exe 2>/dev/null)
    name=$(cat /proc/$pid/comm 2>/dev/null)
    if echo "$exe" | grep -q "^/tmp"; then
        echo "SUSPICIOUS: PID=$pid NAME=$name EXE=$exe"
    fi
done

echo ""
echo "=== Step 3: Check /tmp for executables ==="
find /tmp -type f -executable 2>/dev/null

echo ""
echo "=== Step 4: Check processes running as wrong user ==="
echo "sshd should run as root — any sshd running as other user is suspicious"
ps aux | grep sshd | grep -v root | grep -v grep

echo ""
echo "=== Step 5: Verify legitimate sshd ==="
ls -l /proc/$(pgrep -x sshd | head -1)/exe 2>/dev/null
