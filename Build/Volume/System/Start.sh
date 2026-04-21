#!/bin/bash

# Copy default files from /System/Default to / without overwriting existing files
cp -n /System/Default/* / 2>/dev/null

# Manual changes by me to make code more organized and manageable
bash OLLaMA-Start.sh
bash NginX-Host-Build.sh
bash OLLaMA-Model-Manage.sh

# Keep container running
tail -f /dev/null

