## Numbering has drifted twice — cross-reference before trusting old entries (2026-09-XX)

Everything below this point uses an OLD numbering scheme
(13-permission-directories, 14-users-sudo, 15-process-signals,
16-networking, 02-bin-recovery, 04-sbin-admin) that no longer matches the
repo on disk. The repo was renumbered at least once after this backlog was
last touched (to 01-process-signals through 10-networking), then renumbered
again into dependency-correct learning order (00-shell-and-filesystem
through 14-shell-scripting-automation, current as of this entry). Current
mapping for anything referenced below:

- 13-permission-directories -> 03-permission-directories
- 14-users-sudo -> 04-users-sudo
- 15-process-signals -> 06-process-signals
- 16-networking -> 10-networking
- 02-bin-recovery -> 07-bin-recovery
- 04-sbin-admin -> 05-sbin-admin

Do not trust folder numbers in entries below without translating through
this mapping first. Future renumbers should add a new mapping block here
rather than editing history below.

## Correction: 05-sbin-admin (formerly 04-sbin-admin) is NOT inconsistent

README.md's structure table (as of commit 31e040a) flagged
`05-sbin-admin` as "**Inconsistent** — drills/README/test-log exist with no
break/fix behind them. Needs resolving." This is wrong and needs fixing in
README — the drills-only shape is not an accident, it's the direct result
of the deliberate split documented below (2026-07-17): break/fix/harden
content for sbin-admin was intentionally moved to
`linux-security-labs/phase3-access-control/sbin-admin`, and the drills that
remained (sbin-inventory, user-management, filesystem-ops,
service-management) were kept here on purpose as neutral admin-tool
reference material. Fix README's status table to reflect this instead of
flagging it as unresolved.

## Open: no hostname-confirmation warning in LAB-SETUP.md

LAB-SETUP.md (added this session) doesn't warn about confirming `hostname`
before running break/fix scripts. This bit us once already — see "Resolved
— process note for future reference" below, where 13/14
(permission-directories/users-sudo, old numbering) were accidentally tested
on the HOST instead of the training VM. LAB-SETUP.md should get an explicit
"run `hostname` and confirm you're on the lab VM before any break step"
line so this doesn't repeat.

---

</parameter>
