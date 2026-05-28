#!/bin/bash
# Simulates a process masquerading as a legitimate system binary
# Planted in /tmp to demonstrate noexec bypass and name deception
# Safe — uses /bin/sleep, no actual malware

echo "=== Planting fake sshd in /tmp ==="
mkdir -p /tmp/.hidden
cp /bin/sleep /tmp/.hidden/sshd

echo "=== Launching masqueraded process ==="
/tmp/.hidden/sshd 300 &
echo "Fake sshd PID: $!"

echo ""
echo "=== Now investigate ==="
echo "ps aux | grep sshd"
echo "ls -l /proc/PID/exe"
echo "pstree -p | grep sshd"
echo "lsof -p PID"
echo "stat /tmp/.hidden/sshd"
echo ""
echo "Run: ./fix/03-detect-masquerade.sh to investigate"
