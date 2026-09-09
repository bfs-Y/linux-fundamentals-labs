# Drill 04: Service Management

Time: 8 minutes

## What You're Doing

Using systemctl and service commands to manage system services.

## Start Container with systemd
```bash
docker run -it --rm --privileged ubuntu:22.04 /bin/bash
apt update && apt install -y systemd ssh
```

Note: Full systemd doesn't work well in containers. Commands shown for reference.

## Check Service Status
```bash
systemctl status ssh
```

Shows if ssh service is running, stopped, or failed.

Common states:
- active (running) - service is up
- inactive (dead) - service stopped
- failed - service crashed

## Start a Service
```bash
systemctl start ssh
```

No output = success.

Check:
```bash
systemctl status ssh
```

Should show "active (running)".

## Stop a Service
```bash
systemctl stop ssh
```

Check:
```bash
systemctl status ssh
```

Should show "inactive (dead)".

## Enable Service at Boot
```bash
systemctl enable ssh
```

Service will auto-start on boot.

Check:
```bash
systemctl is-enabled ssh
```

Shows: "enabled"

## Disable Service at Boot
```bash
systemctl disable ssh
```

Won't start on boot anymore.

## Restart Service
```bash
systemctl restart ssh
```

Stops then starts (applies new config).

## Reload Service Config
```bash
systemctl reload ssh
```

Reloads config without stopping service (if service supports it).

## List All Services
```bash
systemctl list-units --type=service
```

Shows every service and its state.

Filter running only:
```bash
systemctl list-units --type=service --state=running
```

Filter failed:
```bash
systemctl list-units --type=service --state=failed
```

## Check Service Logs
```bash
journalctl -u ssh
```

Shows logs for ssh service.

Last 50 lines:
```bash
journalctl -u ssh -n 50
```

Follow live:
```bash
journalctl -u ssh -f
```

Press Ctrl+C to stop.

## Service Dependencies

See what service depends on:
```bash
systemctl list-dependencies ssh
```

Shows services that must start before ssh.

## Create Simple Service
```bash
cat > /etc/systemd/system/test.service << 'EOF'
[Unit]
Description=Test Service

[Service]
ExecStart=/bin/sleep 3600
Restart=always

[Install]
WantedBy=multi-user.target
EOF
```

Reload systemd:
```bash
systemctl daemon-reload
```

Start it:
```bash
systemctl start test
systemctl status test
```

Should be running.

Stop it:
```bash
systemctl stop test
```

## Key Commands
```
systemctl status service    # Check status
systemctl start service     # Start
systemctl stop service      # Stop
systemctl restart service   # Restart
systemctl enable service    # Auto-start at boot
systemctl disable service   # Don't auto-start
systemctl list-units        # List all services
journalctl -u service       # View logs
```

## Old Style (pre-systemd)

Some systems use:
```bash
service ssh start
service ssh stop
service ssh status
```

Works on older Linux or when systemctl isn't available.

## Exit
```bash
exit
```

## Key Lesson

systemctl controls all services on modern Linux.

Start/stop/enable are most common operations.

journalctl shows service logs.
