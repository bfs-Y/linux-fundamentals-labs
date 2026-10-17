#!/usr/bin/env bash
# Rocky. Locks hplip-libs behind libsane-hpaio.
# Check versions first: dnf --showduplicates list hplip-libs
set -euo pipefail
OLD=3.23.12-10.el10_2.5
sudo dnf install -y 'dnf-command(versionlock)'
sudo dnf downgrade -y "hplip-libs-$OLD" "hplip-common-$OLD" "libsane-hpaio-$OLD"
sudo dnf versionlock add hplip-libs
echo "Broken. Diagnose cold: sudo dnf upgrade libsane-hpaio"
