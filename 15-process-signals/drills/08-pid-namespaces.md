## Objective

Understand PID namespaces — how containers use them for isolation
and how attackers abuse them to hide processes.

## Drill 1 — Check your current namespace

readlink /proc/self/ns/pid
ps -eo pid,pidns,cmd | head -20

Note your host namespace ID. Every process on the host
shares this same number.

## Drill 2 — Create a new PID namespace

sudo unshare --pid --fork --mount-proc bash

Inside the namespace:
readlink /proc/self/ns/pid     — different ID than host
ps aux                         — only 2 processes visible
echo $$                        — you are PID 1

From the host (second terminal):
ps aux | grep unshare          — host sees real PID
ps -eo pid,pidns,cmd | grep bash  — host sees namespace ID

## Drill 3 — Detect processes in foreign namespaces

Get your host namespace ID:
HOST_NS=$(readlink /proc/self/ns/pid | tr -d 'pid:[]')

Find any process NOT in the host namespace:
ps -eo pid,pidns,cmd | awk -v ns=$HOST_NS '$2 != ns && $2 != "-" && $2 != "PIDNS"'

Empty = clean.
Any output = process in a different namespace — investigate.

## Drill 4 — Docker and PID namespaces

Run a container and check its namespace:
docker run -d --name test nginx
docker inspect test | grep Pid
cat /proc/CONTAINER_PID/status | grep NSpid

NSpid shows both the host PID and the namespace PID.
The container thinks it is PID 1.
The host knows its real PID.

## Key questions

- What does a process inside a PID namespace see vs the host?
- Why is host-level monitoring more reliable than container-level?
- How do you detect a process running in a foreign namespace?
- What is NSpid in /proc/PID/status?
- Why does the first process in a PID namespace become PID 1?
