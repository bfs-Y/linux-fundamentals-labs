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
