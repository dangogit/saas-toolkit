# saas-toolkit

A Claude Code plugin with everything you need to build, launch, and grow a SaaS product. 15 skills and 4 agents covering your full stack - from spec to launch day.

**By [Daniel Goldman](https://danielthegoldman.com)**

## Quick Start

### Install from GitHub (recommended)

```bash
claude plugin add dangogit/saas-toolkit
```

This installs directly from the GitHub repo - works right away.

### Install from Marketplace

```bash
claude plugin add dangogit/saas-toolkit
```

If the plugin is listed on the Claude Code marketplace, you can also browse and install it there. Marketplace approval may still be pending - use the GitHub method above if it's not available yet.

---

Restart Claude Code after installing to activate all skills and agents.

## Skills

### Build

| Command | What it does |
|---------|-------------|
| `/setup` | Bootstrap a new project - Next.js + Supabase + Tailwind + shadcn/ui + React Query + zod |
| `/auth` | Supabase Auth end-to-end - OAuth, email/password, middleware, protected routes, AuthProvider |
| `/database` | Supabase schema design, RLS policies, migrations, real-time, storage |
| `/responsive-ui` | Mobile-first UI - shadcn/ui components, TanStack Table, React Query, forms, charts, dark mode |
| `/ai-integration` | Add AI features with Vercel AI SDK - streaming chat, tool calling, structured output |
| `/billing` | Subscription management - Polar.sh checkout, webhooks, feature gating, pricing page |
| `/api-integration` | Polar.sh payments, Resend email, webhooks, third-party API patterns |
| `/analytics` | PostHog setup - event tracking, funnels, feature flags, A/B testing, session replay |
| `/secure` | Security audit - OWASP top 10 for Next.js/Supabase, auth hardening, input validation |

### Launch

| Command | What it does |
|---------|-------------|
| `/landing-page` | High-converting landing pages - headline formulas, CTA design, section order, social proof |
| `/seo` | Technical SEO, on-page optimization, Next.js metadata API, structured data, Core Web Vitals |
| `/brand-kit` | Brand identity - logo, favicon, OG images, color palette, typography, dark mode tokens |
| `/content-writer` | Marketing copy - blog posts, social media, email sequences, Product Hunt launch, changelog |
| `/deploy` | Deploy to Vercel - pre-flight build checks, GitHub repo, env vars, custom domain, rollback |
| `/launch-checklist` | 100+ item pre-launch checklist across code, database, auth, payments, SEO, security, analytics |

### Agents

| Agent | What it does |
|-------|-------------|
| **saas-mentor** | SaaS development mentor - architecture decisions, idea validation, what to build next |
| **prd-writer** | Takes a feature idea, explores your codebase, interviews you, and outputs a structured PRD with user stories, data model, API design, and acceptance criteria |
| **saas-reviewer** | Read-only code review for SaaS - checks auth gaps, RLS policies, billing logic, webhook security. Two-stage: spec compliance then code quality. Verdicts: APPROVE / BLOCK |
| **qa-tester** | Generates test plans for SaaS-critical flows (auth, billing, subscriptions, feature gating) and writes Playwright/Vitest tests |

## Tech Stack

This toolkit is opinionated about what works for shipping SaaS products fast:

| Layer | Tool |
|-------|------|
| Framework | Next.js App Router + TypeScript |
| UI | Tailwind CSS + shadcn/ui + Radix |
| Database | Supabase (Postgres + Auth + Storage + Edge Functions) |
| Data | TanStack React Query + react-hook-form + zod |
| Hosting | Vercel |
| Payments | Polar.sh (Merchant of Record) |
| Analytics | PostHog |
| AI | Vercel AI SDK (Anthropic, OpenAI, Google) |
| Email | Resend + React Email |

## Recommended Companion Plugins

These are separate plugins that pair well with saas-toolkit:

```bash
claude plugin install superpowers@superpowers-marketplace
claude plugin install context7@claude-plugins-official
claude plugin install frontend-design@claude-plugins-official
```

| Plugin | What it adds |
|--------|-------------|
| **superpowers** | Brainstorming, implementation planning, systematic debugging, TDD, code review |
| **context7** | Auto-fetches latest library docs so you never get stale API advice |
| **frontend-design** | Generates distinctive, production-grade UI beyond default AI aesthetics |

## The SaaS Journey

```
  Validate idea
       |
    prd-writer -------> Spec the feature
       |
    /setup -----------> Bootstrap project
       |
    /auth ------------> Set up authentication
       |
    /database --------> Design schema + RLS
       |
    /responsive-ui ---> Build the UI
       |
    /ai-integration --> Add AI features
       |
    /billing ---------> Subscriptions + feature gating
       |
    /api-integration -> Connect email + APIs
       |
    /analytics -------> Track everything
       |
    /secure ----------> Audit security
       |
    saas-reviewer ----> Review the code
       |
    qa-tester --------> Test critical flows
       |
    /landing-page ----> Build your marketing page
       |
    /seo -------------> Optimize for search
       |
    /brand-kit -------> Logo, favicon, OG images
       |
    /content-writer --> Write launch copy
       |
    /launch-checklist > Final verification
       |
    /deploy ----------> Ship it
```

## About

Built by [Daniel Goldman](https://danielthegoldman.com) based on patterns from real SaaS products in production. Every skill reflects how things are actually built - not how they look in tutorials.

## License

MIT
