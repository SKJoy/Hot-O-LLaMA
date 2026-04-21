#!/bin/bash

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

    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_types text/plain text/css application/json application/javascript application/xml text/javascript;

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



# Test and reload Nginx
nginx -t && nginx -s reload


