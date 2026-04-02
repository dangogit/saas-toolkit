# saas-toolkit

A Claude Code plugin with everything you need to build, launch, and grow a SaaS product. 15 skills and a SaaS mentor agent covering your full stack - from bootstrapping to launch day.

**By [Daniel Goldman](https://danielthegoldman.com)**

## Quick Start

```bash
# Inside Claude Code
/plugin marketplace add dangogit/saas-toolkit
```

Then select and install the plugin from the marketplace. Restart Claude Code to activate.

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

### Agent

**saas-mentor** - A SaaS development mentor that knows the full stack. Ask it about architecture decisions, what to build next, how to validate ideas, or when to launch. It will point you to the right skill when relevant.

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
