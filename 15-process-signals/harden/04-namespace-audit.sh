#!/bin/bash
# Audits processes running in foreign PID namespaces
# Detects containers, hidden processes, and namespace abuse
# Run from the host — never from inside a container

echo "=== Host PID namespace ==="
HOST_NS=$(readlink /proc/self/ns/pid | tr -d 'pid:[]')
echo "Host namespace ID: $HOST_NS"

echo ""
echo "=== Processes in foreign namespaces ==="
FOREIGN=$(ps -eo pid,pidns,cmd | awk -v ns="$HOST_NS" '$2 != ns && $2 != "-" && $2 != "PIDNS"')

if [ -z "$FOREIGN" ]; then
    echo "CLEAN: No processes found in foreign namespaces"
else
    echo "WARNING: Processes found in foreign namespaces:"
    echo "$FOREIGN"
    echo ""
    echo "Investigate each PID:"
    echo "  ps -fp PID"
    echo "  ls -l /proc/PID/exe"
    echo "  cat /proc/PID/status | grep -E 'Name|State|PPid|NSpid'"
fi

echo ""
echo "=== All unique namespaces in use ==="
ps -eo pidns | grep -v PIDNS | grep -v "^[[:space:]]*-$" | sort -u

echo ""
echo "=== Docker containers running ==="
docker ps 2>/dev/null || echo "Docker not available or no containers running"

echo ""
echo "=== NSpid check for suspicious processes ==="
echo "NSpid with two values = process inside a namespace"
for pid in $(ps -eo pid --no-headers); do
    nspid=$(grep NSpid /proc/$pid/status 2>/dev/null)
    if echo "$nspid" | grep -q $'\t.*\t'; then
        name=$(cat /proc/$pid/comm 2>/dev/null)
        echo "PID=$pid NAME=$name $nspid"
    fi
done
