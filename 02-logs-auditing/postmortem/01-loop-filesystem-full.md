# Postmortem - small log filesystem filled up

**What caused it:** I wrote a filler file until the 50 MB loop filesystem
was full. This was on purpose, to see what a full log disk looks like.

**How I found it:** `dd` stopped with "No space left on device" and `df`
showed 100% used with 0 available.

**How it was fixed:** deleting the filler file freed the space, and a
write to the filesystem worked again.

**What I'd do differently:** `df` at 100% does not mean logging stopped at
that moment. It shows the space available to normal users, and ext4 holds
back 5% for root. On Ubuntu a root write still worked at 100%. On Rocky
the same write failed even though `stat -f` showed free blocks. I think
ext4 needs some extra space for its own bookkeeping, but I never proved
it. When a disk looks full, check `stat -f`, not `tune2fs -l`, because
`tune2fs` can be out of date while the filesystem is mounted.
