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

### 04-C Rocky chown/chgrp (2026-10-21)
- Plain chown: Operation not permitted. sudo chown: labreader bfs, context unchanged (user_home_t).
- echo more >> own.txt: Permission denied (file is 644, group bfs has r--). Ubuntu allowed it (664).
- After sudo chgrp: labreader labreader, append denied (other r--).
- Difference is default mode (Rocky 644, Ubuntu 664), probably umask; not yet checked.
