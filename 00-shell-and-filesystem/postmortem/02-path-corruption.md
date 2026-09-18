# Postmortem — $PATH corruption

**Root cause:** `$PATH` was set to an empty string. An empty component in
`$PATH` is interpreted by bash as "search the current directory," not
"search nowhere" — so `ls` failed with `No such file or directory` (ENOENT,
a genuine failed lookup at `./ls`) rather than `not found` (no candidate
located anywhere), because bash did in fact search, just only one
directory.

**Detection method:** Two hypotheses were tested and eliminated with
evidence before the correct one was found: (1) a stale command hash was
ruled out via `hash` showing an empty table; (2) creating a dummy `./ls` in
the cwd and observing the error change from `No such file or directory` to
`Permission denied` confirmed bash was searching cwd, not refusing to
search at all.

**Time to resolution:** Required two rounds of hypothesis-and-test before
landing on the correct mechanism; not solved on the first guess.

**One thing to do differently:** When PATH is fully broken, `chmod` and
other external tools are unreachable too — recovery requires either
restoring PATH directly via `export` (a builtin, no PATH needed) or having
a known-good PATH value already captured somewhere accessible without
external tools.
