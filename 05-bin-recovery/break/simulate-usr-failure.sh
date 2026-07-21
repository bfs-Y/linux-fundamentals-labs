#!/bin/bash
# Simulate /usr mount failure in Docker

echo "[*] Starting Alpine container with /usr failure simulation..."

docker run -it --rm --privileged alpine:3.19 /bin/sh -c '
echo "[*] Moving /usr to simulate mount failure"
mv /usr /usr.backup
mkdir /usr

echo "[*] Verifying failure state"
echo "--- Trying vim (should fail) ---"
vim 2>&1 | head -1

echo "--- Trying find (should fail) ---"
find 2>&1 | head -1

echo "--- Available tools in /bin ---"
ls /bin | wc -l

echo ""
echo "[*] Emergency shell ready. /usr unavailable."
echo "[*] Use: mount /usr.backup /usr to restore"
echo ""

/bin/sh
'
