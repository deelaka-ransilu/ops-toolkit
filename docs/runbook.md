# Runbook

Notes on how ops-toolkit works and what I do when something breaks.

## What this toolkit checks

health-check.sh checks 5 things:
- disk (limit 80%)
- memory (limit 80%)
- load (limit 8)
- whether cron is running
- whether port 53 is listening.

Each result goes into logs/health.log. If something is wrong it also writes an alert to logs/alerts.log and exits with 1. If all is fine it exits with 0. Cron runs it every 5 minutes.

## Where the logs are

- logs/health.log: every check result
- logs/alerts.log: only problems
- logs/health.log.1.gz: old rotated logs (logrotate keeps 7 days)

Quick look: `tail -n 10 logs/health.log`

## Failure 1: port goes down

I started a server on port 8080 and then killed it. The script printed a WARNING, exited with 1, and wrote an [ALERT]. Fix: restart the service.

## Failure 2: cron stops

I stopped cron on purpose. No [ALERT] appeared, only a gap in health.log, because nothing was running the script. Fix: `sudo service cron start`.

## Failure 3: disk limit

A 1 GB file didn't change usage on my 1 TB disk, so I lowered DISK_LIMIT to 3 to trigger the warning. This was simulated, not a real full disk. Fix in real life: find what's using the space and remove it.

## Known limitations

- Cron in WSL only runs while WSL is open.
- If cron dies, the script can't report it.
- Alerts only go to a log file.