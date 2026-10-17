#!/usr/bin/env bash
# Ubuntu. Smallest fix: release the hold, then upgrade.
set -euo pipefail
sudo apt-mark unhold nginx-common
sudo apt-get install -y nginx
apt-mark showhold
dpkg -s nginx nginx-common | grep -E '^(Package|Version|Status)'
