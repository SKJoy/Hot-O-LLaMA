#!/bin/sh

# Copy default files from /System/Default to / without overwriting existing files
cp -n /System/Default/* / 2>/dev/null

# Build Nginx config with bearer token authentication
build_nginx_config() {
    local NGINX_CONF="/etc/nginx/conf.d/default.conf"
    local TOKEN_FILE="/Data/Bearer-Token.txt"
    local TIMEOUT="${NGINX_TIMEOUT:-300}"
    
    cat > "$NGINX_CONF" << NGINX_EOF
map \$http_authorization \$ollama_bearer_token {
    default "";
    "~*Bearer\s+([^\s]+)" \$1;
}

map \$ollama_bearer_token \$ollama_token_valid {
    default 0;

NGINX_EOF

    # Add enabled tokens to map
    if [ -f "$TOKEN_FILE" ]; then
        while IFS= read -r LINE || [ -n "$LINE" ]; do
            LINE=$(echo "$LINE" | xargs)
            if [ -z "$LINE" ] || [ "${LINE:0:1}" = "#" ]; then
                continue
            fi
            if [ "${LINE:0:7}" = "ENABLE " ]; then
                TOKEN="${LINE:7}"
                echo "    \"$TOKEN\" 1;" >> "$NGINX_CONF"
            fi
        done < "$TOKEN_FILE"
    fi

    cat >> "$NGINX_CONF" << NGINX_EOF

    proxy_connect_timeout ${TIMEOUT}s;
    proxy_send_timeout ${TIMEOUT}s;
    proxy_read_timeout ${TIMEOUT}s;
    send_timeout ${TIMEOUT}s;
    proxy_buffering off;
    proxy_request_buffering off;

    location / {
        if (\$ollama_token_valid = 0) {
            return 401 "Unauthorized: Invalid or missing bearer token";
        }

        proxy_pass http://localhost:11434/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
NGINX_EOF
}

# Start Ollama in background with output to stdout (if not already running)
if ! pgrep -x ollama > /dev/null 2>&1; then
    nohup ollama serve > /dev/stdout 2>&1 &
fi

# Wait for Ollama to start
sleep 5

# Build Nginx config with bearer tokens
build_nginx_config

# Test and reload Nginx
nginx -t && nginx -s reload

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

# Keep container running
exec tail -f /dev/null