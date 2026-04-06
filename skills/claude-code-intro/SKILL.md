---
name: claude-code-intro
description: Claude Code fundamentals - what it is, how it works, core workflows, memory system, and CLAUDE.md configuration. Use when setting up Claude Code for the first time or explaining how it works.
---

# Claude Code Fundamentals

## What Is Claude Code

Claude Code is an AI coding assistant that runs in your terminal. Unlike ChatGPT or browser-based Claude, it can:
- See your **entire codebase** - all files, all connections
- Make changes across **multiple files** at once
- Run commands, install packages, deploy code
- Remember context between sessions via CLAUDE.md and MEMORY.md

## Core Workflows

### Chat Mode
Ask Claude Code questions about your project:
- "Explain how authentication works in this app"
- "Show me all the API routes"
- "What happens when a user signs up?"

### Making Changes
Tell Claude Code what you want built:
- "Add a contact form to the landing page"
- "Fix the bug where users can't log out"
- "Add dark mode support"

Claude Code will read relevant files, propose changes, and apply them with your approval.

### Multi-File Operations
Claude Code excels at changes that touch many files:
- "Rename the User model to Customer everywhere"
- "Add PostHog tracking to all button clicks"
- "Update all API routes to require authentication"

## Memory System

### CLAUDE.md - Project Instructions
A file at your project root that tells Claude Code how to work in this project:
- What tech stack you use
- Coding conventions to follow
- Commands for building, testing, deploying

**Hierarchy (most specific wins):**
1. `~/.claude/CLAUDE.md` - Global preferences (all projects)
2. `./CLAUDE.md` - Project-level instructions
3. `./src/CLAUDE.md` - Directory-level overrides

### MEMORY.md - Persistent Knowledge
Claude Code remembers things between conversations:
- Your role and preferences
- Decisions made in previous sessions
- Feedback you gave ("don't do X", "always do Y")

Ask Claude Code to remember something:
- "Remember that we use Polar.sh for payments, not Stripe"
- "Remember that the admin email is admin@example.com"

## Essential Commands

| Command | What It Does |
|---------|-------------|
| `claude` | Start Claude Code in current directory |
| `/help` | Show available commands |
| `/clear` | Clear conversation history |
| `/compact` | Compress conversation to save context |
| `/cost` | Show token usage and cost |
| `Shift+Tab` | Switch between Plan and Act modes |

## Tips for Non-Technical Users

1. **Be specific.** "Add a blue button that says Subscribe" is better than "make it look nice"
2. **One thing at a time.** Don't ask for 5 features in one message
3. **Review changes.** Read what Claude Code changed before accepting
4. **Use Plan mode first.** Press Shift+Tab to plan before implementing
5. **Save your CLAUDE.md.** It's the most important file in your project
