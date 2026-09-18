# 00 — Shell and Filesystem: Drill (with answers)

Scenario-based, built from what actually happened during this module's
lab, not invented from a textbook.

---

**1. You SSH into a box, `ls` fails, and someone says "nothing changed."
Before touching anything else — what's the one command that shows you
PATH's real value, using nothing but a shell builtin?**

`echo "$PATH"`. It's a builtin, so it works no matter how broken the
environment is — no external binary required, no risk of it being the
thing that's actually broken. This came out of a real mistake: the first
instinct was `type -a ls`, which turned out to be the wrong tool here —
it only reports what the alias points at, and stops there. It never
confirms whether PATH itself, the thing actually needed to reach the real
binary, is intact.

---

**2. `ls` fails with `No such file or directory` instead of `not found`.
What does that specific wording actually tell you?**

`not found` means bash searched every directory in PATH and found nothing
anywhere. `No such file or directory` means bash *did* find a specific
path to try, attempted to open it, and that exact path doesn't exist. The
two imply different things about what bash actually did. This distinction
came out of a live debugging chain: PATH was set to empty, and `ls` threw
the second kind of error — meaning bash wasn't refusing to search, it was
searching *somewhere specific* and failing there. That somewhere turned
out to be the current directory, because an empty PATH component is
interpreted as "search here," not "search nothing."

---

**3. A teammate says a deleted file's data is gone for good because `rm`
ran with no error. When are they wrong, and what would you check?**

They're wrong if another hard link to the same inode still exists. `rm`
only removes one directory entry and decrements a link count — it doesn't
touch the underlying data unless that count reaches zero. The number to
check is the link count column in `ls -li` or `stat`, ideally *before* the
delete, since that's the only reliable way to know in advance whether a
name is the last pointer to that data or one of several.

---

**4. A symlink's target file gets deleted. `ls -li` on the symlink still
shows it. Why does the symlink survive, and what does `cat` do?**

A symlink isn't the same kind of object as its target — it has its own
separate inode, and that inode's entire content is just a text string: the
path it points to. Deleting the target never touches the symlink's own
inode, so the symlink itself keeps existing. But `cat` on it tries to
resolve that stored path and open whatever's there — and if the target's
gone, that resolution fails with `No such file or directory`, even though
the symlink object itself is completely intact. Proven directly: the
target was deleted, `ls -li` still listed the symlink with its original
inode, and `cat` failed cleanly right after.

---

**5. A cleanup script quietly failed to delete a file with a space in its
name. What broke, and what's the fix?**

`xargs` splits its input on whitespace by default. A filename like
`my file.log`, when piped in as plain text from `find`, gets torn into two
separate arguments at the space — neither of which is a real path — so
both delete attempts fail and the actual file is left untouched. It failed
*silently* in the sense that the script kept running and printed no
obvious crash, just two `rm: cannot remove` lines that looked like noise.
Fix: `find ... -print0 | xargs -0 rm` — a null byte delimiter instead of
whitespace, since a null byte can never legally appear inside a filename.
