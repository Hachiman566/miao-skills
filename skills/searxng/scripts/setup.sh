#!/usr/bin/env bash
# SearXNG setup script - auto-detects and starts SearXNG instance
set -e

CONTAINER_NAME="searxng"
PORT=8888
BASE_URL="http://localhost:${PORT}"
SETTINGS_DIR="${HOME}/.config/searxng"
SETTINGS_FILE="${SETTINGS_DIR}/settings.yml"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}[searxng]${NC} $*"; }
warn() { echo -e "${YELLOW}[searxng]${NC} $*"; }
fail() { echo -e "${RED}[searxng]${NC} $*"; exit 1; }

# Check if SearXNG is already responding
is_running() {
  curl -sf "${BASE_URL}/search?q=test&format=json" -o /dev/null 2>/dev/null
}

# Check if docker is available
check_docker() {
  if ! command -v docker &>/dev/null; then
    fail "Docker is not installed. Install Docker first: https://docs.docker.com/get-docker/"
  fi
  if ! docker info &>/dev/null; then
    fail "Docker daemon is not running. Start Docker and retry."
  fi
}

# Write minimal settings.yml that enables JSON API
write_settings() {
  mkdir -p "${SETTINGS_DIR}"
  if [[ ! -f "${SETTINGS_FILE}" ]]; then
    log "Writing SearXNG settings to ${SETTINGS_FILE}"
    cat > "${SETTINGS_FILE}" <<'EOF'
use_default_settings: true

search:
  safe_search: 0
  autocomplete: ""
  default_lang: "all"
  formats:
    - html
    - json

server:
  port: 8080
  bind_address: "0.0.0.0"
  limiter: false
EOF
  fi
}

main() {
  # Already up
  if is_running; then
    log "SearXNG is already running at ${BASE_URL}"
    exit 0
  fi

  check_docker
  write_settings

  # Container exists but stopped
  if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    warn "Container '${CONTAINER_NAME}' exists but is not running. Starting it..."
    docker start "${CONTAINER_NAME}"
  else
    # Generate a secret key
    SECRET=$(openssl rand -hex 32 2>/dev/null || cat /proc/sys/kernel/random/uuid 2>/dev/null | tr -d '-' || echo "$(date +%s)_searxng_secret")

    log "Creating SearXNG container on port ${PORT}..."
    docker run -d \
      --name "${CONTAINER_NAME}" \
      -p "${PORT}:8080" \
      -e "SEARXNG_BASE_URL=${BASE_URL}/" \
      -e "SEARXNG_SECRET=${SECRET}" \
      -v "${SETTINGS_DIR}:/etc/searxng:rw" \
      --restart unless-stopped \
      searxng/searxng:latest
  fi

  # Wait for it to be ready (up to 30s)
  log "Waiting for SearXNG to be ready..."
  for i in $(seq 1 30); do
    if is_running; then
      log "SearXNG is ready at ${BASE_URL}"
      exit 0
    fi
    sleep 1
  done

  fail "SearXNG did not become ready in 30s. Check logs: docker logs ${CONTAINER_NAME}"
}

main "$@"
