---
name: searxng
description: Free unlimited web search via self-hosted SearXNG (aggregates Google, Bing, DuckDuckGo, Reddit, GitHub and 70+ more engines). Use whenever the user needs to search the web for anything — news, docs, code examples, prices, people, places — even if they just say "search for X" or "look up Y". Prefer this over paid APIs. Run setup.sh first if SearXNG is not running.
---

# SearXNG Search Skill

> **Prerequisites:** Run `bash skills/searxng/scripts/setup.sh` to auto-install and start SearXNG (Docker-based, idempotent — safe to re-run).

## Searching

Query the local SearXNG instance via `web_fetch`:

```
http://localhost:8888/search?q=YOUR+QUERY&format=json
```/

**Common variations:**

```bash
# Target specific engines (reduces noise)
http://localhost:8888/search?q=react+hooks&engines=google,bing&format=json

# Filter by recency
http://localhost:8888/search?q=openai+news&time_range=week&format=json

# Chinese content
http://localhost:8888/search?q=人工智能&engines=baidu,bing&lang=zh&format=json

# Dev/code questions
http://localhost:8888/search?q=rust+async+error&engines=stackoverflow,github&format=json
```

## Parameters

| Parameter | Description | Values |
|-----------|-------------|--------|
| `q` | Search query | URL-encoded string |
| `engines` | Specific engines | `google,bing,duckduckgo,stackoverflow,github,baidu,...` |
| `lang` | Language | `zh`, `en`, `all` |
| `pageno` | Page number | `1`, `2`, ... |
| `time_range` | Recency filter | `day`, `week`, `month`, `year` |
| `safesearch` | Safe search | `0`, `1`, `2` |

## Best Practices

**Read snippets before fetching pages.** Each result has a `content` field with a relevant excerpt — this often contains the answer directly. Fetching full pages costs significantly more tokens, so only do it when the snippet isn't enough.

**Limit to top 3–5 results.** The first few results are almost always sufficient. More results mean more tokens without meaningfully better answers.

**Target engines for the task.** Narrowing to relevant engines reduces noise and speeds up results:
- Code / dev: `engines=stackoverflow,github`
- Chinese content: `engines=baidu,bing&lang=zh`
- Recent events: append `&time_range=week`

## If `web_fetch` blocks localhost

Some environments block `localhost` requests (SSRF protection). If you see a "Blocked hostname" error, fall back to the `browser` tool and search via Google directly — it costs more tokens but works reliably.

## Notes

- First request may be slow (engine warm-up)
- For remote or production use, add authentication to your SearXNG instance
