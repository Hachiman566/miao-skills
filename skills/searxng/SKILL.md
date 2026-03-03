---
name: searxng
description: Self-hosted web_search capability using SearXNG metasearch engine. Aggregates 70+ search engines for free, unlimited searches. Works with agent's web_fetch for full content. Requires deployed SearXNG instance.
---

# SearXNG Search Skill

Self-hosted metasearch engine integration for AI agents.

> **⚠️ Prerequisites Required**
>
> This skill requires a **running SearXNG instance** to work. You must deploy SearXNG first before using this skill.
>
> See the [Deployment](#deployment) section below for instructions.

## What it does

Provides free, unlimited web search using a self-hosted SearXNG instance.

## Prerequisites Check

Before using this skill, verify SearXNG is running:

```bash
# Check if SearXNG is accessible
curl http://localhost:8888/search?q=test&format=json

# Should return JSON with search results
```

If the command fails, SearXNG is not running. Deploy it first using the instructions below.

## When to use

Use this skill when the user needs to:
- Search the web for current information
- Get search results from multiple engines aggregated together
- Perform unlimited searches without API costs
- Maintain privacy with self-hosted search

## Deployment

### Quick Start (Docker)

```bash
docker run -d \
  --name searxng \
  -p 8888:8080 \
  -e "SEARXNG_BASE_URL=http://localhost:8888/" \
  -e "SEARXNG_SECRET=$(openssl rand -hex 32)" \
  --restart unless-stopped \
  searxng/searxng:latest
```

### With Docker Compose (Recommended)

Create `docker-compose.yml`:

```yaml
version: '3'
services:
  searxng:
    image: searxng/searxng:latest
    container_name: searxng
    ports:
      - "8888:8080"
    environment:
      - SEARXNG_BASE_URL=http://localhost:8888/
      - SEARXNG_SECRET=${SEARXNG_SECRET}
    volumes:
      - ./searxng:/etc/searxng:rw
    restart: unless-stopped
```

```bash
# Generate secret
echo "SEARXNG_SECRET=$(openssl rand -hex 32)" > .env

# Start
docker compose up -d
```

### Configuration for JSON API

Create `searxng/settings.yml` to enable JSON API:

```yaml
use_default_settings: true

search:
  safe_search: 0
  autocomplete: ""
  default_lang: "all"
  formats:
    - html
    - json    # Enable JSON output

server:
  port: 8080
  bind_address: "0.0.0.0"
  secret_key: "${SEARXNG_SECRET}"
  limiter: false  # Disable rate limiter for local use

outgoing:
  request_timeout: 10.0
  max_request_timeout: 15.0
```

## Instructions

### Method 1: web_fetch (Recommended)

```javascript
// Basic search
await web_fetch({
  url: "http://localhost:8888/search?q=openai&format=json"
})

// With specific engines
await web_fetch({
  url: "http://localhost:8888/search?q=openai&engines=google,bing&format=json"
})

// Chinese search
await web_fetch({
  url: "http://localhost:8888/search?q=人工智能&format=json&lang=zh"
})
```

### Method 2: exec + jq (for parsing)

```bash
curl -s "http://localhost:8888/search?q=openai&format=json" | jq '.results[] | {title, url, content}'
```

### Method 3: exec + curl (more control)

```bash
curl -s "http://localhost:8888/search?q=你的搜索词&format=json" | jq '.results[] | {title, url, content}'
```

## Search Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `q` | Search query | `q=openai` |
| `format` | Output format | `format=json` |
| `engines` | Specific engines | `engines=google,bing,duckduckgo` |
| `lang` | Language | `lang=zh` |
| `pageno` | Page number | `pageno=2` |
| `time_range` | Time filter | `time_range=day/week/month/year` |
| `safesearch` | Safe search | `safesearch=0/1/2` |

## Available Engines

SearXNG aggregates 70+ search engines including:
- Google, Bing, DuckDuckGo
- Wikipedia, Reddit
- GitHub, Stack Overflow
- YouTube, YouTube No Ads
- And many more

## Advantages

- **Free**: No API costs, unlimited requests
- **Privacy**: No tracking, self-hosted
- **Flexible**: Aggregate multiple engines
- **No Rate Limits**: Your own instance

## Notes

- First request may be slow (engine warm-up)
- Run on a server with public IP for remote access
- For production, consider adding authentication
