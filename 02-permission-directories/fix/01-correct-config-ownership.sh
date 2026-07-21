#!/bin/bash
# Fix: correct ownership/permissions so the intended service user can read it
set -euo pipefail

CONFIG_PATH="/etc/drilltest.conf"
SERVICE_USER="nobody"
SERVICE_GROUP="nogroup"

echo "[FIX] Current (broken) ownership:"
ls -la "${CONFIG_PATH}"

echo "[FIX] Correcting ownership to ${SERVICE_USER}:${SERVICE_GROUP}, readable-only mode..."
sudo chown "${SERVICE_USER}:${SERVICE_GROUP}" "${CONFIG_PATH}"
sudo chmod 640 "${CONFIG_PATH}"

echo "[VERIFY] New ownership/permissions:"
ls -la "${CONFIG_PATH}"
echo "[VERIFY] Read test:"
sudo -u "${SERVICE_USER}" cat "${CONFIG_PATH}"
