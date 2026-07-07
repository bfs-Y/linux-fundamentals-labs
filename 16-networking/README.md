# Module 16 — Linux Networking (Basics)

## Scope
This module now covers only basic networking failure modes that show up as
collateral damage during general Linux sysadmin work — the kind of thing you
fix in minutes once you know Linux, not deep protocol-level study.

**Deep networking labs — ARP, TCP/UDP internals, NAT, container namespaces,
load balancing, TLS, packet capture, network attacks — have moved to their
own repo: [linux-networking-labs](https://github.com/bfs-Y/linux-networking-labs)**

## What stays here
- Interface down / won't come up
- Route missing / default gateway gone
- DNS resolution silently failing
- A port blocked by firewall you didn't expect

## Structure
- break/ — scripts that deliberately break basic networking
- fix/ — diagnosis and repair for each break scenario
- drills/ — hands-on command sequences for muscle memory
