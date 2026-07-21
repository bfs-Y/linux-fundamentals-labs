# Drill 04: Process Management Without systemctl

Time: 6 minutes

## Scenario

Emergency shell. `/usr` missing. A service crashed and you need to restart it.

No `systemctl`. No `journalctl`. Just basic process tools.

## Setup
```bash
docker run -it --rm --privileged alpine:3.19 /bin/sh

# Fake a running service
sleep 3600 &
SLEEP_PID=$!
echo $SLEEP_PID > /tmp/service.pid

# Break /usr
mv /usr /usr.backup
mkdir /usr
```

## What You Need To Do

Find running processes. Kill the sleep process. Start a new one. Verify it's actually running.

## Commands That Work

**See what's running:**
```bash
ps
```

**Find your process:**
```bash
ps | grep sleep
```

**Kill it:**
```bash
kill 123
```

If it won't die:
```bash
kill -9 123
```

**Start something in background:**
```bash
sleep 1000 &
echo $! > /tmp/newservice.pid
```

**Check it's there:**
```bash
ps | grep sleep
```

## What Doesn't Work

`systemctl status` - gone  
`systemctl restart` - gone  
`journalctl` - gone  

They're all in `/usr`.

## How To Work Around It

**No logs?**
```bash
dmesg | grep -i error
cat /var/log/messages
```

**Need to reload a service?**
```bash
kill -HUP $PID
```

**Need to stop gracefully?**
```bash
kill -TERM $PID
```

**Nuclear option:**
```bash
kill -9 $PID
```

## Exit
```bash
kill $(cat /tmp/service.pid)
exit
```

## Point

systemctl hides the details. Emergency mode exposes them.

You're back to PIDs and signals. Learn them.
