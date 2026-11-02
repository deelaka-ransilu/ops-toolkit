# ops-toolkit

## What it is

A small monitoring setup for a Linux machine, built with Bash and cron. It checks the system every 5 minutes, logs the results, and writes an alert when something is wrong. I built it on WSL Ubuntu to learn shell scripting, cron and log handling.

## How the pieces fit

- `health-check.sh` checks disk, memory, load, the cron process and ports. Each result goes into `logs/health.log`.
- If a check fails, it calls `send-alert.sh`, which writes an `[ALERT]` line to `logs/alerts.log`.
- cron runs `health-check.sh` every 5 minutes.
- logrotate runs once a day. It compresses old logs and keeps 7 copies so the logs don't grow forever.

## How to run it

    git clone https://github.com/deelaka-ransilu/ops-toolkit.git
    cd ops-toolkit
    ./scripts/health-check.sh
    tail -n 10 logs/health.log

The script exits 0 if everything is fine and 1 if any check failed.

## Problems I hit and how I fixed them

- logrotate failed because VS Code saved the config with Windows (CRLF) line endings. I fixed it with `sed -i 's/\r$//'` and set VS Code to LF.
- A commit changed the script permissions to 644. I restored execute permission with `chmod +x`.
- I deleted and re-cloned the repo and lost the logs and empty folders. `mkdir -p` in the script recreates `logs/`.
- I kept editing in the terminal instead of the file, or forgot to save. Now I check every edit with `grep`.
- Cron checks showed up late because I looked at the logs before the 5-minute mark.
- logrotate gave a permission error on its default state file. I fixed it with my own state file using `-s`.

## Known limitations

- Cron in WSL only runs while WSL is open.
- If cron dies, nothing runs the script, so no alert is sent. The only sign is a gap in `health.log`.
- Alerts only go to a log file.
- I tested the disk check by lowering `DISK_LIMIT`, not by filling the disk.