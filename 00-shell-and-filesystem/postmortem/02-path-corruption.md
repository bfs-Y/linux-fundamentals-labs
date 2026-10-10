# Postmortem - empty $PATH

**What caused it:** I set `PATH=""`. External programs like `ls` and
`chmod` stopped working, but builtins like `echo` still did. `ls` failed
with "No such file or directory", not "not found". An empty entry in
`$PATH` means "look in the current directory", so bash did look, once,
and found nothing.

**How I found it:** I had two wrong guesses first. Stale command cache:
ruled out because `hash` was empty. `type -a ls` only showed the alias, so
it didn't help. What worked was putting a file called `ls` in the current
directory. The error changed to "Permission denied", which showed that
bash was looking there and had found a file that wasn't executable.
`echo "$PATH"` showed the empty value directly.

**How it was fixed:** `export PATH` back to the normal value. That's a
builtin, so it worked without `$PATH`. I couldn't use `chmod` to fix the
dummy file, because `chmod` is a program too.

**What I'd do differently:** when commands vanish, run `echo "$PATH"`
first. Absolute paths like `/usr/bin/cat` still work with an empty
`$PATH`. Keep a copy of the normal value somewhere I can read without any
external program.
