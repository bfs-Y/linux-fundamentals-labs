# Lab Setup

## Requirements

- One Linux VM you fully control, snapshot-able, destroy/rebuild in minutes.
- Any mainstream distro is fine (Ubuntu Server, Debian, Rocky, Fedora) — the
  modules in this repo are about underlying mechanism, not distro-specific
  tooling, though a few (package-management) will note distro differences
  where they matter.
- Root or sudo access on that VM. Never run break/fix exercises against a
  machine that isn't disposable.
- Basic tools installed before starting `00-shell-and-filesystem`: a text
  editor you're comfortable with (`nano` or `vim`), `git`.

## Recommended setup

- KVM/libvirt, VirtualBox, or any hypervisor you already have — this repo
  doesn't assume a specific one.
- Take a clean snapshot immediately after first boot, before touching
  anything. Every module's BREAK step should start from a known-good state,
  not from wherever the last module left things.
- A second, throwaway snapshot or clone is useful once you reach modules
  that risk an unrecoverable state (`01-boot-process`, `09-storage-mounts-fstab`)
  — restore from snapshot rather than trying to manually undo a bad
  break/fix attempt.

## What this repo assumes you already have

- Comfort typing in a terminal (this is not a "how to open a terminal"
  repo — `00-shell-and-filesystem` starts at paths, redirection, and
  inodes, not at what a terminal is).
- Network access from the VM to install packages (needed from
  `02-package-management` onward).

## What this repo does NOT require

- A multi-VM network topology — that's the domain of
  [`linux-networking-labs`](https://github.com/bfs-Y/linux-networking-labs).
- Root on a real production or shared machine — every exercise here assumes
  a disposable, single-user lab VM.

## Rebuilding from scratch

If a module's BREAK step leaves the VM in a state you can't confidently
recover from using that module's own FIX step, restore from your clean
snapshot rather than attempting a manual repair outside the lab cycle —
the point is proving you can fix what you broke, not proving you can save
a VM you no longer understand the state of.


## Before every break step

Run `hostname` and confirm you're on the lab VM, not your host machine.
This has bitten this project once already — a break/fix session was
accidentally run against the host instead of the training VM. Cheap to
check, expensive to recover from if skipped.
