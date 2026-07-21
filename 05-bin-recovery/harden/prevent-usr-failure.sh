#!/bin/bash
# Hardening to prevent /usr mount failures

cat << 'EOF'
# /usr Mount Failure Prevention

## 1. Filesystem Health Monitoring

Check filesystem regularly:
  tune2fs -l /dev/sdaX | grep -i "filesystem state"

Schedule automated checks:
  Add to /etc/crontab:
  0 2 * * 0 /sbin/fsck -n /dev/sdaX

## 2. Fstab Validation

Verify mount points before reboot:
  mount -a -v --fake

Check syntax:
  findmnt --verify

## 3. Emergency Shell Practice

Test recovery quarterly:
  - Boot to emergency mode intentionally
  - Time yourself mounting /usr
  - Verify log analysis skills

## 4. Separate /bin from /usr (Legacy Systems)

On critical servers, keep real /bin split.
Avoid merged /bin → /usr/bin layout.

Tradeoff: More complex package management
Benefit: Better recoverability

## 5. Boot Monitoring

Alert on mount failures:
  - Configure systemd to email on emergency.target
  - Monitor /var/log/boot.log for FAILED entries

## Limitations

- Does not prevent hardware failure
- Cannot fix corrupted filesystems automatically
- Assumes root partition remains accessible

Modern systemd systems may use different emergency targets.
Test your specific distro's behavior.
EOF
