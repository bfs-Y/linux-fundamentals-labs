#!/bin/bash
# 05-users-sudo/fix/03-sudoers-correct-path.sh
#
# Fix for break/03. Find the real path with command -v, rewrite the rule,
# validate it with visudo -cf BEFORE installing, then test and clean up.

set -u
RULE=/etc/sudoers.d/labreader

sudo test -f "$RULE" || { echo "$RULE not found. Run break/03 first."; exit 1; }
id labreader >/dev/null 2>&1 || { echo "labreader doesn't exist."; exit 1; }

REAL=$(command -v systemctl)
echo "Real path: $REAL"
TMP=$(mktemp)
echo "labreader ALL=(root) NOPASSWD: $REAL status ssh" > "$TMP"
if ! sudo visudo -cf "$TMP"; then
    echo "new rule failed validation, not installing"; rm -f "$TMP"; exit 1
fi
sudo install -m 0440 -o root -g root "$TMP" "$RULE"
rm -f "$TMP"

if sudo -u labreader sudo -n -l "$REAL" status ssh >/dev/null 2>&1; then
    RESULT="labreader can run the one command"
else
    RESULT="labreader is still refused"
fi
if sudo -u labreader sudo -n -l "$REAL" restart ssh >/dev/null 2>&1; then
    RESULT="$RESULT, but can also restart ssh (too broad)"
else
    RESULT="$RESULT and cannot restart ssh"
fi

sudo rm -f "$RULE"
sudo loginctl terminate-user labreader 2>/dev/null || true
for i in 1 2 3 4 5 6 7 8 9 10; do pgrep -u labreader >/dev/null || break; sleep 1; done
if sudo userdel -r labreader 2>/dev/null && ! id labreader >/dev/null 2>&1; then
    echo "RESULT: $RESULT, removed rule and labreader"
else
    echo "RESULT: $RESULT, userdel did not finish, labreader kept"
fi
