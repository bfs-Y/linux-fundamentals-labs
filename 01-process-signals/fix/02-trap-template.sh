#!/bin/bash
# Production signal handler template
# Demonstrates safe cleanup on SIGTERM, SIGINT, and unexpected exit

TEMP_FILE="/tmp/backup_temp.db"

cleanup() {
    trap - SIGTERM SIGINT EXIT
    echo "Caught signal — cleaning up..."
    rm -f "$TEMP_FILE"
    exit 1
}

trap cleanup SIGTERM SIGINT EXIT

echo "Starting backup..."
touch "$TEMP_FILE"
echo "Working..."
sleep 60

echo "Done."
rm -f "$TEMP_FILE"
trap - SIGTERM SIGINT EXIT
exit 0
