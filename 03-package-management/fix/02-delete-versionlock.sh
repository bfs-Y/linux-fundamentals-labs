#!/usr/bin/env bash
# Rocky. Smallest fix: drop the lock, then upgrade.
set -euo pipefail
sudo dnf versionlock delete hplip-libs
sudo dnf upgrade -y libsane-hpaio
rpm -q hplip-libs libsane-hpaio
cat /etc/dnf/plugins/versionlock.list
