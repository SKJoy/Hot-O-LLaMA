#!/bin/bash

# Start OLLaMA in background with output to stdout (if not already running)
# Official OLLaMA image runs as PID 1 via entrypoint, but we check to be safe
if ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    nohup ollama serve > /dev/stdout 2>&1 &
fi

# Wait for OLLaMA to start
sleep 5

