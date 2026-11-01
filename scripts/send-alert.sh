#!/usr/bin/env bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$BASE_DIR/logs"
ALERT_FILE="$LOG_DIR/alerts.log"
mkdir -p "$LOG_DIR"

message="$1"

echo "$(date '+%Y-%m-%d %H:%M:%S') [ALERT] ${message}" >> "$ALERT_FILE"