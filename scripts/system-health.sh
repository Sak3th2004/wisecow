#!/usr/bin/env bash
set -eu

CPU_LIMIT="${CPU_LIMIT:-80}"
MEM_LIMIT="${MEM_LIMIT:-80}"
DISK_LIMIT="${DISK_LIMIT:-80}"
PROC_LIMIT="${PROC_LIMIT:-400}"
LOG_FILE="${LOG_FILE:-health-alerts.log}"

if [ ! -r /proc/stat ]; then
  echo "this check needs a linux system" >&2
  exit 1
fi

read_cpu() {
  awk '/^cpu / {print $2+$3+$4+$5+$6+$7+$8, $5+$6}' /proc/stat
}

read -r total1 idle1 < <(read_cpu)
sleep 1
read -r total2 idle2 < <(read_cpu)

delta=$((total2 - total1))
if [ "$delta" -le 0 ]; then
  cpu=0
else
  cpu=$(( (100 * (delta - (idle2 - idle1))) / delta ))
fi

mem=$(awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {printf "%d", (t-a)*100/t}' /proc/meminfo)
disk=$(df -P / | awk 'NR==2 {gsub("%","",$5); print $5}')
procs=$(ps -e --no-headers | wc -l | tr -d ' ')

echo "cpu=${cpu}% mem=${mem}% disk=${disk}% procs=${procs}"

alert() {
  echo "ALERT $1"
  echo "$(date '+%Y-%m-%d %H:%M:%S') ALERT $1" >> "$LOG_FILE"
}

if [ "$cpu" -gt "$CPU_LIMIT" ]; then
  alert "cpu ${cpu}% > ${CPU_LIMIT}%"
fi
if [ "$mem" -gt "$MEM_LIMIT" ]; then
  alert "memory ${mem}% > ${MEM_LIMIT}%"
fi
if [ "$disk" -gt "$DISK_LIMIT" ]; then
  alert "disk ${disk}% > ${DISK_LIMIT}%"
fi
if [ "$procs" -gt "$PROC_LIMIT" ]; then
  alert "processes ${procs} > ${PROC_LIMIT}"
fi