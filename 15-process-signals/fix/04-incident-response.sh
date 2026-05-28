#!/bin/bash
# Incident response for suspicious process detection
# Observe, identify, check persistence, then contain
# Never kill first — evidence and persistence check first

if [ -z "$1" ]; then
    echo "Usage: $0 <PID>"
    echo "Example: $0 1234"
    exit 1
fi

PID=$1

echo "=== Step 1: Process identity ==="
ps -fp $PID

echo ""
echo "=== Step 2: Process ancestry ==="
pstree -p | grep $PID

echo ""
echo "=== Step 3: Binary location ==="
ls -l /proc/$PID/exe 2>/dev/null

echo ""
echo "=== Step 4: Open files and connections ==="
lsof -p $PID 2>/dev/null

echo ""
echo "=== Step 5: Network connections ==="
ss -pant | grep $PID

echo ""
echo "=== Step 6: Environment variables ==="
cat /proc/$PID/environ 2>/dev/null | tr '\0' '\n'

echo ""
echo "=== Step 7: Persistence check ==="
echo "--- Crontab ---"
crontab -l 2>/dev/null || echo "No crontab"

echo "--- /etc/cron.d ---"
ls /etc/cron.d/

echo "--- .bashrc tail ---"
tail -10 ~/.bashrc

echo "--- SSH authorized keys ---"
cat ~/.ssh/authorized_keys 2>/dev/null || echo "No authorized_keys"

echo "--- Suspicious systemd services ---"
systemctl list-units --type=service --state=running | grep -v systemd

echo ""
echo "=== Evidence collected ==="
echo "If satisfied — contain with: kill -9 $PID"
echo "Verify with: ps aux | grep $PID"
