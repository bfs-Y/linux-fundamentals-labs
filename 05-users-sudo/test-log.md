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

## 05-D su vs sudo (Ubuntu, 2026-10-28)
- sudo -u root env and sudo -i env: both HOME=/root USER=root LOGNAME=root.
- sudo -u root pwd keeps the caller's directory; sudo -i pwd -> /root (login shell).
- su root: Authentication failure (root password locked). sudo -i worked: authentication vs authorization.
- su labreader: HOME=/home/labreader, PWD unchanged. su - labreader: PWD=/home/labreader. PATH identical in all.
- Not checked: Rocky; whether a profile changes PATH.

## 05-D su vs sudo (Rocky, 2026-10-28)
- su root worked (password prompt, exit 0): root has a password on Rocky, locked on Ubuntu.
- sudo -u root / sudo -i: HOME=/root; pwd kept for -u root, /root for -i. Same as Ubuntu.
- su labreader: HOME=/home/labreader, PWD unchanged, PATH kept the caller's (/home/bfs/.local/bin...). su -: PWD=/home/labreader, PATH=labreader's own.
- userdel refused right after su (process 31023); a few seconds later no process remained and userdel worked. loginctl terminate-user reported the user was not logged in, so it did nothing.

## 05-E sudoers wrong path (Ubuntu, 2026-10-28)
- Rule /opt/nonexistent/systemctl status ssh: visudo -c "parsed OK". sudo -l -U lists it. Running the real command: "sudo: a password is required".
- Replaced by hand with /usr/bin/systemctl status ssh: status ran as root, restart refused.
- Adding --no-pager changed the argument list and sudo refused it: sudoers matches arguments exactly.
- First fix script misreported "still refused" because it used the exit code (systemctl status exits 3 when inactive). Changed to sudo -n -l.
- Not run on Rocky.
- Rerun with the sudo -n -l fix script (Ubuntu): ended "labreader can run the one command and cannot restart ssh, removed rule and labreader". /etc/sudoers.d held only README afterwards.

## 05-E sudoers wrong path (Rocky, 2026-10-29)
- Break matched Ubuntu: visudo -c accepted /opt/nonexistent/systemctl, sudo -l listed it, real command: "sudo: a password is required".
- First fix run failed: /etc/sudoers.d is root-only on Rocky, so [ -f ] as a normal user could not see the rule. Cleaned up by hand with sudo.
- Scripts changed to sudo test -f / -e. Rerun result: fix found the rule via sudo test, ended "labreader can run the one command and cannot restart ssh, removed rule and labreader"; id labreader: no such user.
- Rocky differences: no README in /etc/sudoers.d; defaults include always_set_home and !visiblepw; secure_path has no /usr/local or /snap/bin. Unit is sshd, so "status ssh" names no real unit (the sudo -l match test is unaffected).
