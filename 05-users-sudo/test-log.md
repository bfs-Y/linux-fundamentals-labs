## 05-A baseline (Ubuntu, 2026-10-28)
- id, groups and /proc/self/status agree: uid 1000, gid 1000, groups 4 24 27 30 46 100 114 1000.
- getent passwd and grep /etc/passwd match for a local account. Not tested: an SSSD/LDAP account.
- /etc/shadow is -rw-r----- root shadow; cat gave Permission denied.

## 05-B group added after process start (Ubuntu, 2026-10-28)
- Running loop: Groups 1001, log "denied", before and after usermod -aG labdb labreader.
- id labreader showed 1001,1002(labdb). Fresh sudo -u read worked.
- Fix restarted the loop: Groups 1001 1002, log "ok". Script removed labreader, labdb and the lab folder.
- No snapshot taken (virsh was run on the VM, not the host).

## 05-C usermod -G without -a (Ubuntu, 2026-10-28)
- drilluser in audio,video; file video.conf root:video 640 readable. After usermod -G sudo: groups 1001,27(sudo) only, file Permission denied, and sudo granted by mistake.
- Fix: gpasswd -d drilluser sudo; usermod -aG audio,video. File readable again. Script removed drilluser and /tmp/usermodlab.
- Rewrote break/fix 01: the old fix re-added sudo, which the original state never had. Run on Ubuntu only (sudo group name; Rocky uses wheel).

## 05-B group added after process start (Rocky, 2026-10-28)
- Same as Ubuntu: running loop Groups 1001, log "denied", before and after usermod -aG labdb labreader. id showed 1002(labdb). Fresh sudo -u read worked.
- Fix restarted the loop: Groups 1001 1002, log "ok". Script removed labreader, labdb and the lab folder, no userdel complaint.
- ls -l shows the SELinux dot on db.conf. Context not recorded.
