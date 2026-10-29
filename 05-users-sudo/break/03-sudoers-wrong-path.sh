#!/bin/bash
# 05-users-sudo/break/03-sudoers-wrong-path.sh
# Run ONE break/fix pair at a time.
#
# labreader is given one command through sudo, but the rule names a path
# that does not exist. The rule passes visudo -c, so nothing warns about
# it. labreader can authenticate, then sudo refuses.
# Needs sudo. Leaves /etc/sudoers.d/labreader until fix/03 runs.

set -u
RULE=/etc/sudoers.d/labreader
BAD=/opt/nonexistent/systemctl

sudo test -e "$RULE" && { echo "$RULE exists. Run the fix script first."; exit 1; }
id labreader >/dev/null 2>&1 && { echo "labreader already exists. Not touching it."; exit 1; }

sudo useradd -m -s /bin/bash labreader
TMP=$(mktemp)
echo "labreader ALL=(root) NOPASSWD: $BAD status ssh" > "$TMP"
sudo visudo -cf "$TMP" || { echo "rule has a syntax error"; rm -f "$TMP"; exit 1; }
sudo install -m 0440 -o root -g root "$TMP" "$RULE"
rm -f "$TMP"

echo "Rule installed: $(sudo cat "$RULE")"
echo "visudo -c says: $(sudo visudo -c 2>&1 | tail -2 | tr '\n' ' ')"
echo "sudo -l -U labreader:"
sudo -l -U labreader 2>&1 | tail -4
echo "Running as labreader:"
sudo -u labreader sudo -n /usr/bin/systemctl status ssh 2>&1 | head -2

if sudo -u labreader sudo -n /usr/bin/systemctl status ssh >/dev/null 2>&1; then
    echo "RESULT: labreader can run the command"
else
    echo "RESULT: the rule is valid, but names the wrong path, so sudo refuses"
fi
