# linux-fundamentals-labs

Hands-on Linux systems fundamentals — shell/filesystem basics, boot process,
logging, package management, permissions, users, process/signal handling,
systemd, storage, networking, SSH, firewalling, shell scripting automation.
This is a **build → break → fix** repo.

Hardening is intentionally out of scope here. Deliberate hardening,
adversarial attack simulation, and full defense cycles belong in
[`linux-security-labs`](https://github.com/bfs-Y/linux-security-labs). This
repo teaches the underlying mechanism — what the system does, why it broke,
how you prove the fix with evidence — without the adversarial layer on top.

(Two topics — `07-process-signals` and `08-bin-recovery` — already contain
`harden/` work done before this scope was formalized. That's legacy, left in
place rather than deleted; new topics don't get a `harden/` folder.)

Deep networking (routing, DNS internals, firewalling, packet-level analysis)
lives in [`linux-networking-labs`](https://github.com/bfs-Y/linux-networking-labs),
not here. `11-networking` and `13-firewall` in this repo currently hold
shallow break/fix content or are unstarted scaffolds — see Known Gaps for
the overlap/migration decision still owed with that repo.

See [`LAB-SETUP.md`](./LAB-SETUP.md) for VM and snapshot requirements before
starting any module.

## Related repos

- [`linux-security-labs`](https://github.com/bfs-Y/linux-security-labs) —
  adversarial security track: privilege escalation, MAC, auditing, incident
  response, full attack/defend/harden cycles.
- [`linux-networking-labs`](https://github.com/bfs-Y/linux-networking-labs) —
  deep networking track: layer 1/2 through layer 5, tcpdump/Wireshark, DNS
  internals, nmap/recon, multi-fault incidents.

## Methodology

1. **Build** it correctly, manually, first.
2. **Break** it — a realistic misconfiguration or failure.
3. **Fix** it using evidence (logs, `strace`, kernel/proc state), not guesswork.
4. **Test/Log** the fix to confirm it actually holds.
5. **Postmortem** — what happened, actual root cause, evidence, what you'd
   tell a teammate.

No harden step. That discipline lives in `linux-security-labs`.

## `/lab-notes`

Session-level notes and postmortems that don't belong to a single topic.

## Structure

Modules are numbered in dependency-correct learning order, not build order.
Numbering has been revised twice since this repo started — see `BACKLOG.md`
for the full translation history if any external notes reference an older
scheme. Current order, and why `02-logs-auditing` sits where it does: log
literacy (`journalctl`, `dmesg`, persistent vs volatile journal storage) is
assumed by `01-boot-process`, `07-process-signals`, and `09-services-systemd`
— all of which come before where logs-auditing used to sit (originally
`13`) — so it was moved up immediately after boot-process.

| Topic | Status |
|---|---|
| `00-shell-and-filesystem` | Scaffolded, empty. Foundation module — added to fill a prerequisite gap; nothing here assumed prior shell fluency existed before this. |
| `01-boot-process` | Scaffolded, empty. Intended as conceptual (boot sequence, read-only exploration), not adversarial GRUB recovery — that harder version may belong later, near storage/fstab, if built at all. |
| `02-logs-auditing` | Scaffolded, empty. Moved here (from position 13) so log literacy exists before the several earlier modules that already assume it. |
| `03-package-management` | Scaffolded, empty. Placed early on purpose — every later module assumes you can install tools. |
| `04-permission-directories` | Break/drills/fix present. No test-log, no README. Postmortem folder added, needs content. |
| `05-users-sudo` | Break/drills/fix present. No test-log, no README. Postmortem folder added, needs content. |
| `06-sbin-admin` | **Inconsistent** — drills/README/test-log exist with no break/fix behind them. This is intentional, not a gap: sbin-admin's break/fix content was deliberately split out to `linux-security-labs/phase3-access-control/sbin-admin` on 2026-07-17; the drills that remain here (inventory, user management, filesystem ops, service management reference) were kept on purpose as neutral admin-tool reference material. See `BACKLOG.md` for the full split history. |
| `07-process-signals` | Build/break/fix/test-log/notes/README present. Postmortem folder added, needs content. Has legacy `harden/` (pre-scope). |
| `08-bin-recovery` | Build/break/fix/test-log/README present. Postmortem folder added, needs content. Has legacy `harden/` (pre-scope). |
| `09-services-systemd` | Empty — not started. |
| `10-storage-mounts-fstab` | Empty — not started. |
| `11-networking` | Break/drills/fix/README present. Postmortem folder added. **Overlaps with `linux-networking-labs` — migration or scope-narrowing decision owed, see Known Gaps.** |
| `12-ssh` | Scaffolded, empty. |
| `13-firewall` | Scaffolded, empty. **Likely redundant with `linux-networking-labs`' existing `firewall-rule-precedence` and `nat` work — scope decision owed, see Known Gaps.** |
| `14-shell-scripting-automation` | Empty — not started. Capstone module — intended to automate mechanisms taught in earlier modules, not to teach new mechanism itself. |

## Known gaps as of last review

- `04-permission-directories` and `05-users-sudo` have no test-log — the fix
  was never proven to hold.
- `09`, `10`, `14` are bare skeletons. `02-logs-auditing` is also an empty
  skeleton as of this reorder, freshly relocated but not yet built out.
- `11-networking` and `13-firewall` overlap with real, more developed
  content already in `linux-networking-labs` (routing/NAT/ICMP diagnostics,
  `firewall-rule-precedence`). Undecided: migrate this content there and
  remove/narrow it here, or keep a permanently shallow fundamentals-level
  version and reserve depth for the dedicated repo. Not resolved as of this
  writing — do not build out `11` or `13` further until this is decided.
- `12-ssh` may also warrant a look against `linux-security-labs`'
  `ssh-hardening` module to confirm no unintended duplication, though SSH's
  basic mechanism plausibly belongs here regardless.
- Every postmortem folder added in a previous pass is empty — folders exist,
  no postmortems written yet.
