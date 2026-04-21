#!/bin/bash

# Copy default files from /System/Default to / without overwriting existing files
cp -n /System/Default/* /

# Copy PHP config to PHP-FPM conf.d directory (from Data if exists, else template)
if [ -f /Data/PHP.ini ]; then
    cp -f /Data/PHP.ini /etc/php/8.4/fpm/conf.d/99-custom.ini
else
    cp -f /System/Default/Data/PHP.ini /etc/php/8.4/fpm/conf.d/99-custom.ini
fi

# Manual changes by me to make code more organized and manageable
bash OLLaMA-Start.sh
bash OLLaMA-Model-Manage.sh

# Start PHP-FPM in background
php-fpm8.4 &

# Build NginX host configuration
bash NginX-Host-Build.sh

# Keep container running
tail -f /dev/null

