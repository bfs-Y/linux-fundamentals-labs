# linux-fundamentals-labs

Hands-on Linux systems fundamentals — process/signal handling, permissions, users, storage, systemd, shell scripting, networking basics. This is a **build → break → fix** repo.

Hardening is intentionally out of scope here. Deliberate hardening, adversarial attack simulation, and full defense cycles belong in [`linux-security-labs`](https://github.com/bfs-Y/linux-security-labs). This repo teaches the underlying mechanism — what the system does, why it broke, how you prove the fix with evidence — without the adversarial layer on top.

(Two early topics — `01-process-signals` and `05-bin-recovery` — already contain `harden/` work done before this scope was formalized. That's legacy, left in place rather than deleted; new topics don't get a `harden/` folder.)

Deep networking (routing, DNS internals, firewalling, packet-level analysis) lives in [`linux-networking-labs`](https://github.com/bfs-Y/linux-networking-labs), not here. `10-networking` in this repo currently holds shallow break/fix content — see Known Gaps for the migration decision still owed.

## Related repos

- [`linux-security-labs`](https://github.com/bfs-Y/linux-security-labs) — adversarial security track: privilege escalation, MAC, auditing, incident response, full attack/defend/harden cycles.
- [`linux-networking-labs`](https://github.com/bfs-Y/linux-networking-labs) — deep networking track: layer 1/2 through layer 5, tcpdump/Wireshark, DNS internals, nmap/recon, multi-fault incidents.

## Methodology

1. **Build** it correctly, manually, first.
2. **Break** it — a realistic misconfiguration or failure.
3. **Fix** it using evidence (logs, `strace`, kernel/proc state), not guesswork.
4. **Test/Log** the fix to confirm it actually holds.
5. **Postmortem** — what happened, actual root cause, evidence, what you'd tell a teammate.

No harden step. That discipline lives in `linux-security-labs`.

## `/lab-notes`

Session-level notes and postmortems that don't belong to a single topic.

## Structure

| Topic | Status |
|---|---|
| `01-process-signals` | Build/break/fix/test-log/notes/README present. Postmortem folder added, needs content. Has legacy `harden/` (pre-scope). |
| `02-permission-directories` | Break/drills/fix present. No test-log, no README. Postmortem folder added, needs content. |
| `03-users-sudo` | Break/drills/fix present. No test-log, no README. Postmortem folder added, needs content. |
| `04-sbin-admin` | **Inconsistent** — drills/README/test-log exist with no break/fix behind them. Needs resolving before a postmortem folder makes sense. |
| `05-bin-recovery` | Build/break/fix/test-log/README present. Postmortem folder added, needs content. Has legacy `harden/` (pre-scope). |
| `06-services-systemd` | Empty — not started. |
| `07-storage-mounts-fstab` | Empty — not started. |
| `08-logs-auditing` | Empty — not started. |
| `09-shell-scripting-automation` | Empty — not started. |
| `10-networking` | Break/drills/fix/README present. Postmortem folder added. **Migration to `linux-networking-labs` owed — see Known Gaps.** |

## Known gaps as of last review

- `02-permission-directories` and `03-users-sudo` have no test-log — the fix was never proven to hold.
- `04-sbin-admin` needs its scope resolved: either write the missing break/fix work, or re-scope the existing drills/test-log to match what's actually here.
- `06` through `09` are bare skeletons.
- `10-networking` now has a confirmed target repo (`linux-networking-labs`). Decide: migrate this content there and remove `10-networking` from this repo, or keep a permanently shallow fundamentals-level version here and reserve depth for the dedicated repo. Undecided as of this writing.
- Every postmortem folder added in the last pass is empty — folders exist, no postmortems written yet.
