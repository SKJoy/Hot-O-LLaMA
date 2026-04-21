#!/bin/bash

# Copy default files from /System/Default to / without overwriting existing files
cp -n /System/Default/* /

# Manual changes by me to make code more organized and manageable
bash OLLaMA-Start.sh
bash OLLaMA-Model-Manage.sh

# Start PHP-FPM in background
php-fpm8.4 &

# Build NginX host configuration
bash NginX-Host-Build.sh

# Keep container running
tail -f /dev/null

