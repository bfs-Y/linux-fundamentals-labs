#!/bin/bash
# Recall drill: config file ownership/permissions
echo "Q1: A service can't read its own config file. What TWO things"
echo "    do you check first, in order?"
read -p "Your answer: " ans1
echo "Reference: 1) ls -la <file>  2) confirm expected owner/group matches"
echo "the service's actual running user (check with: ps aux | grep <service>)"
echo ""
echo "Q2: You need a config readable by the 'nobody' user specifically."
echo "    What group does 'nobody' actually belong to on Ubuntu, and how"
echo "    do you find out if you're not sure?"
read -p "Your answer: " ans2
echo "Reference: nogroup (not 'nobody') — confirm with: id nobody"
echo ""
echo "Q3: Write the two commands to set correct owner AND safe permission"
echo "    (readable by owner+group, not world) on /etc/myconfig.conf for"
echo "    a service running as 'appuser'."
read -p "Your answer: " ans3
echo "Reference: chown appuser:appuser /etc/myconfig.conf"
echo "           chmod 640 /etc/myconfig.conf"
