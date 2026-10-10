# Postmortem - find | xargs rm missed a file with a space in its name

**What caused it:** `xargs` splits its input on spaces. The file
`/tmp/my file.log` came through as two arguments, `/tmp/my` and
`file.log`. Neither exists, so `rm` printed two errors and the real file
was left alone.

**How I found it:** I checked with `ls /tmp/my*.log` after the cleanup
ran, and the file was still there. The script had kept going and looked
like it had worked.

**How it was fixed:** `find /tmp -name '*.log' -print0 | xargs -0 rm`.
This separates names with a null byte, which can't appear in a filename.
The file was gone afterwards.

**What I'd do differently:** use `-print0` and `-0` whenever filenames
go through a pipe. I also ran `find` over all of `/tmp`, which printed
permission errors from folders I don't own. Next time I'd limit it to a
test folder with `-maxdepth` so the output stays about the bug.
