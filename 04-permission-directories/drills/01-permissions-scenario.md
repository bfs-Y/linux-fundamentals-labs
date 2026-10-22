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

File 600 and directory 700. Files created by `touch` or `echo >` start from 666 and directories from 777, and umask clears bits. `cp` starts from the source file's mode instead, then applies the umask, unless `-p` is used. That is why files never get `x` from umask. I only changed it in one shell, and I did not prove that a systemd service uses its own value.

6. `chmod 600` on a file shared through an ACL stops a service account reading it, and `ls -l` looks normal. Why?

On a file with an ACL, the group bits in `chmod` set the mask, which caps named-user and group entries. `chmod 600` made the mask `---`, so `labreader`'s `r--` showed `#effective:---`. The tell is the `+` in `ls -l`. `getfacl` shows it, and `setfacl -m m::r--` fixed it on both distros.

7. `mv` a file to another filesystem: what changes, and what does `cp -p` keep?

`mv` on one filesystem kept the inode. Across filesystems `strace` showed `renameat2` fail with EXDEV, then a copy and an unlink, so the inode changed. `cp` makes a new inode and a new mtime. `cp -p` makes a new inode but keeps the mtime.

8. On Rocky, does `mv` into `/dev/shm` keep the SELinux label?

In one test `mv` kept `user_home_t`, while a new file and a plain `cp` got `user_tmp_t`. I did not trace why `mv` kept it, and I did not test a service reading the moved file.

9. A service account is refused its config in `/etc`, and `ls -l` shows a normal `-rw-------`. What is the smallest fix?

The file was `root:root 600`, so `labreader` got "Permission denied". I changed it to `root:labreader 640`: the service can read it, cannot write it, and root stays the owner. I did not chown the file to the service or open it to everyone.

10. A directory was changed from 755 to 744. The file inside is still 644, but another user's `ls -l` shows `-?????????` and `cat` fails. Why?

That user falls in the "other" class, which now has `r` but no `x`. `r` lists the names, and `x` is needed to read details or open anything. The owner kept `x`, so it only broke for other accounts. `chmod 755` on the directory fixed it.

11. A script created a config under `umask 077` and set the right group, but the group can't read it. What do you change, and what do you change to stop it recurring?

The mode was 600, so the group got nothing even though `ls -l` showed the right group. `chmod 640` fixed the existing file. A file made under `umask 027` came out `640`, so the umask in the writing script fixes the next one. I did not test what umask a systemd service gets.
