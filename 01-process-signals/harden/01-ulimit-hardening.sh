#!/bin/bash
# Hardens process and file descriptor limits system-wide
# Prevents fork bombs and EMFILE exhaustion
# Requires root. Changes take effect on next login.

set -euo pipefail

LIMITS_FILE="/etc/security/limits.conf"
PAM_SESSION="/etc/pam.d/common-session"

echo "=== Setting system-wide ulimits ==="

# Prevent fork bombs — cap user processes
grep -q "nproc" "$LIMITS_FILE" || cat >> "$LIMITS_FILE" << 'LIMITS'
* soft nproc 1024
* hard nproc 2048
LIMITS

# Prevent EMFILE exhaustion — raise open file limit
grep -q "nofile" "$LIMITS_FILE" || cat >> "$LIMITS_FILE" << 'LIMITS'
* soft nofile 65536
* hard nofile 65536
LIMITS

echo "=== Enabling PAM limits ==="
grep -q "pam_limits" "$PAM_SESSION" || echo "session required pam_limits.so" >> "$PAM_SESSION"

echo ""
echo "=== Current limits ==="
ulimit -a

echo ""
echo "Done. Log out and back in to apply."
echo "Verify with: ulimit -u && ulimit -n"
