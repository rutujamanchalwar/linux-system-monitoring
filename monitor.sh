#!/bin/bash

DATE=$(date)
OS=$(uname)
LOG_FILE="monitor.log"

echo "----- $DATE -----" >> $LOG_FILE

# ---------------- CPU ----------------
if [ "$OS" = "Darwin" ]; then
  CPU=$(top -l 1 | grep "CPU usage" | awk '{print $3 + $5}')
else
  CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
fi

# ---------------- MEMORY ----------------
if [ "$OS" = "Darwin" ]; then
  MEM=$(vm_stat | awk '
  /Pages active/ {active=$3}
  /Pages wired/ {wired=$4}
  /Pages free/ {free=$3}
  END {
    total=(active+wired+free)*4096/1024/1024
    used=(active+wired)*4096/1024/1024
    printf "%.2f", (used/total)*100
  }')
else
  MEM=$(free | awk 'NR==2{printf "%.2f", $3*100/$2}')
fi

# ---------------- DISK ----------------
DISK=$(df -h / | awk 'NR==2{print $5}' | tr -d '%')

# ---------------- OUTPUT ----------------
echo "CPU Usage: $CPU%" | tee -a $LOG_FILE
echo "Memory Usage: $MEM%" | tee -a $LOG_FILE
echo "Disk Usage: $DISK%" | tee -a $LOG_FILE