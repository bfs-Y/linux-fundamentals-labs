#!/bin/bash
# Fix: restore correct group memberships using -aG (append, not replace)
set -euo pipefail

TEST_USER="drilluser"
echo "[FIX] Current (broken) groups:"
id "${TEST_USER}"

echo "[FIX] Restoring audio,video,sudo correctly with -aG..."
sudo usermod -aG audio,video,sudo "${TEST_USER}"

echo "[VERIFY] Groups should now include audio, video, AND sudo:"
id "${TEST_USER}"
