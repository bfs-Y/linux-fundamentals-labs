#!/usr/bin/env bash
# Ubuntu. Holds nginx-common behind nginx so "apt install nginx" fails.
# Check versions first: apt-cache policy nginx-common
set -euo pipefail
OLD=1.24.0-2ubuntu7
sudo apt-get install -y nginx
sudo apt-get install -y --allow-downgrades "nginx=$OLD" "nginx-common=$OLD"
sudo apt-mark hold nginx-common
echo "Broken. Diagnose cold: sudo apt install nginx"
