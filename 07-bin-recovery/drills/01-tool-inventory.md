# Drill 01: Tool Inventory

Time: 5 minutes

## Scenario

System won't boot. Emergency shell. `/usr` missing.

Figure out what you have to work with.

## Setup
```bash
docker run -it --rm alpine:3.19 /bin/sh
mv /usr /usr.backup
```

## What to Do

List what's in `/bin`. Note what's missing that you'd normally reach for.

Find out if there's any text editor available.

Check if you can read logs.

## What You Get (82 commands)

**Shells:** sh, ash

**Files:** ls, cat, cp, mv, rm, mkdir, chmod, chown, ln

**Text:** grep, sed (no awk, no tail)

**System:** ps, dmesg, mount, umount, df, stat

**Network:** ping, netstat

**Other:** tar, gzip, gunzip

## What's Gone

vim, nano - no real editors

curl, wget - no network fetching

systemctl - no service management

python, perl - no interpreters

find - filesystem search gone

tail - can't tail logs normally

awk - no advanced text processing

## Workarounds

**No tail:**
```bash
dmesg | grep -i error
cat /var/log/messages | grep fail
```

**No find:**
```bash
ls -R /var | grep suspicious
```

**No vim:**

Use `vi` if it exists in `/bin`. Otherwise `ed`. Or just `cat` to read, `echo >>` to append.

## Exit
```bash
mv /usr.backup /usr
exit
```

## Point

Emergency mode gives you almost nothing. Learn what's actually in `/bin` so you know what you can and can't do when things break.
