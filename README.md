# Miao Skills

A collection of useful skills for AI agents (Claude Code, Cursor, Codex, Gemini CLI, OpenClaw, and more).

## Available Skills

### [searxng](./skills/searxng/SKILL.md)
Self-hosted metasearch engine integration for AI agents. Provides free, unlimited web search using a self-hosted SearXNG instance.

## Installation

### Install All Skills

```bash
npx skills add <your-username>/miao-skills
```

### Install Specific Skill

```bash
npx skills add <your-username>/miao-skills --skill searxng
```

### Install for Specific Agent

```bash
# For Claude Code
npx skills add <your-username>/miao-skills --agent claude-code --skill searxng

# For Cursor
npx skills add <your-username>/miao-skills --agent cursor --skill searxng

# Install globally
npx skills add <your-username>/miao-skills --global --skill searxng
```

## Contributing

Contributions are welcome! Feel free to:

1. Fork this repository
2. Create a new skill in `skills/<skill-name>/SKILL.md`
3. Submit a pull request

## Skill Guidelines

Each skill should have:
- Proper frontmatter with `name` and `description`
- Clear "When to use" section
- Step-by-step instructions
- Code examples where applicable

## License

MIT
