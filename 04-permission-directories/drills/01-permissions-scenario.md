# 04 - Permissions: Drill

1. Why can `rm` delete a file you can't write to, and what stops it?

Deleting removes a name from a directory, so the directory's `w` and `x` bits decide it. With the directory at 555 and the file at 664, `rm` failed with "Permission denied". With the directory at 755 and the file at 000, `rm` only asked "remove write-protected regular file?". The file's mode only triggers that prompt.

2. A directory is at mode 111. What works and what doesn't?

`ls d` fails because listing names needs `r`. `cat d/f.txt` works because `x` lets you reach a name you already know. At 444, `ls d` printed the name but couldn't read details of `d/f.txt`, and `cat` was denied. Same result on Ubuntu and Rocky. If I `chmod 444 .` from inside the directory, I can't `chmod` it back through `.`, so I fix it from the parent.

3. Who can change a file's owner, and who can change its group?

Only root can change the owner: my plain `chown` gave "Operation not permitted". The group can be changed by root, or by the owner to a group they belong to. As owner, `chgrp adm` worked because I'm in `adm`, and `chgrp labreader` failed because I'm not.

4. After `sudo chown labreader own.txt` the same append worked on Ubuntu and failed on Rocky. Why?

The kernel picks one class only: owner, else group, else other. Ubuntu's umask is 0002, so the file was 664 and my group had `rw-`. Rocky's is 0022, so the file was 644 and the group had `r--`. I confirmed both umask values and the resulting modes.

5. `umask 077`: what modes do a new file and a new directory get?

File 600 and directory 700. Files start from 666 and directories from 777, and umask clears bits. That is why files never get `x` from umask. I only changed it in one shell, and I did not prove that a systemd service uses its own value.

6. `chmod 600` on a file shared through an ACL stops a service account reading it, and `ls -l` looks normal. Why?

On a file with an ACL, the group bits in `chmod` set the mask, which caps named-user and group entries. `chmod 600` made the mask `---`, so `labreader`'s `r--` showed `#effective:---`. The tell is the `+` in `ls -l`. `getfacl` shows it, and `setfacl -m m::r--` fixed it on both distros.

7. `mv` a file to another filesystem: what changes, and what does `cp -p` keep?

`mv` on one filesystem kept the inode. Across filesystems `strace` showed `renameat2` fail with EXDEV, then a copy and an unlink, so the inode changed. `cp` makes a new inode and a new mtime. `cp -p` makes a new inode but keeps the mtime.

8. On Rocky, does `mv` into `/dev/shm` keep the SELinux label?

In one test `mv` kept `user_home_t`, while a new file and a plain `cp` got `user_tmp_t`. I did not trace why `mv` kept it, and I did not test a service reading the moved file.
