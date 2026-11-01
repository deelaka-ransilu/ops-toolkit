#!/usr/bin/env bash

LOG_FILE="$HOME/ops-toolkit/logs/health.log"

DISK_LIMIT=80
MEM_LIMIT=80
LOAD_LIMIT=8
PORTS="53"
problems=0

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$1] $2" >> "$LOG_FILE"
}

# --- Disk ---
disk=$(df / | awk 'NR==2 {gsub("%",""); print $5}')

if [ "$disk" -ge "$DISK_LIMIT" ]; then
    echo "WARNING: Disk usage ${disk}% (limit ${DISK_LIMIT}%)"
    log "WARN" "Disk usage ${disk}% (limit ${DISK_LIMIT}%)"
    problems=$((problems + 1))
else
    echo "OK: Disk usage ${disk}%"
    log "OK" "Disk usage ${disk}%"
fi

# --- Memory ---
mem=$(free | awk '/Mem:/ {printf "%d", $3/$2*100}')

if [ "$mem" -ge "$MEM_LIMIT" ]; then
    echo "WARNING: Memory usage ${mem}% (limit ${MEM_LIMIT}%)"
    log "WARN" "Memory usage ${mem}% (limit ${MEM_LIMIT}%)"
    problems=$((problems + 1))
else
    echo "OK: Memory usage ${mem}%"
    log "OK" "Memory usage ${mem}%"
fi

# --- Load ---
load=$(cut -d' ' -f1 /proc/loadavg)

if awk -v l="$load" -v m="$LOAD_LIMIT" 'BEGIN {exit !(l >= m)}'; then
    echo "WARNING: Load average ${load} (limit ${LOAD_LIMIT})"
    log "WARN" "Load average ${load} (limit ${LOAD_LIMIT})"
    problems=$((problems + 1))
else
    echo "OK: Load average ${load}"
    log "OK" "Load average ${load}"
fi

# --- Process ---
if pgrep -x cron > /dev/null; then
    echo "OK: Process cron is running"
    log "OK" "Process cron is running"
else
    echo "WARNING: Process cron is NOT running"
    log "WARN" "Process cron is NOT running"
    problems=$((problems + 1))
fi

# --- Ports ---
for port in $PORTS; do
    if ss -ltn | grep -q ":${port} "; then
        echo "OK: Port ${port} is listening"
        log "OK" "Port ${port} is listening"
    else
        echo "WARNING: Port ${port} is NOT listening"
        log "WARN" "Port ${port} is NOT listening"
        problems=$((problems + 1))
    fi
done

# --- Exit code ---
if [ "$problems" -gt 0 ]; then
    exit 1
else
    exit 0
fi