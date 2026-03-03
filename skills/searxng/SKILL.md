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

## Default Usage Pattern

**When using this skill, follow this pattern by default:**

```
1. Search with SearXNG → Get titles, URLs, snippets
2. Use snippets directly if they contain the answer
3. Only fetch full pages if more detail is needed
4. Limit to top 3-5 results
```

**Key principles:**
- Search snippets often contain the answer - use them first
- Fetching full pages costs more tokens - only do it when necessary
- Be selective with results - more results = more tokens

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

## Best Practices

**Default Behavior for Agents:**

When using this skill, follow these practices by default:

1. **Use search snippets first** - Don't fetch full pages unless needed
2. **Limit to top 3-5 results** - More results = more tokens
3. **Use precise keywords** - Short queries work better
4. **Specify target engines** - Reduces noise and token usage
5. **Filter by time range when relevant** - Get recent results only

### Recommended Usage Order (Most Efficient)

| Method | Token Usage | Speed | When to Use |
|---------|--------------|--------|-------------|
| `searxng_search` tool | ⭐⭐⭐ Lowest | Fast | **Primary choice** |
| `web_fetch` with SearXNG | ⭐⭐ Low | Fast | Fallback |
| `browser` with Google | ⭐ High | Slow | When login needed |

### Standard Practices

1. **Limit Results Count**
```javascript
// Only fetch first page (fewer results = less tokens)
searxng_search({ query: "rust", pageno: 1 })
```

2. **Specify Target Engines**
```javascript
// Use only relevant engines to reduce noise
searxng_search({
  query: "javascript error",
  engines: "stackoverflow,github"  // Developer-focused
})

// Chinese search
searxng_search({
  query: "人工智能",
  engines: "baidu,bing",
  lang: "zh"
})
```

3. **Use Precise Keywords**
```
❌ "帮我找一下关于 rust 语言的编程相关的资料和教程"
✅ "rust 编程教程"

❌ "搜索一下最新的人工智能新闻和动态"
✅ "AI 最新新闻"
```

4. **Filter by Time Range**
```javascript
// Recent results only (less data to process)
searxng_search({
  query: "openclaw update",
  time_range: "week"  // day/week/month/year
})
```

5. **Avoid Content Parsing When Possible**
```javascript
// ❌ This fetches full page content (high token usage)
const page = await web_fetch({ url: resultUrl })
const summary = await summarize({ text: page })

// ✅ Use search snippet directly (low token usage)
const results = await searxng_search({ query: "openclaw" })
for (const r of results.slice(0, 3)) {
  // Use r.content (snippet) instead of fetching full page
}
```

### When `web_fetch` is Blocked

If `web_fetch` shows "Blocked hostname" error (localhost SSRF protection):

```javascript
// Fallback: Use browser tool instead
// This costs more tokens but works reliably

// Tell agent to use browser
"用浏览器搜索：openclaw github"

// Agent will:
// 1. Open https://www.google.com/search?q=openclaw+github
// 2. Read results page
// 3. Extract relevant information
```

### Comparison: SearXNG vs Paid Search APIs

| Feature | SearXNG | Brave | Perplexity | Gemini |
|---------|---------|--------|------------|---------|
| **Cost** | Free ✅ | Paid | Paid | Paid |
| **Token Usage** | Low ⭐ | Low | Very Low | Very Low |
| **AI Summary** | ❌ | ❌ | ✅ | ✅ |
| **Rate Limits** | Unlimited ✅ | Limited | Limited | Limited |
| **Privacy** | Self-hosted ✅ | Third-party | Third-party | Third-party |

**Recommendation**: Use SearXNG for unlimited searches. Use Perplexity/Gemini when you need AI-summarized answers to save tokens.

### Quick Reference

```javascript
// ✅ Low token usage
const results = await searxng_search({ query: "rust async" });

// Process only top 3 results
for (const r of results.slice(0, 3)) {
  console.log(`${r.title}: ${r.url}`);
  // Use r.content (snippet) - already has answer
}

// ❌ High token usage
const page = await web_fetch({ url: result.url });  // Full page fetch
const summary = await summarize({ text: page });
```

## Notes

- First request may be slow (engine warm-up)
- Run on a server with public IP for remote access
- For production, consider adding authentication
- `web_fetch` may block localhost due to SSRF protection - use `browser` tool as fallback
