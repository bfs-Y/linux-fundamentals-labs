#!/bin/bash
# Break: a config file gets the wrong owner, service can't read its own
# config. No attacker — a common deployment/copy mistake.
set -euo pipefail

CONFIG_PATH="/etc/drilltest.conf"
echo "[SETUP] Creating a test config file..."
echo "setting=value" | sudo tee "${CONFIG_PATH}" > /dev/null
sudo chown root:root "${CONFIG_PATH}"
sudo chmod 600 "${CONFIG_PATH}"

echo "[BREAK] Config is owned by root, mode 600 — unreadable by a service"
echo "running as a non-root user (common after a bad deploy script)."
ls -la "${CONFIG_PATH}"

echo "[VERIFY] Try reading as a non-root user:"
echo "  sudo -u nobody cat ${CONFIG_PATH}"
echo "Expected: Permission denied"
