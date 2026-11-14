# Drill: df

Command: `df -P /`

**What happens when I press Enter.** The shell finds /usr/bin/df on my PATH and runs it with execve. strace showed one execve and no clone or fork, so df is a single process and starts no children.

**Files it reads.** It loads libc and the locale files. Most of the ENOENT lines are just df looking for translated message files, so they are not errors. The one that matters is /proc/self/mountinfo, which is how df learns what is mounted and which device sits under /.

**Files it writes.** None.

**Kernel interface.** The used and free numbers come from one syscall, statfs("/"). df never reads a file inside /. The kernel keeps the counters in the filesystem itself: f_blocks, f_bfree, f_bavail, and the inode counters f_files and f_ffree. That is why df and df -i agree about what they describe.

**Daemon contacted.** None.

**Why this exact output.** On my Ubuntu VM, f_blocks was 10242616, f_bfree was 6445649 and f_bavail was 5917304, with 4096-byte blocks. Used plus Available came to about 2 GiB less than the total. The gap is f_bfree minus f_bavail, which is 528345 blocks. tune2fs showed 524249 reserved blocks for root (5% of the filesystem), and /sys/fs/ext4/vda2/reserved_clusters showed 4096. Those two add up to 528345 exactly. This is why an app can hit "no space left" while df still shows free space: the free blocks are reserved for root.

**Also noticed.** tune2fs reported a block count of 10484992, but statfs reported f_blocks of 10242616. The difference is probably filesystem metadata (not checked yet), so a df total never matches the raw device size.

**How it could mislead me.** df shows what the filesystem says is used, not what the files add up to. If a deleted file is still held open by a process, df counts it and du doesn't. df -i is a separate check for inode exhaustion.
