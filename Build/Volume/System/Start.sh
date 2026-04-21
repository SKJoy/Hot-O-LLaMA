#!/bin/bash

# Copy default files from /System/Default to / without overwriting existing files
cp -n /System/Default/* /

# Copy PHP config to PHP-FPM conf.d directory
cp -f /Data/PHP.ini /etc/php/8.4/fpm/conf.d/99-custom.ini

# Truncate log files exceeding HOT_O_LLAMA_MAX_LOG_SIZE
bash Log-Truncate.sh

# Manual changes by me to make code more organized and manageable
bash OLLaMA-Start.sh
bash OLLaMA-Model-Manage.sh

# Start PHP-FPM in background
php-fpm8.4 &

# Build NginX host configuration
bash NginX-Host-Build.sh

# Keep container running
tail -f /dev/null

