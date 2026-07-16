# linux-break-fix-harden — Backlog

## Repo-wide security/fundamentals split needed (found 2026-07-16)
This repo mixes genuine Linux fundamentals with offensive-security/red-team
content that should live in linux-security-labs instead — same pattern
already fixed for 16-networking (firewall, hardening-audit) and for
03-privilege-escalation, 13-permissions-security, 14-users-sudo (already
migrated tonight).

Verified via actual file content, not just folder names — apply the test:
"is there an attacker in this scenario, or is this a neutral mechanism/
misconfiguration?" before moving anything.

### CONFIRMED SECURITY — move to linux-security-labs
- 01-usr-execution — PATH hijack, "malicious ls", "exfiltrating data",
  explicit attacker framing
- 04-sbin-admin — world-writable useradd binary, privilege-escalation
  vector via a system binary
- 05-lib-hijacking — LD_PRELOAD persistence (real rootkit technique),
  shared library replacement/checksum evasion
- 06-tmp-attacks — PATH hijack via /tmp targeting root cron job
- 07-var-attacks — log tampering: surgical deletion of attacker SSH
  activity from auth.log (candidate for phase6-logging-monitoring,
  NOT phase7 — this is about log/monitoring integrity specifically)
- 08-boot-security — planted root backdoor in /etc/passwd + /etc/shadow
- 09-root-hardening — GRUB boot-parameter injection (init=/bin/bash
  bypass), real physical-access attack technique
- 10-dev-attacks — /dev/null replaced with a capture file to exfiltrate
  data meant to be discarded
- 11-etc-hardening — NOT YET CHECKED, folder name suggests likely security,
  verify content before assuming
- 12-home-security — planted reverse shell in .bashrc, planted attacker
  SSH key in authorized_keys

### CONFIRMED FUNDAMENTALS — stay here, no action needed
- 02-bin-recovery — /usr mount failure simulation, no attacker, genuine
  resilience/troubleshooting scenario
- 15-process-signals — zombie process creation for inspection, matches
  known legitimate Module 15 fundamentals work

### Execution plan for next session
1. Check 11-etc-hardening content (not yet verified)
2. For each CONFIRMED SECURITY folder: create matching phase folder in
   linux-security-labs (07-var-attacks -> phase6-logging-monitoring;
   the rest likely phase7-secops unless individual review suggests
   otherwise, same reasoning process used for privilege-escalation/
   users-sudo/permissions-security tonight)
3. mv (not git mv, cross-repo) each folder's contents into place
4. Commit removal in linux-break-fix-harden, commit addition in
   linux-security-labs, verify no data lost via find before each commit
5. After migration, re-verify linux-break-fix-harden's remaining folder
   list is genuinely fundamentals-only (repeat the same audit once more,
   don't assume this list is exhaustive)

## Lesson from tonight's users-sudo/permissions-security migration
Bulk-moving entire folders based on the break/ script's content was wrong —
each folder had 1 genuinely neutral drill file mixed in with 6 legitimately
security-framed ones (users-sudo: 04-useradd-usermod.md was neutral;
permissions-security: 06-stat-namei.md was neutral). BOTH were caught and
restored to fundamentals after the fact.
When executing the remaining 10-folder migration: check EVERY file
individually (break/fix/harden/drills), not just the break/ script, before
deciding a whole folder moves. Some drills may be neutral command-reference
content even inside a folder whose break/ scripts are clearly attacks.

## Thin folders after security migration (not urgent, revisit later)
13-permissions-security and 14-users-sudo now only contain the restored
neutral drills (06-stat-namei.md, 04-useradd-usermod.md respectively) — no
break/fix/harden scripts of their own, since all prior break/fix content in
those folders was genuinely security-framed and correctly stayed migrated.
Consider whether these two topics deserve real neutral break/fix content of
their own (e.g., a genuine permission-misconfiguration-no-attacker scenario,
a genuine useradd/usermod mistake-and-fix scenario) or whether a single
reference drill is sufficient for this repo's scope.

## No postmortem content anywhere in this repo
Confirmed: linux-break-fix-harden has zero postmortem/ entries across any
topic folder. Revisit — decide whether to backfill at least one real
postmortem here, matching the standard already established in
linux-networking-labs (ARP capture) and linux-security-labs.
