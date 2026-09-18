#!/bin/bash
# 00-shell-and-filesystem/fix/02-restore-path.sh
#
# FIX for break/02-path-corruption.sh
# Root cause: PATH was set to an empty string. An empty PATH component
# is interpreted as "search the current directory," not "search nowhere" —
# which is why builtins kept working but external binaries failed with
# ENOENT-style errors instead of a clean "not found."
#
# NOTE: like the break script, this must be SOURCED, not executed with
# bash, or the restored PATH will only apply to a throwaway child process
# and your actual shell will remain broken.
#   source fix/02-restore-path.sh
# NOT:
#   bash fix/02-restore-path.sh

KNOWN_GOOD_PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/snap/bin"

echo "[fix] Current (broken) PATH:"
/usr/bin/echo "$PATH"

echo "[fix] Restoring known-good PATH..."
export PATH="$KNOWN_GOOD_PATH"

echo "[fix] PATH restored. Verifying with ls..."
ls /tmp > /dev/null 2>&1 && echo "[fix] ls succeeded — PATH restored correctly."
