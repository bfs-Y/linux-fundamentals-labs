## 04-A file operations baseline (2026-10-21)
- mv same fs: inode 656918 before and after (rename only)
- cp: new inode (656921), new mtime; cp -p: new inode (656922), mtime kept
- mv across fs: dev 64770 -> dev 29, inode 656921 -> 2
- strace: renameat2 -> EXDEV, then open/create/unlinkat (copy + delete)
- rm dir: "Is a directory"; rm -d / rmdir: "Directory not empty" when non-empty
- dir 555 + file 664: rm denied. dir 755 + file 000: rm only prompts.

### 04-A raw evidence (Wed Oct 21 03:22:16 AM CDT 2026)
$ stat -c "dev=%d inode=%i" on same-fs mv
658352 r1.txt
658352 r2.txt
$ cp vs cp -p
inode=658352 mtime=2026-10-21 03:22:16.936981278 -0500 r2.txt
inode=658353 mtime=2026-10-21 03:22:16.943055398 -0500 r3.txt
inode=658354 mtime=2026-10-21 03:22:16.936981278 -0500 r4.txt
$ strace mv across filesystems
renameat2(AT_FDCWD, "r2.txt", 3, "r2.txt", RENAME_NOREPLACE) = -1 EXDEV (Invalid cross-device link)
unlinkat(3, "r2.txt", 0)                = -1 ENOENT (No such file or directory)
unlinkat(AT_FDCWD, "r2.txt", 0)         = 0
+++ exited with 0 +++

### 04-A Rocky 10 (2026-10-21)
- Same results as Ubuntu: mv same-fs keeps inode (68470084); cp new inode; cp -p keeps mtime; cross-fs mv gets EXDEV then copy + unlink.
- dir 555 + file 664: rm "Permission denied".
- SELinux: ls -ldZ ~/lab04 -> unconfined_u:object_r:user_home_t:s0.
- mv d.txt /dev/shm kept user_home_t. New file and plain cp in /dev/shm got user_tmp_t. So mv kept the source context, cp used the destination default (one run; mechanism not traced).

### 04-B directory r vs x (Ubuntu, 2026-10-21)
- d=444 and d=644: ls shows name f.txt but cannot stat it; cat d/f.txt Permission denied.
- d=111: ls d denied; cat d/f.txt prints hello. x = reach by known name, r = list names.
- Trap: chmod 444 . from inside d locked me out; chmod 755 . then failed. Fix was cd to parent and chmod 755 d.

### 04-C chown/chgrp (Ubuntu, 2026-10-21)
- Plain chown labreader own.txt: Operation not permitted. sudo chown worked: owner labreader, group ubuntulab.
- echo more >> own.txt worked (group rw). Size 5 -> 10.
- Plain chgrp labreader: Operation not permitted. sudo chgrp worked: labreader labreader.
- echo again >> own.txt: Permission denied (now "other", r--).
- Kernel uses one class only: owner, else group, else other.

### 04-C group rule (Ubuntu, 2026-10-21)
- Owner chgrp adm g.txt: worked (owner is in adm). chgrp labreader g.txt: Operation not permitted (owner not in labreader).
- Owner change: root only. Group change: root, or owner to a group they belong to.

### 04-C Rocky chown/chgrp (2026-10-21)
- Plain chown: Operation not permitted. sudo chown: labreader bfs, context unchanged (user_home_t).
- echo more >> own.txt: Permission denied (file is 644, group bfs has r--). Ubuntu allowed it (664).
- After sudo chgrp: labreader labreader, append denied (other r--).
- Difference is default mode (Rocky 644, Ubuntu 664), probably umask; not yet checked.

### 04-D umask (Ubuntu, 2026-10-21)
- umask 0002: new file 664.
- umask 077: file 600, dir 700. umask 022: file 644, dir 755.
- Files start from 666, directories from 777; umask clears bits. Rocky default not yet checked.
- Rocky umask 0022: new file 644 (-rw-r--r--.). Ubuntu 0002 gives 664.
- This explains the chown lab difference: Rocky group had r-- only, Ubuntu group had rw-.
- Rocky umask 0022: new file 644 (-rw-r--r--.). Ubuntu 0002 gives 664.
- This explains the chown lab difference: Rocky group had r-- only, Ubuntu group had rw-.
- Ubuntu terminal showed 0022 after my own umask 022 experiment in the same shell; a new terminal should show 0002.

### 04-E ACL mask (Ubuntu, 2026-10-21)
- Before chmod 600: -rw-r-----+, labreader reads the file.
- After chmod 600: -rw-------+, getfacl: user:labreader:r-- #effective:---, group::r-- #effective:---, mask::---. labreader blocked.
- chmod on an ACL file sets the mask, which caps named-user and group entries.
- Fix: setfacl -m m::r-- -> mask::r--, labreader reads again, ls -l shows -rw-r-----+.
- fix/02 script left labreader (created by hand, no .created-labreader marker) and removed /tmp/aclcase.
- Tell: "+" in ls -l. Run getfacl before concluding.

### 04-E ACL mask (Rocky, 2026-10-21)
- Same as Ubuntu: after chmod 600, getfacl shows labreader r-- #effective:---, mask::---. labreader blocked.
- ls -lZ before fix: unconfined_u:object_r:user_tmp_t:s0. Not re-checked after fix.
- Fix script set mask::r--, labreader read again, ls -l -rw-r-----+. Left labreader in place (no marker), removed /tmp/aclcase.
- Not tested on Rocky: the userdel path for a script-created labreader.

### 04-B directory r vs x (Rocky, 2026-10-21)
- d=444: ls d shows f.txt but cannot access d/f.txt; cat d/f.txt Permission denied.
- d=111: ls d denied; cat d/f.txt prints hello.
- Same as Ubuntu. Always chmod the directory from its parent, never "chmod ." from inside.

### 04-G umask hides new files (Ubuntu, 2026-10-22)
- Break: file created under umask 077 -> -rw------- group labreader. labreader: Permission denied.
- Fix: chmod 640 repaired the file; a new file under umask 027 was -rw-r-----, readable by labreader.
- chmod fixes one file, umask fixes what the process creates next.
- Script created and removed labreader (marker present). userdel warnings were harmless.

### 04-H wrong config ownership (Ubuntu, 2026-10-22)
- Break: /etc/drilltest.conf root:root 600 -> labreader Permission denied.
- Fix: root:labreader 640 -> labreader can read, cannot write.
- Script created and removed labreader (marker present). userdel warnings harmless.

### 04-F directory execute removed (Ubuntu, 2026-10-21)
- dir 755: labreader reads file. After chmod 744: ls lists file.txt, ls -l shows -????????? and Permission denied, cat denied.
- Owner keeps x, so it breaks only for other users.
- Fix: chmod 755 restored access. Script removed /tmp/dirlab, left labreader.

### 04-I why chmod . fails inside a 444 directory (Ubuntu, 2026-10-22)
- Entered d at 755, ran chmod 444 . (succeeded), then stat . -> "cannot statx '.': Permission denied".
- ls -ld ~/lab04/d from the full path worked (resolved via parent x).
- cd d at 444 from outside: Permission denied.
- x on a directory is needed to resolve any name in it, "." included. Fix by chmod from the parent path.

### 04-A cp mode vs mtime (Ubuntu, 2026-10-22)
- p1.txt 600. Plain cp p2.txt: mode 600, new mtime. cp -p p3.txt: mode 600, mtime identical to source.
- Plain cp copied the source mode (umask 0002 masks nothing here). -p visibly added only the mtime.
- Ownership not tested (same user). Umask vs source-mode distinction not yet shown.
