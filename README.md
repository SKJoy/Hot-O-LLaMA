# Hot-O-LLaMA - Docker-based OLLaMA Server with Bearer Token Authentication 🦙

A Docker containerized OLLaMA server with Nginx reverse proxy and Bearer token authentication (OpenAI-compatible).

## Features ✨

- 🐳 Official OLLaMA image base (Ubuntu)
- 🛡️ Nginx reverse proxy with Bearer token auth
- 🔐 OpenAI-compatible API (`Authorization: Bearer <token>`)
- 📦 Automatic model management (download/remove)
- ⚙️ Environment variable configuration
- 🔄 Model renaming for API consistency (`hot-o-llama`)

## Architecture 🏗️

```
┌──────────────────────────────────────────────────────────┐
│                    Docker Container                        │
│                                                            │
│  ┌──────────────┐         ┌──────────────┐               │
│  │   OLLaMA     │         │   Nginx      │               │
│  │  Port 11434  │<--------│   Port 80    │               │
│  │  (serve)     │         │ (Bearer auth) │               │
│  └──────────────┘         └──────────────┘               │
│                                 │                         │
└─────────────────────────────────┼─────────────────────────┘
                                  │
                     ┌─────────────┴─────────────┐
                     │       Ports Mapping       │
                     │                           │
             ┌───────┴───────┐         ┌─────────┴─────────┐
             │   Port 80     │         │   Port 11434      │
             │ (Nginx +Auth) │         │  (Direct OLLaMA) │
             └───────────────┘         └───────────────────┘
```

## Prerequisites 🛠️

- 🐳 Docker Engine 24+ or Docker Desktop
- 🐳 Docker Compose v2.20+

## Configuration ⚙️

### Environment Variables (`.env`)

#### Docker Stack 🐳
| Variable | Default | Description |
|----------|---------|-------------|
| `VOLUME_PATH` | `./` | Volume path prefix |
| `NETWORK_PREFIX` | `172.31.245.` | Docker network prefix (change per stack) |
| `USER_ID` | `0` | Container user ID |
| `USER_GROUP_ID` | `0` | Container group ID |

#### OLLaMA 🦙
| Variable | Default | Description |
|----------|---------|-------------|
| `OLLAMA_DEFAULT_MODEL` | `gemma4:e2b-it-q4_K_M` | Model to clone as `hot-o-llama` |
| `OLLAMA_CONTEXT_LENGTH` | `16384` | Maximum context length |
| `OLLAMA_NUM_THREADS` | `4` | Number of CPU threads |
| `OLLAMA_NUM_PARALLEL` | `2` | Parallel requests |
| `OLLAMA_MAX_LOADED_MODELS` | `2` | Max loaded models |
| `OLLAMA_KEEP_ALIVE` | `60m` | Model idle timeout |
| `OLLAMA_IP_HTTP` | `0.0.0.0` | OLLaMA server host (use gateway for internal only) |
| `OLLAMA_PORT_HTTP` | `11434` | OLLaMA port |

#### NginX 🛡️
| Variable | Default | Description |
|----------|---------|-------------|
| `NGINX_IP_HTTP` | `0.0.0.0` | Nginx server host (use gateway for internal only) |
| `NGINX_PORT_HTTP` | `65482` | Nginx port |

### Bearer Token Authentication 🔐 (`Data/Bearer-Token.txt`)

Format: `STATUS token`

```
ENABLE my-bearer-token-2026-1    # Allow access with this token
DISABLE my-bearer-token-2026-2   # Deny/disabled token
```

Comments (`#`) and empty lines are ignored.

Token validation is done via Nginx `map` directive:
- 🔍 Extracts token from `Authorization: Bearer <token>` header
- ✅ Validates against enabled tokens in the file
- ❌ Returns 401 if invalid or missing

### Model Management 📦 (`Data/Model.txt`)

Format: `ACTION model:tag`

```
DOWNLOAD model-name:tag    # Pull and install model
REMOVE model-name:tag     # Remove installed model
```

## Usage 🚀

### Quick Start 🏃‍♂️

```bash
# Copy sample.env to .env and configure
cp sample.env .env

# Start the container
docker-compose up -d

# Check logs
docker-compose logs -f
```

### Access Points 🌐

- 🔐 **Nginx (with Bearer auth required)**: `http://<host>:<NGINX_PORT_HTTP>`
- 🦙 **Direct OLLaMA (no Bearer auth required)**: `http://<host>:<OLLAMA_PORT_HTTP>`

> 📝 **Note**: OLLaMA port 11434 is exposed directly but only accessible from within the container. External access should be via Nginx on port 80 with Bearer token authentication.

### Using Bearer Tokens 🔐 (OpenAI-compatible)

```bash
# With Bearer token
curl -H "Authorization: Bearer my-bearer-key-2026-1" \
  -H "Content-Type: application/json" \
  http://localhost:65482/api/generate \
  -d '{"model":"hot-o-llama","prompt":"Say hello"}'

# Without token - returns 401 ❌
curl http://localhost:65482/api/generate
```

### Model Management 📦

#### Default Model 🏷️
The configured `OLLAMA_DEFAULT_MODEL` is automatically pulled and cloned as `hot-o-llama`. Clients can use `hot-o-llama` without knowing the actual model name.

#### Additional Models ➕
Add `DOWNLOAD` or `REMOVE` entries to `Data/Model.txt`:

```
DOWNLOAD llama3:8b-instruct-q4_K_M ✅
REMOVE old-model:latest ❌
```

## Environment Variables ⚙️

OLLaMA automatically picks up standard OLLaMA environment variables (set in docker-compose.yml):
- `OLLAMA_HOST` - Server host (internal, always 0.0.0.0)

## Troubleshooting 🛠️

### Container won't start ❌
- 📝 Check logs: `docker-compose logs server`
- ✅ Verify `.env` file exists and is valid

### Model not found 🦙
- 📋 Check model exists: `docker exec -it hot-o-llama-server-1 ollama list`
- 💫 Verify logs for pull errors

### Authentication failing (401) 🔒
- ✅ Verify bearer token is `ENABLED` in `Data/Bearer-Token.txt`
- 📝 Check header format: `Authorization: Bearer <token>` (not `Basic`)

### Port already in use 🚧
- 🔧 Change `NGINX_PORT_HTTP` or `OLLAMA_PORT_HTTP` in `.env`
- 🛡️ For internal-only expose, set IP to Docker network gateway

## License 📄

MIT License - See LICENSE file for details.