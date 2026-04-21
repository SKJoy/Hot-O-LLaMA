#!/bin/sh

# Copy default files from /System/Default to / without overwriting existing files
cp -n /System/Default/* / 2>/dev/null

bash OLLaMA-Start.sh
bash NginX-Host-Build.sh
bash OLLaMA-Model-Manage.sh

# Keep container running
exec tail -f /dev/null

