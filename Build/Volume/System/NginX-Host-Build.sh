#!/bin/bash

# /Data/Bearer-Token.txt => /etc/nginx/conf.d/default-bearer-token.conf
TOKEN_FILE="/Data/Bearer-Token.txt"
BEARER_CONF="/etc/nginx/conf.d/default-bearer-token.conf"

cat > "$BEARER_CONF" << EOF
map \$ollama_bearer_token \$ollama_token_valid {
    default 0;

EOF

if [ -f "$TOKEN_FILE" ]; then
    while IFS= read -r LINE || [ -n "$LINE" ]; do
        LINE=$(echo "$LINE" | xargs)
        if [ -z "$LINE" ] || [ "${LINE:0:1}" = "#" ]; then
            continue
        fi
        if [ "${LINE:0:7}" = "ENABLE " ]; then
            TOKEN="${LINE:7}"
            echo "    \"$TOKEN\" 1;" >> "$BEARER_CONF"
        fi
    done < "$TOKEN_FILE"
fi

cat >> "$BEARER_CONF" << 'EOF'
}
EOF

# Replace timeout values with NGINX_TIMEOUT from .env
sed -i "s/^proxy_connect_timeout .*/proxy_connect_timeout ${NGINX_TIMEOUT:-300}s/" /etc/nginx/conf.d/default.conf
sed -i "s/^proxy_send_timeout .*/proxy_send_timeout ${NGINX_TIMEOUT:-300}s/" /etc/nginx/conf.d/default.conf
sed -i "s/^proxy_read_timeout .*/proxy_read_timeout ${NGINX_TIMEOUT:-300}s/" /etc/nginx/conf.d/default.conf
sed -i "s/^send_timeout .*/send_timeout ${NGINX_TIMEOUT:-300}s/" /etc/nginx/conf.d/default.conf

# Fix permission for nginx log directory (mounted from host)
chmod 755 /var/log/nginx
chmod 755 /var/log/php

# Test and reload Nginx
nginx -t && nginx


