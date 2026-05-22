#!/bin/bash
# Detects broken Docker PID 1 — app running as init without reaping
# Run inside a container to check if PID 1 is a real init system

PID1_NAME=$(cat /proc/1/status | grep "^Name:" | awk '{print $2}')

echo "=== PID 1 Check ==="
echo "Process: $PID1_NAME"
echo ""

case "$PID1_NAME" in
    systemd|tini|dumb-init|init)
        echo "PASS: PID 1 is a real init system"
        echo "Zombie reaping: handled"
        echo "Signal forwarding: handled"
        ;;
    python*|node|java|ruby|gunicorn|flask|uvicorn)
        echo "FAIL: PID 1 is an application process"
        echo "Zombie reaping: NOT handled"
        echo "Signal forwarding: NOT handled"
        echo ""
        echo "Fix: docker run --init ..."
        echo "  or add tini to your Dockerfile"
        echo "  ENTRYPOINT [\"/usr/bin/tini\", \"--\", \"your-app\"]"
        ;;
    sh|bash|dash)
        echo "WARN: PID 1 is a shell"
        echo "Zombie reaping: partial"
        echo "Signal forwarding: unreliable"
        echo ""
        echo "Fix: use tini or --init flag"
        ;;
    *)
        echo "UNKNOWN: $PID1_NAME"
        echo "Verify manually: cat /proc/1/status"
        ;;
esac

echo ""
echo "=== Current zombie count ==="
ps -eo state | grep -c Z || echo "0 zombies"
