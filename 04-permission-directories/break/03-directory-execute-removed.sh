#!/bin/bash
# 04-permission-directories/break/03-directory-execute-removed.sh
#
# A folder loses its execute bit. The file inside is still readable by
# everyone and ls still lists its name, but nobody else can open it.
# Needs sudo. Leaves the broken folder in /tmp/dirlab until
# fix/03-restore-directory-execute.sh runs.

set -u

DIR=/tmp/dirlab

if ! id labreader >/dev/null 2>&1; then
    sudo useradd -m -s /bin/bash labreader
    CREATED=yes
fi

mkdir -p "$DIR/d"
chmod 755 "$DIR"
[ "${CREATED:-}" = yes ] && touch "$DIR/.created-labreader"

echo "hi" > "$DIR/d/file.txt"
chmod 644 "$DIR/d/file.txt"
chmod 755 "$DIR/d"

echo "Before:"
ls -ld "$DIR/d"
echo "labreader reads: $(sudo -u labreader cat "$DIR/d/file.txt" 2>&1)"

echo
echo "Change: chmod 744 on the folder. It looks harmless, the file is still 644."
chmod 744 "$DIR/d"
ls -ld "$DIR/d"
echo "labreader lists the folder:"
sudo -u labreader ls "$DIR/d" 2>&1
echo "labreader runs ls -l:"
sudo -u labreader ls -l "$DIR/d" 2>&1

if sudo -u labreader cat "$DIR/d/file.txt" >/dev/null 2>&1; then
    echo "RESULT: labreader can still open the file"
else
    echo "RESULT: labreader sees the file name but cannot open it"
fi
