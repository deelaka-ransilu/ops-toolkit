#!/usr/bin/env bash

LOG_FILE="$HOME/ops-toolkit/logs/health.log"

DISK_LIMIT=80
MEM_LIMIT=80
LOAD_LIMIT=8

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$1] $2" >> "$LOG_FILE"
}

# --- Disk ---
disk=$(df / | awk 'NR==2 {gsub("%",""); print $5}')

if [ "$disk" -ge "$DISK_LIMIT" ]; then
    echo "WARNING: Disk usage ${disk}% (limit ${DISK_LIMIT}%)"
    log "WARN" "Disk usage ${disk}% (limit ${DISK_LIMIT}%)"
else
    echo "OK: Disk usage ${disk}%"
    log "OK" "Disk usage ${disk}%"
fi

# --- Memory ---
mem=$(free | awk '/Mem:/ {printf "%d", $3/$2*100}')

if [ "$mem" -ge "$MEM_LIMIT" ]; then
    echo "WARNING: Memory usage ${mem}% (limit ${MEM_LIMIT}%)"
    log "WARN" "Memory usage ${mem}% (limit ${MEM_LIMIT}%)"
else
    echo "OK: Memory usage ${mem}%"
    log "OK" "Memory usage ${mem}%"
fi

# --- Load ---
load=$(cut -d' ' -f1 /proc/loadavg)

if awk -v l="$load" -v m="$LOAD_LIMIT" 'BEGIN {exit !(l >= m)}'; then
    echo "WARNING: Load average ${load} (limit ${LOAD_LIMIT})"
    log "WARN" "Load average ${load} (limit ${LOAD_LIMIT})"
else
    echo "OK: Load average ${load}"
    log "OK" "Load average ${load}"
fi