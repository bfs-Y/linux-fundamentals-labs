#!/bin/bash
# Simulates a reverse shell for investigation practice
# Safe — no actual network connection, output goes to /dev/null
# Use fix/04-incident-response.sh to investigate and contain

echo "=== Simulating reverse shell ==="
bash -i >& /dev/null 2>&1 &
echo "Reverse shell PID: $!"
echo ""
echo "Now investigate without killing it:"
echo "  ps aux | grep bash"
echo "  pstree -p"
echo "  lsof -p PID"
echo "  ss -pant | grep PID"
echo "  cat /proc/PID/environ | tr '\0' '\n'"
echo "  ls -l /proc/PID/exe"
echo ""
echo "Check persistence:"
echo "  crontab -l"
echo "  cat ~/.bashrc | tail -20"
echo "  ls /etc/cron.d/"
echo "  cat ~/.ssh/authorized_keys"
echo ""
echo "When done investigating run:"
echo "  kill -9 PID"
