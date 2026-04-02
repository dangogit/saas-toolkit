---
name: launch-checklist
description: Pre-launch verification checklist covering code quality, security, performance, and marketing. Run through this before going live with any SaaS product. Use for: launch prep, production readiness. Triggers on "launch checklist", "pre-launch", "ready to launch", "go live checklist", "ship it".
---

# launch-checklist

> Pre-launch verification checklist covering everything from code quality to marketing. Run through this before going live with any SaaS product.

**Trigger phrases:** "launch checklist", "pre-launch", "ready to launch", "go live checklist", "production checklist", "before launch", "launch day", "ship it", "deployment checklist", "release checklist"

---

## How to Use This Checklist

1. Go through each category top to bottom
2. Mark items as you verify them
3. Items marked **(Critical)** must pass before launch - no exceptions
4. Items marked **(Recommended)** should be done but won't block launch
5. Items marked **(Nice-to-have)** can wait for post-launch

---

## Code Quality

- [ ] **(Critical)** Production build passes without errors (`npm run build`)
- [ ] **(Critical)** No `console.log` or `console.error` in production code
- [ ] **(Critical)** Environment variables are set for production (not hardcoded)
- [ ] **(Critical)** Error boundaries wrap all major page sections
- [ ] **(Critical)** No TypeScript `any` types in critical paths
- [ ] **(Recommended)** Linter passes with zero warnings (`npm run lint`)
- [ ] **(Recommended)** No unused dependencies in package.json
- [ ] **(Recommended)** Bundle size analyzed and optimized (no unnecessary client-side JS)
- [ ] **(Recommended)** API error responses return proper HTTP status codes
- [ ] **(Nice-to-have)** E2E tests cover critical user flows (signup, payment, core feature)

---

## Database

- [ ] **(Critical)** All migrations applied to production database
- [ ] **(Critical)** RLS (Row Level Security) policies enabled on all user-facing tables
- [ ] **(Critical)** Database indexes on frequently queried columns
- [ ] **(Critical)** Backup strategy configured (daily automated backups)
- [ ] **(Critical)** Connection pooling configured (PgBouncer or Supabase pooler)
- [ ] **(Recommended)** No sensitive data stored in plain text (passwords, API keys, PII)
- [ ] **(Recommended)** Database can handle expected initial load (load tested if high traffic expected)
- [ ] **(Recommended)** Soft delete implemented for user data (don't permanently delete on day 1)
- [ ] **(Nice-to-have)** Point-in-time recovery enabled
- [ ] **(Nice-to-have)** Read replicas configured for read-heavy workloads

---

## Authentication

- [ ] **(Critical)** Sign up flow works end-to-end (email verification if required)
- [ ] **(Critical)** Login works with all supported methods (email/password, OAuth)
- [ ] **(Critical)** Password reset flow sends email and allows reset
- [ ] **(Critical)** Protected routes redirect unauthenticated users to login
- [ ] **(Critical)** Session expiration and refresh tokens work correctly
- [ ] **(Critical)** OAuth callbacks configured for production URLs (Google, GitHub, etc.)
- [ ] **(Recommended)** Rate limiting on login and signup endpoints
- [ ] **(Recommended)** Account deletion flow works (GDPR compliance)
- [ ] **(Recommended)** Email change flow works with verification
- [ ] **(Nice-to-have)** Two-factor authentication available

---

## Payments

- [ ] **(Critical)** Stripe (or payment provider) uses live mode keys, not test keys
- [ ] **(Critical)** Webhook endpoint configured and verified in production
- [ ] **(Critical)** Subscription creation works (free trial if offered)
- [ ] **(Critical)** Subscription upgrade and downgrade work correctly
- [ ] **(Critical)** Subscription cancellation works (access continues until period end)
- [ ] **(Critical)** Failed payment handling works (dunning emails, grace period)
- [ ] **(Critical)** Prices match what's displayed on the pricing page
- [ ] **(Recommended)** Invoice and receipt emails are sent automatically
- [ ] **(Recommended)** Refund flow tested and documented
- [ ] **(Recommended)** Tax handling configured (Stripe Tax or manual)
- [ ] **(Recommended)** Customer portal accessible for self-service billing management
- [ ] **(Nice-to-have)** Annual billing discount offered and working

---

## SEO

- [ ] **(Critical)** Every page has a unique title tag (50-60 characters)
- [ ] **(Critical)** Every page has a unique meta description (150-160 characters)
- [ ] **(Critical)** Sitemap generated and accessible at `/sitemap.xml`
- [ ] **(Critical)** robots.txt exists and blocks `/app`, `/dashboard`, `/api`
- [ ] **(Critical)** OG images set for homepage, blog posts, and key pages
- [ ] **(Critical)** Canonical URLs set on all pages
- [ ] **(Recommended)** Structured data (JSON-LD) for Organization and SoftwareApplication
- [ ] **(Recommended)** Blog posts have proper heading hierarchy (H1, H2, H3)
- [ ] **(Recommended)** All images have descriptive alt text
- [ ] **(Recommended)** Internal linking between related pages
- [ ] **(Nice-to-have)** FAQ schema on pricing/FAQ pages
- [ ] **(Nice-to-have)** Google Search Console verified and sitemap submitted

---

## Performance

- [ ] **(Critical)** Largest Contentful Paint (LCP) under 2.5 seconds
- [ ] **(Critical)** Interaction to Next Paint (INP) under 200ms
- [ ] **(Critical)** Cumulative Layout Shift (CLS) under 0.1
- [ ] **(Critical)** Images optimized (WebP/AVIF, responsive sizes, lazy loading)
- [ ] **(Recommended)** Fonts loaded with `next/font` (no layout shift)
- [ ] **(Recommended)** Third-party scripts deferred (`strategy="lazyOnload"`)
- [ ] **(Recommended)** Lighthouse performance score above 90
- [ ] **(Recommended)** CDN configured for static assets
- [ ] **(Nice-to-have)** Edge functions for latency-sensitive endpoints
- [ ] **(Nice-to-have)** Service worker for offline support

---

## Security

- [ ] **(Critical)** All environment variables stored securely (not committed to git)
- [ ] **(Critical)** `.env` file in `.gitignore`
- [ ] **(Critical)** HTTPS enforced on all pages (redirect HTTP to HTTPS)
- [ ] **(Critical)** API routes validate and sanitize all input
- [ ] **(Critical)** SQL injection prevented (parameterized queries or ORM)
- [ ] **(Critical)** XSS prevented (no `dangerouslySetInnerHTML` with user input)
- [ ] **(Critical)** CSRF protection on state-changing endpoints
- [ ] **(Recommended)** Security headers configured (CSP, X-Frame-Options, etc.)
- [ ] **(Recommended)** Rate limiting on API endpoints
- [ ] **(Recommended)** File upload validation (type, size, content)
- [ ] **(Recommended)** Dependency audit passed (`npm audit` with no critical/high)
- [ ] **(Nice-to-have)** Penetration test or security audit completed
- [ ] **(Nice-to-have)** Bug bounty program or responsible disclosure page

### Security Headers Checklist

```ts
// next.config.ts headers
const securityHeaders = [
  { key: "X-DNS-Prefetch-Control", value: "on" },
  { key: "Strict-Transport-Security", value: "max-age=63072000; includeSubDomains; preload" },
  { key: "X-Frame-Options", value: "SAMEORIGIN" },
  { key: "X-Content-Type-Options", value: "nosniff" },
  { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
  { key: "Permissions-Policy", value: "camera=(), microphone=(), geolocation=()" },
];
```

---

## Analytics

- [ ] **(Critical)** Analytics tool installed and tracking page views (PostHog, Plausible, etc.)
- [ ] **(Critical)** Sign-up event tracked
- [ ] **(Critical)** Payment/conversion event tracked
- [ ] **(Recommended)** Key feature usage events tracked
- [ ] **(Recommended)** Funnel defined: visit -> signup -> activation -> payment
- [ ] **(Recommended)** Session recording enabled for debugging UX issues
- [ ] **(Recommended)** UTM parameters tracked for marketing attribution
- [ ] **(Nice-to-have)** Dashboard with key metrics (MRR, signups, activation rate)
- [ ] **(Nice-to-have)** Cohort analysis configured
- [ ] **(Nice-to-have)** Custom alerts for anomalies (signup drop, error spike)

### Essential PostHog Events

```tsx
// Track these events at minimum
posthog.capture("user_signed_up", { method: "email" | "google" });
posthog.capture("onboarding_completed", { steps_completed: 3 });
posthog.capture("feature_used", { feature: "dashboard_created" });
posthog.capture("subscription_started", { plan: "pro", interval: "monthly" });
posthog.capture("subscription_cancelled", { reason: "too_expensive" });
```

---

## Legal

- [ ] **(Critical)** Privacy Policy page exists and is linked from footer
- [ ] **(Critical)** Terms of Service page exists and is linked from footer
- [ ] **(Critical)** Cookie consent banner shown (if using cookies/tracking in EU)
- [ ] **(Critical)** GDPR compliance: users can request data export and deletion
- [ ] **(Recommended)** Privacy policy covers: data collected, how it's used, third parties, retention
- [ ] **(Recommended)** Terms cover: acceptable use, liability limits, termination, refunds
- [ ] **(Recommended)** Cookie policy lists all cookies and their purposes
- [ ] **(Nice-to-have)** DPA (Data Processing Agreement) available for enterprise customers
- [ ] **(Nice-to-have)** SOC 2 compliance in progress (for enterprise-focused SaaS)

### Where to Get Legal Templates
- [Termly](https://termly.io) - generates privacy policy and terms
- [Iubenda](https://iubenda.com) - GDPR-compliant cookie consent and policies
- Consult a lawyer for anything beyond standard SaaS terms

---

## Marketing

- [ ] **(Critical)** Landing page is live and communicates value proposition clearly
- [ ] **(Critical)** Pricing page shows plans, features, and pricing
- [ ] **(Critical)** Sign-up flow is accessible from landing page (clear CTA)
- [ ] **(Recommended)** Product Hunt launch drafted (tagline, description, images, first comment)
- [ ] **(Recommended)** Twitter/X account created and has pinned intro tweet
- [ ] **(Recommended)** LinkedIn company page created
- [ ] **(Recommended)** Launch announcement email drafted for mailing list
- [ ] **(Recommended)** 3-5 blog posts published for SEO
- [ ] **(Nice-to-have)** Demo video or product walkthrough recorded
- [ ] **(Nice-to-have)** Press kit with logo, screenshots, and founder bio
- [ ] **(Nice-to-have)** Referral or early adopter program set up

---

## Monitoring

- [ ] **(Critical)** Error tracking installed (Sentry, PostHog, or similar)
- [ ] **(Critical)** Alerts configured for server errors (500s, unhandled exceptions)
- [ ] **(Critical)** Uptime monitoring active (Vercel checks, UptimeRobot, BetterStack)
- [ ] **(Recommended)** API endpoint health checks configured
- [ ] **(Recommended)** Alert notifications go to Slack/email (not just a dashboard)
- [ ] **(Recommended)** Log aggregation for debugging (Vercel logs, Fly.io logs)
- [ ] **(Recommended)** Database monitoring (connection count, query performance)
- [ ] **(Nice-to-have)** Status page for customers (Instatus, BetterStack)
- [ ] **(Nice-to-have)** Automated incident response runbook

### Minimum Monitoring Setup

```
Error tracking:  Sentry or PostHog error tracking
Uptime:          UptimeRobot (free) or BetterStack
Logs:            Platform logs (Vercel/Fly.io built-in)
Alerts:          Slack webhook for critical errors
```

---

## Launch Day Plan

### Timeline

| Time | Action |
|------|--------|
| T-7 days | Final testing, fix any remaining bugs |
| T-3 days | Prepare all marketing assets (tweets, emails, PH listing) |
| T-1 day | Final deploy to production, smoke test all flows |
| T-1 day | Schedule launch tweets and emails |
| Launch morning | Submit Product Hunt (aim for 12:01 AM PT) |
| Launch +1 hour | Post on Twitter/X, LinkedIn, relevant communities |
| Launch +2 hours | Send email to mailing list |
| Launch +4 hours | Engage with comments on PH and social media |
| Launch day | Monitor errors, respond to feedback, fix critical bugs |
| T+1 day | Share results, thank early users, collect feedback |
| T+7 days | Write retrospective, plan next iteration |

### Launch Day Channels

| Channel | Action | Timing |
|---------|--------|--------|
| Product Hunt | Submit listing | 12:01 AM PT |
| Twitter/X | Launch thread (5-7 tweets) | Morning |
| LinkedIn | Launch post | Morning |
| Hacker News | Show HN post | Morning |
| Reddit | Post in relevant subreddits | Morning |
| Indie Hackers | Share in relevant groups | Morning |
| Email list | Send launch announcement | Mid-morning |
| Discord/Slack communities | Share in relevant channels | Throughout day |

### Launch Day Monitoring Checklist

- [ ] Watch error tracking dashboard for new errors
- [ ] Monitor server metrics (CPU, memory, response times)
- [ ] Check payment webhook logs for failed events
- [ ] Respond to all Product Hunt comments within 1 hour
- [ ] Track signup numbers in real-time
- [ ] Have a rollback plan if critical bugs are found
- [ ] Keep a shared doc of bugs and feedback received

---

## Post-Launch (First 7 Days)

- [ ] Fix any bugs reported on launch day
- [ ] Reach out to every new user personally (email or in-app message)
- [ ] Collect and organize user feedback
- [ ] Write a "what we learned" post
- [ ] Set up a feedback collection system (feature requests, bug reports)
- [ ] Review analytics: conversion funnel, drop-off points
- [ ] Plan the next 2-week sprint based on user feedback
- [ ] Thank everyone who helped with launch
- [ ] Update Product Hunt listing with any new info
- [ ] Schedule a retrospective meeting

---

## Quick Pre-Launch Smoke Test

Run through these 10 critical flows manually before launch:

1. **Visit landing page** - loads fast, looks correct, CTA works
2. **Sign up** - create a new account successfully
3. **Verify email** - confirmation email arrives, link works
4. **Complete onboarding** - first-run experience works
5. **Use core feature** - the main thing your product does works
6. **Upgrade to paid** - payment flow completes, access granted
7. **Manage billing** - can view invoices, update payment method
8. **Reset password** - email arrives, can set new password
9. **Mobile experience** - all flows work on a real phone
10. **Invite team member** - if applicable, invitation flow works
