## Numbering has drifted a third time — logs-auditing moved up (2026-09-13)

Everything below this point (including the "drifted twice" mapping block)
used a numbering scheme where logs-auditing was `13-logs-auditing`, near
the end. That's been corrected — log literacy (`journalctl`, `dmesg`,
persistent vs volatile journal storage) was needed by several earlier
modules (01-boot-process, 07-process-signals, 09-services-systemd in the
new numbering) long before the student would formally reach it at position
13. Same category of mistake as package-management originally being too
late in the very first roadmap draft.

Mapping from the "drifted twice" numbering to current:

- 02-package-management -> 03-package-management
- 03-permission-directories -> 04-permission-directories
- 04-users-sudo -> 05-users-sudo
- 05-sbin-admin -> 06-sbin-admin
- 06-process-signals -> 07-process-signals
- 07-bin-recovery -> 08-bin-recovery
- 08-services-systemd -> 09-services-systemd
- 09-storage-mounts-fstab -> 10-storage-mounts-fstab
- 10-networking -> 11-networking
- 11-ssh -> 12-ssh
- 12-firewall -> 13-firewall
- 13-logs-auditing -> 02-logs-auditing (moved up, not just shifted)

00-shell-and-filesystem, 01-boot-process, and 14-shell-scripting-automation
are unchanged across all three numbering schemes.

Do not trust folder numbers in entries below (including the "drifted
twice" block) without translating through this mapping first. As before:
future renumbers should add a new mapping block here rather than editing
history below.

## Process note: git mv and empty .gitkeep files don't mix safely

While executing this reorder, several `git mv` operations targeting
empty skeleton folders (identifiable only by their `.gitkeep` markers)
got tangled in git's rename-detection heuristics — since empty files are
byte-identical, git guessed at "closest match" renames across completely
unrelated folders rather than tracking the actual intended moves. The
symptom: `git status` showed `.gitkeep` files renaming between modules
that were never actually related. Caught before committing by cross-
checking `find <module> -type f` file counts against the pre-reorder tree,
module by module — the real content files (README.md, test-log.md, actual
break/fix scripts) all renamed correctly throughout; only the empty
`.gitkeep` bookkeeping got scrambled, and since `.gitkeep` files carry no
real content, this was cosmetic, not a data-loss risk. Lesson: after any
bulk `git mv` touching skeleton/empty folders, verify with `find`-based
file counts before trusting `git status`'s rename labels, and don't
hesitate to `git reset` and re-stage cleanly if the rename list looks
suspicious.

---
