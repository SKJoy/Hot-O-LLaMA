#!/bin/bash

# Start Ollama in background with output to stdout (if not already running)
if ! pgrep -x ollama > /dev/null 2>&1; then
    nohup ollama serve > /dev/stdout 2>&1 &
fi

# Wait for Ollama to start
sleep 5

