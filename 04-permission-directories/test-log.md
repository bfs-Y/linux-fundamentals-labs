## 04-A file operations baseline (2026-10-21)
- mv same fs: inode 656918 before and after (rename only)
- cp: new inode (656921), new mtime; cp -p: new inode (656922), mtime kept
- mv across fs: dev 64770 -> dev 29, inode 656921 -> 2
- strace: renameat2 -> EXDEV, then open/create/unlinkat (copy + delete)
- rm dir: "Is a directory"; rm -d / rmdir: "Directory not empty" when non-empty
- dir 555 + file 664: rm denied. dir 755 + file 000: rm only prompts.
