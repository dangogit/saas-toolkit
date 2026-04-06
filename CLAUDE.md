# saas-toolkit

Base toolkit for SaaS development with Claude Code. Part of the nCode course ecosystem.

## Plugin Architecture

This is the base plugin. Students also install one track extension:
- `saas-toolkit-web` - Next.js + Supabase + Vercel + AI SDK + Gemini
- `saas-toolkit-mobile` - React Native + Expo + Firebase + Gemini

## Conventions

- Students are non-technical founders. Explain decisions simply.
- Always use environment variables for secrets. Never hardcode.
- Default to the "Golden Stack": Next.js + Supabase + Vercel + Polar.sh + PostHog
- When suggesting commands, prefer Claude Code skills over raw CLI commands.
- Hebrew is the primary language of course content but code and comments should be in English.
