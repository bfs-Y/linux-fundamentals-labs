#!/bin/bash
# Break: usermod -G (no -a) silently REPLACES all existing group
# memberships instead of adding to them. No attacker — a common,
# accidental operational mistake.
set -euo pipefail

TEST_USER="drilluser"

if id "${TEST_USER}" &>/dev/null; then
  echo "[SETUP] ${TEST_USER} already exists, reusing."
else
  echo "[SETUP] Creating test user with existing group memberships..."
  sudo useradd -m "${TEST_USER}"
fi

sudo usermod -aG audio,video "${TEST_USER}"

echo "[BEFORE] Groups for ${TEST_USER}:"
id "${TEST_USER}"

echo "[BREAK] Running usermod -G sudo (WITHOUT -a)..."
sudo usermod -G sudo "${TEST_USER}"

echo "[AFTER] Groups for ${TEST_USER} — audio/video are now GONE:"
id "${TEST_USER}"
