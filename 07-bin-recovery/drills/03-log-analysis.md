# Drill 03: Log Analysis Without tail

Time: 5 minutes

## Scenario

System won't boot. Emergency shell. `/usr` unavailable.

Must analyze logs to find what failed.

## Setup
```bash
docker run -it --rm --privileged alpine:3.19 /bin/sh
hostname  # Verify in container

cat > /var/log/boot.log << 'EOF'
[OK] Started Network Manager
[OK] Started User Login Management
[FAILED] Failed to mount /usr - filesystem check required
[OK] Started Emergency Shell
[ERROR] Cannot start systemd services without /usr
[FAILED] Failed to start Apache Web Server
[OK] Mounted /boot partition
[ERROR] /dev/sda2 has filesystem errors
[OK] Started System Logger
[FAILED] Failed to mount /home - disk not found
EOF

mv /usr /usr.backup
mkdir /usr
```

## Analysis

Show failures:
```bash
grep FAILED /var/log/boot.log
```

Show errors:
```bash
grep ERROR /var/log/boot.log
```

Count them:
```bash
grep -c FAILED /var/log/boot.log  # Returns: 3
grep -c ERROR /var/log/boot.log   # Returns: 2
```

Find problematic device:
```bash
grep ERROR /var/log/boot.log | grep /dev
```

Output: `/dev/sda2 has filesystem errors`

## Tools Available

- `cat` - read entire file
- `grep` - filter lines
- `grep -c` - count matches
- `grep -i` - case-insensitive search

## Tools Missing

- `tail` - see last N lines (in `/usr/bin`)
- `less` - paginated viewing (in `/usr/bin`)
- `vim` - editing (in `/usr/bin`)
- `wc` - might not be in `/bin` on minimal systems

## Workarounds

No tail? Use grep for specific terms:
```bash
grep -i error /var/log/boot.log
grep -i mount /var/log/boot.log
```

Or read the whole file if small:
```bash
cat /var/log/boot.log
```

## Cleanup
```bash
exit
```

## Key Lesson

Emergency shell log analysis relies on grep. Learn grep flags:
- `-c` count matches
- `-i` ignore case 
- `-v` invert (show non-matches)
- `-A 5` show 5 lines after match
- `-B 5` show 5 lines before match
