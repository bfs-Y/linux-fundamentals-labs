# Drill 02: Manual /usr Mount

Time: 7 minutes

## Scenario

Boot failed. `/usr` partition exists but didn't auto-mount.

Emergency shell active. Must mount manually.

## Setup
```bash
docker run -it --rm --privileged alpine:3.19 /bin/sh
mv /usr /usr.unmounted
mkdir /usr
```

## Problem
```bash
vi
# /bin/sh: vi: not found
```

Tools in `/usr/bin` unavailable.

## Recovery

Check what should be mounted:
```bash
cat /etc/fstab  # In real scenario
```

Mount it:
```bash
mount /usr.unmounted /usr
```

Verify:
```bash
vi  # Should work now
ls /usr/bin | wc -l  # Should show 143
```

## Real-World Commands

If `/usr` is on `/dev/sda2`:
```bash
mount /dev/sda2 /usr
```

If filesystem corrupt:
```bash
dmesg | grep -i error
# Might need: fsck /dev/sda2
```

Check current mounts:
```bash
mount  # No args, shows all mounted filesystems
```

## Cleanup
```bash
exit
```

## Key Points

`mount [source] [destination]` reconnects filesystems.

Without `/usr`, you lose editors, network tools, most utilities.

Emergency shell has `mount` in `/bin` for exactly this reason.

Always verify with `ls /usr/bin | wc -l` or try running a tool.
