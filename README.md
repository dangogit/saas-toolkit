# saas-toolkit

Base Claude Code plugin for SaaS development. Part of the nCode course by Daniel Goldman.

## Install

```bash
claude plugin add dangogit/saas-toolkit
```

## What's Included

### Skills
- `env-management` - Local/staging/production environment patterns
- `payment-sandbox` - Test payments safely (Polar.sh, RevenueCat)
- `supabase-local-dev` - Local Supabase development workflow
- `git-for-beginners` - Simplified Git for non-technical founders
- `claude-code-intro` - Claude Code fundamentals and memory

### Agents
- `saas-mentor` - Business advice (pricing, positioning, growth)
- `prd-writer` - Generate PRDs from idea descriptions
- `code-reviewer` - Review code before shipping
- `qa-tester` - Test features and find edge cases

## MCP Servers (installed by nCode installer)

The nCode installer (`danielthegoldman.com/claude-code-installer`) sets up these MCPs automatically:
- **Context7** - Look up any library/framework docs instantly
- **Playwright** - Browser testing and automation
- **Memory** - Persistent knowledge graph

Track-specific MCPs are listed in each extension's README.

## Recommended Plugins

```bash
# Superpowers - brainstorming, planning, debugging, TDD
claude plugin add superpowers

# Context7 - library docs lookup
claude plugin add context7
```

## Extensions

- `dangogit/saas-toolkit-web` - Web development track
- `dangogit/saas-toolkit-mobile` - Mobile development track
