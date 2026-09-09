# /bin - Emergency Shell Recovery

When `/usr` won't mount, half your toolset disappears. This documents recovery with what's left in `/bin`.

## Problem

Boot failure drops you into emergency shell with PATH limited to `/bin:/sbin`.

On systems with real `/bin` split: ~50 binaries available. 
On merged `/bin` → `/usr/bin` systems: symlink points nowhere, almost nothing works.

Recovery requires filesystem diagnostics and manual mounting using only basic tools.

## /bin Contents (Traditional Split)

Present in emergency shell:
```
sh bash ls cat cp mv rm mkdir chmod mount umount
grep sed ps kill dmesg login vi ed
```

Missing (stuck in `/usr/bin`):
```
vim nano curl wget systemctl python tar gzip find
```

Merged systems (Ubuntu 22+, Debian 11+): `/bin` is symlink to `/usr/bin`. If `/usr` mount fails, symlink resolves to nothing. More fragile than split layout.

## Tested Scenarios

- Manual `/usr` mount after fsck failure
- Log analysis with grep/sed only (no text editors)
- Process inspection without systemctl
- Recovery when `vi` is only available editor

## Limitations

Does not cover:
- Encrypted `/usr` partitions (requires additional tools not in `/bin`)
- LVM recovery (needs `/sbin/lvm`, availability varies)
- Network-based recovery (no curl/wget in `/bin`)

Assumes:
- Root filesystem intact
- `/bin` and `/sbin` accessible
- Kernel panic did not occur (shell available)

## Known Gaps

- Limited testing on systemd-less init systems
- Does not address UEFI boot failures (requires efibootmgr)
- Assumes x86_64 architecture

Recovery on ARM/embedded may have different `/bin` contents.
