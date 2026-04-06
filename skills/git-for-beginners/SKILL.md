---
name: git-for-beginners
description: Simplified Git workflow for non-technical founders. Covers commits, branches, pull requests, and merging. Use when the user is new to Git or asks basic version control questions.
---

# Git for Beginners

## What Is Git (Simple Version)

Git is a save system for your code. Like saving a game - you can go back to any save point if something breaks.

**Key concepts:**
- **Commit** = a save point. "Save my work with a note about what I changed"
- **Branch** = a copy of your project to try something new without breaking the main version
- **Push** = upload your saves to GitHub (cloud backup)
- **Pull Request (PR)** = asking to merge your branch back into the main version

## The Simple Workflow

### 1. Start Work on a New Feature

```bash
# Create a new branch for your feature
git checkout -b feature/add-pricing-page

# Now you're on your own copy. The main version is safe.
```

### 2. Make Changes and Save

```bash
# See what changed
git status

# Save your work (commit)
git add .
git commit -m "feat: add pricing page with 3 tiers"
```

### 3. Push to GitHub

```bash
# Upload to GitHub
git push -u origin feature/add-pricing-page
```

### 4. Create a Pull Request

```bash
# Create a PR on GitHub
gh pr create --title "Add pricing page" --body "Added pricing page with free, pro, and enterprise tiers"
```

### 5. Merge When Ready

```bash
# After review, merge to main
gh pr merge --merge
```

## Commit Message Format

Use this pattern: `type: what you did`

| Type | When to Use | Example |
|------|------------|---------|
| `feat` | New feature | `feat: add user profile page` |
| `fix` | Bug fix | `fix: login button not working on mobile` |
| `docs` | Documentation | `docs: update README with setup instructions` |
| `style` | Visual changes | `style: update button colors to match brand` |
| `refactor` | Code cleanup | `refactor: simplify checkout flow` |

## Common Situations

### "I broke something and want to go back"
```bash
# See recent commits
git log --oneline -10

# Go back to a specific commit (keep changes as unstaged)
git reset --soft HEAD~1
```

### "I want to see what changed"
```bash
git diff
```

### "I need to switch branches"
```bash
# Save current work first
git stash

# Switch branches
git checkout main

# Come back and restore work
git checkout feature/my-feature
git stash pop
```

## Rules

1. **Never push directly to main.** Always use branches and PRs.
2. **Commit often.** Small commits are easier to undo than big ones.
3. **Write clear commit messages.** Future you will thank present you.
4. **Pull before you push.** Run `git pull` before pushing to avoid conflicts.
