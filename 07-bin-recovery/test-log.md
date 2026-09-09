## Consolidation Testing - Feb 24, 2026

Ran all 5 /bin drills from memory. Timed myself. No looking at notes.

### Drill 01: Tool Inventory

Checked what's actually in Alpine's /bin vs /usr/bin.

82 commands in /bin. 143 in /usr/bin. vim and curl missing like expected. vi and find are there but in /usr/bin not /bin.

Passed.

### Drill 02: Manual Mount

Broke /usr on purpose with mv. Tools disappeared. vi stopped working.

Mounted it back with `mount /usr.backup /usr`. Everything came back. 143 tools restored.

Passed.

### Drill 03: Log Analysis

Fake boot log with errors. Had to find problems using only grep.

Found 3 FAILED entries and 2 ERROR entries. Used `grep -c` to count because wc wasn't in /bin.

/dev/sda2 had filesystem errors.

Passed.

### Drill 04: Process Management

Started a fake service with sleep. Had to kill it by PID without systemctl.

Messed up first time - tried `kill 3600` (the sleep duration, not the PID). 

Corrected to `kill 8`. Process died. Saw the Terminated message.

Passed.

### Drill 05: Text Editing

Had to change port=80 to port=8080 in a config file. No vim or nano.

Used sed: `sed -i 's/port=80/port=8080/' /tmp/config.txt`

Checked with cat. It worked.

Passed.

---

All 5 drills done. Got better at not executing compromised binaries. Still need practice with sed syntax.
