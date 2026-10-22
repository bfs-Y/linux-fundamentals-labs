#!/bin/bash
# 04-permission-directories/break/01-wrong-config-ownership.sh
# Run ONE break/fix pair at a time. The fix deletes labreader if this script created it.
# Run ONE break/fix pair at a time. The fix deletes labreader if this script created it.
#
# A config file under /etc is owned by root with mode 600, so the service
# account that has to read it is refused. No attacker, just a common
# copy or deploy mistake. ls -l shows a normal locked-down file.
# Needs sudo. Leaves the broken file in place until
# fix/01-correct-config-ownership.sh runs.

set -u

CONF=/etc/drilltest.conf
DIR=/tmp/drilltest

if ! id labreader >/dev/null 2>&1; then
    sudo useradd -m -s /bin/bash labreader
    CREATED=yes
fi
mkdir -p "$DIR"
[ "${CREATED:-}" = yes ] && touch "$DIR/.created-labreader"

echo "setting=value" | sudo tee "$CONF" > /dev/null
sudo chown root:root "$CONF"
sudo chmod 600 "$CONF"
ls -l "$CONF"
echo "labreader reads: $(sudo -u labreader cat "$CONF" 2>&1)"

if sudo -u labreader cat "$CONF" >/dev/null 2>&1; then
    echo "RESULT: labreader can read the config"
else
    echo "RESULT: labreader is blocked, the file is root:root 600"
fi
