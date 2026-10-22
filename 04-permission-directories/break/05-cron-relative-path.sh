#!/bin/bash
# 04-permission-directories/break/05-cron-relative-path.sh
#
# A cron job reads its config by a relative path. By hand, from the
# config's folder, it works. Under cron the job starts in the account's
# home folder, the file isn't there, and the error text isn't anywhere I'd
# normally look. ls -l on the config looks fine the whole time.
# Needs sudo. Leaves the job running every minute until
# fix/05-cron-absolute-path.sh runs.

set -u

DIR=/tmp/cronlab

command -v crontab >/dev/null || { echo "crontab not found."; exit 1; }
if sudo crontab -u labreader -l 2>/dev/null | grep -q .; then
    echo "labreader already has a crontab. Not touching it."
    exit 1
fi

if ! id labreader >/dev/null 2>&1; then
    sudo useradd -m -s /bin/bash labreader
    CREATED=yes
fi

mkdir -p "$DIR"
chmod 755 "$DIR"
[ "${CREATED:-}" = yes ] && touch "$DIR/.created-labreader"

echo "setting=value" > "$DIR/app.conf"
chmod 644 "$DIR/app.conf"
ls -l "$DIR/app.conf"

echo "By hand, from the config's folder:"
( cd "$DIR" && sudo -u labreader cat app.conf 2>&1 )

echo '* * * * * cat app.conf' | sudo crontab -u labreader -
echo "Installed a cron job for labreader: cat app.conf. Waiting 70 seconds..."
sleep 70

if sudo test -f /var/log/cron; then
    LOG=$(sudo grep 'cat app.conf' /var/log/cron | tail -3)
else
    LOG=$(sudo journalctl -u cron -u crond --since "3 min ago" --no-pager | grep -E 'cat app.conf|MTA' | tail -3)
fi
echo "What the cron log shows:"
echo "$LOG"

if [ -z "$LOG" ]; then
    echo "RESULT: no cron log lines found, so I can't tell if the job ran"
elif echo "$LOG" | grep -qi 'no such file'; then
    echo "RESULT: the log shows the error text"
else
    echo "RESULT: the job ran and the cron log has no error text"
fi
