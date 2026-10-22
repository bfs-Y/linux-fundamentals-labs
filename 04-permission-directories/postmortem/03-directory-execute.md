# Postmortem: a folder lost its execute bit

Date: 2026-10-21. Ubuntu 24.04.

A folder went from 755 to 744. The file inside stayed 644, so nothing looked wrong. For `labreader` (class "other"), `ls` still listed `file.txt` because `r` reads names, but `ls -l` showed `-?????????` and `cat` was denied, because reaching a name needs `x`. The owner kept `x`, so it only broke for other users.

The break script's output showed it: `ls -l` run as the affected account and seeing the question marks. The fix was `chmod 755` on the directory.

For whoever takes over: when a file's mode looks right and access still fails, check every directory on the path. `namei -l` shows each one.
