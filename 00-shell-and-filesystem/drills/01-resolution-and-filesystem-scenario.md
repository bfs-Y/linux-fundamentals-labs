# 00 - Shell and Filesystem: Drill

**1. I log into a box and `ls` fails. What's the first command I run to
see `$PATH`, and why that one?**

`echo "$PATH"`. It's a builtin, so it still works when `$PATH` is
broken. I first reached for `type -a ls`, which was the wrong tool. It
only showed the alias and never showed whether `$PATH` was the problem.

**2. `ls` says "No such file or directory" instead of "not found". What's
the difference?**

"Not found" means bash looked through every directory in `$PATH` and
found nothing. "No such file or directory" means bash tried a specific
path and it wasn't there. With `PATH=""`, the empty entry means "look in
the current directory", so bash looked there once and found no `ls`.

**3. I ran `rm` on a file and it finished with no error. Is the data
gone?**

Not if another hard link points at the same inode. `rm` removes one name
and lowers the link count. The data is freed when the count reaches zero
and nothing has the file open. `ls -li` shows the inode number and the
link count.

**4. A symlink's target gets deleted. What happens to the symlink?**

The symlink stays. It has its own inode and only stores the target's path
as text. Reading it fails with "No such file or directory". The size
`ls -li` shows for a symlink is just the length of that path, 15 for
`/tmp/target.txt`.

**5. A cleanup script missed a file with a space in its name. Why?**

`xargs` splits on spaces, so `/tmp/my file.log` became `/tmp/my` and
`file.log`. Neither exists, so `rm` printed two errors and left the real
file alone. `find -print0 | xargs -0 rm` fixes it by splitting on a null
byte, which can't appear in a filename.
