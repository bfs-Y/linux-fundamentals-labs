#!/bin/bash
# 00-shell-and-filesystem/break/02-path-corruption.sh
#
# BREAK: corrupt $PATH so external binaries become unreachable.
#
# IMPORTANT: this script must be SOURCED, not executed, or the corruption
# will only affect a throwaway child process and your shell will be
# untouched. Run it as:
#   source break/02-path-corruption.sh
# NOT:
#   bash break/02-path-corruption.sh

echo "[break] Current PATH before corruption:"
echo "$PATH"

echo "[break] Setting PATH to empty string..."
export PATH=""

echo "[break] PATH is now corrupted. Try running 'ls' — it should fail."
echo "[break] Diagnose and recover manually. Do not just re-export a known-good PATH"
echo "[break] without first confirming WHY 'ls' fails the way it does."
