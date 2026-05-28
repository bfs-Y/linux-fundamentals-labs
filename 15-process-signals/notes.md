# Notes — 15 Process Signals

## Things that surprised me

A zombie process cannot be killed with kill -9. It is already dead.
The only thing that cleans it up is the parent calling wait().
I tried kill -9 on a zombie and nothing happened — now I understand why.

SIGKILL never reaches the process. The kernel handles it directly.
That is why no trap handler can catch it and why it leaves corrupt state.

A process in T state (stopped) will not respond to SIGTERM.
You have to use SIGKILL to force kill a stopped process.
I learned this the hard way during the reverse shell simulation.

## Things that connected later

The Docker PID 1 problem is just the zombie problem in a container.
The container has no real init so nobody calls wait().
Once I understood zombies I understood Docker PID 1 immediately.

nohup, tmux and disown all solve the same problem — surviving terminal death.
The difference is timing: nohup and tmux protect before, disown rescues after.

## Commands I need to remember

ps -eo pid,ppid,state,cmd | awk '$3 ~ /Z/'   — find zombies
sudo strace -p PID -e trace=wait4             — confirm broken reaping
cat /proc/PID/environ | tr '\0' '\n'          — read process environment
ls -l /proc/PID/exe                           — find real binary location
ss -pant | grep PID                           — check network connections

## Signals I keep confusing

SIGSTOP vs SIGTSTP
  SIGSTOP  — kernel level, cannot be caught or ignored
  SIGTSTP  — what Ctrl+z actually sends, CAN be caught

SIGHUP original vs repurposed
  Original  — terminal closed, kill the process
  Daemons   — repurposed as reload config signal

## Security patterns worth remembering

Three red flags for masquerading process:
  wrong path + wrong user + wrong parent = investigate immediately

Reverse shell indicators:
  web server process spawning bash
  stdout/stderr to /dev/null in lsof
  outbound connection in ss output

Always check persistence before killing:
  crontab -l
  /etc/cron.d/
  ~/.bashrc
  ~/.ssh/authorized_keys
  systemctl list-units
