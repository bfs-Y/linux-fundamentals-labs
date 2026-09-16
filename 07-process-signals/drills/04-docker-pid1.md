## Scenario

A Dockerized Flask application is accumulating zombie processes after several hours in production because dead worker or child processes are exiting, but the parent process running as PID 1 is not properly calling wait() to clean them up.

## What you should observe

ps -eo pid,ppid,state,cmd | awk '$3 ~ /Z/'

Look for Z state processes. Note the PPID — repeated parent PID points to the culprit.

## Diagnosis steps

Step 1 — confirm zombies exist and identify parent
ps -eo pid,ppid,state,cmd | awk '$3 ~ /Z/'

Step 2 — check what PID 1 is inside the container
docker exec -it CONTAINER_NAME ps -fp 1

Step 3 — confirm PID 1 is not reaping children
sudo strace -p 1 -e trace=wait4
Silence = broken. No wait4 calls while zombies accumulate.

## Fix

Option 1 — immediate
docker run --init ...

Option 2 — permanent
Add to Dockerfile:
RUN apt-get install -y tini
ENTRYPOINT ["/usr/bin/tini", "--", "python", "app.py"]

## Verify

ps -eo pid,ppid,state,cmd | awk '$3 ~ /Z/'
No Z state processes. PID exhaustion risk eliminated.
