#!/bin/sh

# Manage OLLaMA models
MODEL_FILE="/Data/Model.txt"
if [ -f "$MODEL_FILE" ]; then
    while IFS= read -r LINE || [ -n "$LINE" ]; do
        LINE=$(echo "$LINE" | xargs)
        if [ -z "$LINE" ] || [ "${LINE:0:1}" = "#" ]; then
            continue
        fi
        if [ "${LINE:0:6}" = "REMOVE " ]; then
            MODEL="${LINE:6}"
            ollama rm "$MODEL"
        elif [ "${LINE:0:8}" = "DOWNLOAD " ]; then
            MODEL="${LINE:8}"
            ollama pull "$MODEL"
        fi
    done < "$MODEL_FILE"
fi

# Clone default model to hot-o-llama if OLLAMA_DEFAULT_MODEL is set
if [ -n "$OLLAMA_DEFAULT_MODEL" ]; then
    # Pull the default model if not already present
    if ! ollama list | grep -q "^${OLLAMA_DEFAULT_MODEL}"; then
        ollama pull "$OLLAMA_DEFAULT_MODEL"
    fi
    # Clone/rename to hot-o-llama
    ollama cp "$OLLAMA_DEFAULT_MODEL" hot-o-llama
fi

