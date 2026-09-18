# Lab Notes — cross-module patterns and open threads

## 2026-09-17 — Module 00

- Command resolution order proven empirically: alias > function > builtin >
  $PATH external binary. `type -a` is the single tool that exposes every
  layer at once; `which`/`command -v` only show the final external-binary
  answer and can miss an intervening alias or function.
- An empty $PATH component means "search cwd," not "search nowhere" — a
  real, non-obvious gotcha worth carrying into later modules (09 services,
  14 cron) where environment differs from an interactive shell's.
- find's default scope in /tmp picks up systemd private-tmp dirs you don't
  own, producing unrelated Permission denied noise — scope find more
  tightly (-maxdepth, or a dedicated test dir) in future break scripts
  instead of running loose against shared directories like /tmp.
- Two wrong hypotheses were tested and killed with evidence (stale hash;
  then confirmed empty-PATH-searches-cwd) before landing on the real
  mechanism — worth remembering as a model for future debugging: cheap
  hypotheses first, killed fast by a single command, not defended.
