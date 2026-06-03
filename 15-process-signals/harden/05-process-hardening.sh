#!/bin/bash
# Hardens against process-based privilege escalation
# Checks for PATH hijacking risks and hidden processes

set -euo pipefail

echo "=== Step 1: Audit cron jobs for relative paths ==="
echo "--- Root crontab ---"
sudo crontab -l 2>/dev/null || echo "No root crontab"

echo ""
echo "--- /etc/crontab ---"
grep -v "^#" /etc/crontab | grep -v "^$"

echo ""
echo "--- /etc/cron.d/ ---"
for f in /etc/cron.d/*; do
    echo "File: $f"
    grep -v "^#" "$f" | grep -v "^$" | head -5
done

echo ""
echo "=== Step 2: Find scripts without absolute paths ==="
echo "Checking common script locations for relative command calls..."
grep -r "^[a-z]" /etc/cron.d/ 2>/dev/null | grep -v "/" || echo "None found"

echo ""
echo "=== Step 3: Check for hidden processes ==="
echo "Comparing /proc with ps output..."
ls /proc | grep -E '^[0-9]+$' | sort -n > /tmp/proc_pids.txt
ps aux --no-headers | awk '{print $2}' | sort -n > /tmp/ps_pids.txt
HIDDEN=$(comm -23 /tmp/proc_pids.txt /tmp/ps_pids.txt)
if [ -z "$HIDDEN" ]; then
    echo "CLEAN: No hidden processes detected"
else
    echo "WARNING: PIDs in /proc but not in ps:"
    echo "$HIDDEN"
fi
rm -f /tmp/proc_pids.txt /tmp/ps_pids.txt

echo ""
echo "=== Step 4: Run unhide scan ==="
sudo unhide proc 2>/dev/null || echo "unhide not installed — run: apt-get install unhide"

echo ""
echo "=== Step 5: Check for processes in foreign namespaces ==="
HOST_NS=$(readlink /proc/self/ns/pid | tr -d 'pid:[]')
FOREIGN=$(ps -eo pid,pidns,cmd | awk -v ns="$HOST_NS" '$2 != ns && $2 != "-" && $2 != "PIDNS"')
if [ -z "$FOREIGN" ]; then
    echo "CLEAN: No processes in foreign namespaces"
else
    echo "WARNING: Processes in foreign namespaces:"
    echo "$FOREIGN"
fi
