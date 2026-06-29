#!/bin/bash
# Harden 01: Three-layer security audit for a fresh or existing server
# Layer 1: SSH (the literal front door for remote access)
# Layer 2: Firewall (controls what traffic can even reach any service)
# Layer 3: Privilege/root limiting (damage control if someone still gets in)
# This is the closing exercise of Module 16 — applies reasoning built across every prior topic.

echo "=== LAYER 1: SSH HARDENING AUDIT ==="
sudo sshd -T | grep -iE "permitrootlogin|passwordauthentication|maxauthtries|x11forwarding"
echo ""
echo "Expected: permitrootlogin no, passwordauthentication no, x11forwarding no,"
echo "maxauthtries a low number (e.g. 3). Anything else is a gap to close."

echo ""
echo "=== LAYER 2: FIREWALL AUDIT ==="
sudo ufw status verbose
echo ""
echo "Expected: Default deny (incoming). SSH scoped to a specific trusted range,"
echo "NOT 'Anywhere' / 0.0.0.0/0. Only genuinely public services (e.g. port 80) open wide."

echo ""
echo "=== LAYER 3: PRIVILEGE/ROOT LIMITING AUDIT ==="
echo "Users with sudo (root-equivalent) access:"
getent group sudo
echo ""
echo "Root account password status:"
sudo passwd -S root
echo ""
echo "Expected: minimal, known users in the sudo group (flag anything unexpected —"
echo "a classic persistence technique is an attacker adding themselves to this group)."
echo "Expected: root status shows 'L' (Locked) — no direct root login possible at all,"
echo "the only path to root is through sudo as a known, audited user."
