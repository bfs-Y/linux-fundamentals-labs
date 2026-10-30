# Postmortem: usermod -G without -a replaced a user's groups

Date: 2026-10-28 (Ubuntu), rerun on Ubuntu and Rocky on 2026-10-30 after the script learned to pick `sudo` or `wheel`. On Rocky the admin group is `wheel`, and `usermod -G wheel` dropped `audio` and `video` the same way.

`drilluser` was in `audio` and `video`, and could read a file owned by group `video`. Someone ran `usermod -G sudo drilluser` to give the user sudo. Without `-a`, `-G` replaces the supplementary groups, so the groups became `drilluser` and `sudo` only. The file returned "Permission denied", and the user now had sudo it was never meant to have.

The script's output showed it: `id` before listed `29(audio),44(video)`, and after listed `27(sudo)` only.

The fix was `gpasswd -d drilluser sudo` and `usermod -aG audio,video drilluser`. The first version of my fix script re-added sudo as well, which the original state never had, so I rewrote it to restore only what was taken away.

For whoever takes over: use `-aG`, never `-G` alone. Run `id` before and after any group change, and when a user loses access, check whether the change also added a privilege.
