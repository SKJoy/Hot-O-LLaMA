#!/bin/bash

# Truncate log files exceeding HOT_O_LLAMA_MAX_LOG_SIZE
MAX_SIZE="${HOT_O_LLAMA_MAX_LOG_SIZE:-4096}"

for logfile in /var/log/nginx/*.log /var/log/php/*.log; do
    if [ -f "$logfile" ]; then
        SIZE=$(stat -c%s "$logfile" 2>/dev/null)
        if [ -n "$SIZE" ] && [ "$SIZE" -gt "$MAX_SIZE" ]; then
            : > "$logfile"
        fi
    fi
done
