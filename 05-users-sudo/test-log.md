## 05-A baseline (Ubuntu, 2026-10-28)
- id, groups and /proc/self/status agree: uid 1000, gid 1000, groups 4 24 27 30 46 100 114 1000.
- getent passwd and grep /etc/passwd match for a local account. Not tested: an SSSD/LDAP account.
- /etc/shadow is -rw-r----- root shadow; cat gave Permission denied.

## 05-B group added after process start (Ubuntu, 2026-10-28)
- Running loop: Groups 1001, log "denied", before and after usermod -aG labdb labreader.
- id labreader showed 1001,1002(labdb). Fresh sudo -u read worked.
- Fix restarted the loop: Groups 1001 1002, log "ok". Script removed labreader, labdb and the lab folder.
- No snapshot taken (virsh was run on the VM, not the host).
