
#!/bin/bash

# Linux System Monitoring Tool

LOG_DIR="$HOME/linux-monitor/logs"
LOG_FILE="$LOG_DIR/monitor.log"
DISK_LIMIT=80

mkdir -p "$LOG_DIR"

HOSTNAME_VALUE=$(hostname)
UPTIME_VALUE=$(uptime -p)

# Get approximate CPU usage
CPU_USAGE=$(top -bn1 | awk '/Cpu\(s\)/ {
    for (i=1; i<=NF; i++) {
        if ($i ~ /^id,?$/) {
            idle = $(i-1)
            gsub(",", "", idle)
            printf "%.1f", 100-idle
            exit
        }
    }
}')

# Get memory usage percentage
MEMORY_USAGE=$(free | awk '/Mem:/ {
    if ($2 > 0) printf "%.1f", ($3/$2)*100
}')

# Get disk usage percentage
DISK_USAGE=$(df -P / | awk 'NR==2 {
    gsub("%", "", $5)
    print $5
}')

# Display and save the report
{
    echo "================================"
    echo "Time: $(date)"
    echo "Hostname: $HOSTNAME_VALUE"
    echo "Uptime: $UPTIME_VALUE"
    echo "CPU usage: ${CPU_USAGE:-Unavailable}%"
    echo "Memory usage: ${MEMORY_USAGE:-Unavailable}%"
    echo "Disk usage: ${DISK_USAGE:-Unavailable}%"

    if [[ "$DISK_USAGE" =~ ^[0-9]+$ ]] &&
       [ "$DISK_USAGE" -ge "$DISK_LIMIT" ]; then
        echo "WARNING: Disk usage is high!"
    else
        echo "Disk status: OK"
    fi

    echo "================================"
    echo
} | tee -a "$LOG_FILE"

