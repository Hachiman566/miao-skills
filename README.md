# 🎯 Miao Skills

[![skills](https://img.shields.io/badge/skills-ai%20agents-blue)](https://skills.sh/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A collection of useful skills for AI agents including Claude Code, Cursor, Codex, Gemini CLI, OpenClaw, and 40+ more agents.

## 📦 Available Skills

### 🔍 [searxng](./skills/searxng/SKILL.md)

Self-hosted metasearch engine integration for AI agents. Provides free, unlimited web search using a self-hosted SearXNG instance.

**Features:**
- 🆓 Free, unlimited web search
- 🔒 Privacy-focused, self-hosted
- 🌐 Aggregates 70+ search engines
- 💰 No API costs or rate limits

## 🚀 Quick Install

### Install searxng Skill

```bash
npx skills add Hachiman566/miao-skills --skill searxng
```

### Install All Skills

```bash
npx skills add Hachiman566/miao-skills
```

### Install Globally (Recommended)

```bash
npx skills add Hachiman566/miao-skills --global --skill searxng
```

## 📚 Supported Agents

This skill works with all agents in the [skills ecosystem](https://skills.sh/):

- Claude Code
- Cursor
- Codex
- Gemini CLI
- OpenClaw
- And 40+ more

## 🤝 Contributing

Contributions are welcome!

1. Fork this repository
2. Create a new skill in `skills/<skill-name>/SKILL.md`
3. Follow the [skill guidelines](#-skill-guidelines)
4. Submit a pull request

## 📋 Skill Guidelines

Each skill should include:

- ✅ Proper YAML frontmatter with `name` and `description`
- ✅ Clear "When to use" section
- ✅ Step-by-step instructions
- ✅ Code examples where applicable

**Example frontmatter:**

```yaml
---
name: my-skill
description: A brief description of what this skill does
---
```

## 📖 License

MIT © [Hachiman566](https://github.com/Hachiman566)

---

**Made with ❤️ for the AI agent community**
