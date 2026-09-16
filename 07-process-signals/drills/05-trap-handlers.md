## Scenario

A backup script runs nightly via cron. If killed mid-run it leaves a partial
backup file on disk that appears complete but is corrupt. Nobody notices until
disaster recovery fails three weeks later.

## What you should observe

Without trap — kill the script mid-run, temp file remains on disk.
With trap — kill the script mid-run, cleanup runs, temp file deleted, exit 1.

## Drill

1. Create a script without signal handling. Kill it mid-run.
   Observe the leftover temp file.

2. Add trap to the script:
   trap cleanup SIGTERM SIGINT EXIT

3. Add reset inside cleanup to prevent double-fire:
   trap - SIGTERM SIGINT EXIT

4. Kill it mid-run again. Confirm cleanup ran and temp file is gone.

5. Let it complete normally. Confirm no cleanup message — exit 0.

## Key concepts

SIGTERM — polite shutdown, can be caught. Always try before SIGKILL.
SIGKILL — cannot be caught. Trap never fires. File left on disk.
EXIT — bash pseudo-signal, fires on any exit including normal completion.
exit 1 — signals failure to cron/monitoring. Never exit 0 on unclean shutdown.

## Verify

Kill mid-run:
  ls -la /tmp/backup_temp.db — file should not exist
  echo $? on the script — should be 1

Normal completion:
  No "Caught signal" message printed
  exit code 0
