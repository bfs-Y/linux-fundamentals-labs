## Objective

Understand how systemd manages process lifecycle through signals.
Build, test, and harden a real systemd service.

## Drill 1 — Read a real unit file

cat /lib/systemd/system/nginx.service

Find these fields and explain each one:
- ExecStop
- KillMode
- TimeoutStopSec
- Type
- After

## Drill 2 — Write a minimal unit file

Create /etc/systemd/system/webapp.service:

[Unit]
Description=Python Web Application
After=network.target

[Service]
Type=simple
User=training
WorkingDirectory=/home/training
ExecStart=/usr/bin/python3 -m http.server 8080
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
KillMode=mixed

[Install]
WantedBy=multi-user.target

Load and start:
sudo systemctl daemon-reload
sudo systemctl start webapp
sudo systemctl status webapp

## Drill 3 — Test automatic restart

Get the PID:
sudo systemctl status webapp | grep "Main PID"

Kill it hard — simulate crash:
sudo kill -9 PID

Wait 5 seconds. Check:
sudo systemctl status webapp | grep -E "Active|Main PID"

New PID = systemd restarted automatically.

## Drill 4 — Watch the signal sequence on stop

In one terminal watch logs:
sudo journalctl -u webapp -f

In another terminal stop the service:
sudo systemctl stop webapp

Watch the stop sequence in logs:
Stopping → SIGTERM sent → process exits → Stopped

## Drill 5 — Create a systemd timer

Replace cron with a systemd timer for nightly restart.
Create webapp-restart.timer and webapp-restart.service.
Verify with: sudo systemctl list-timers

## Key questions

- What signal does systemctl stop send first?
- What happens after TimeoutStopSec if process is still running?
- What is the difference between Type=simple and Type=forking?
- What does Restart=on-failure vs Restart=always do?
- What does Persistent=true do in a timer?
- Why does daemon-reload not restart services?
