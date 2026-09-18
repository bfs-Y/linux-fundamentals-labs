#!/bin/bash
# 00-shell-and-filesystem/fix/01-fix-xargs-whitespace.sh
#
# FIX for break/01-xargs-whitespace-bug.sh
# Root cause: xargs splits on whitespace by default, so a filename
# containing a space gets torn into multiple bogus arguments.
# Fix: use find -print0 / xargs -0, which delimit with a null byte —
# the one byte that can never legally appear inside a filename.

echo "[fix] Recreating the test file..."
touch "/tmp/my file.log"

echo "[fix] Removing it safely with null-delimited find | xargs..."
find /tmp -name '*.log' -print0 | xargs -0 rm

echo "[fix] Verifying removal..."
ls /tmp/my*.log 2>&1
