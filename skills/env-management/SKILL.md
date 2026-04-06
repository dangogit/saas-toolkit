---
name: env-management
description: Environment management patterns for SaaS projects - local development, staging, and production. Covers .env files, environment variables, and safe configuration switching. Use when setting up environments, managing secrets, or deploying to different stages.
---

# Environment Management

## The Three Environments

| Environment | Purpose | Who sees it | Data |
|-------------|---------|------------|------|
| **Local** | Development on your machine | Only you | Fake/seed data |
| **Staging** | Test before going live | You + testers | Test data |
| **Production** | Real users, real money | Everyone | Real data |

## .env File Pattern

### File naming convention

```
.env.local          # Local development (git-ignored, never committed)
.env.staging        # Staging values (can be committed if no secrets)
.env.production     # Production values (NEVER committed)
.env.example        # Template with empty values (committed, helps new developers)
```

### .env.example template

```bash
# Database
DATABASE_URL=
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=

# Auth
NEXTAUTH_SECRET=
NEXTAUTH_URL=

# Payments
POLAR_ACCESS_TOKEN=
POLAR_WEBHOOK_SECRET=

# Email
RESEND_API_KEY=

# Analytics
NEXT_PUBLIC_POSTHOG_KEY=
NEXT_PUBLIC_POSTHOG_HOST=

# AI
GOOGLE_GENERATIVE_AI_API_KEY=
```

## Key Rules

### What goes in environment variables
- API keys and secrets
- Database connection strings
- Service URLs that change per environment
- Feature flags

### What does NOT go in environment variables
- Code logic
- UI text
- Constants that never change

### NEXT_PUBLIC_ prefix (Next.js)
- Variables starting with `NEXT_PUBLIC_` are visible in the browser
- **Never** put secrets in `NEXT_PUBLIC_` variables
- OK: `NEXT_PUBLIC_POSTHOG_KEY` (analytics, meant to be public)
- NOT OK: `NEXT_PUBLIC_SUPABASE_SERVICE_ROLE_KEY` (secret!)

## Environment-Specific Configuration

### Supabase

```
Local:      supabase start (runs locally on port 54321)
Staging:    Separate Supabase project (staging-myapp)
Production: Separate Supabase project (prod-myapp)
```

### Vercel

```
Local:      vercel dev (pulls env vars from Vercel)
Staging:    Preview deployments (automatic on PR push)
Production: Production deployment (on merge to main)
```

### Payments (Polar.sh)

```
Local:      Polar.sh sandbox mode (test API key)
Staging:    Polar.sh sandbox mode (same test API key)
Production: Polar.sh live mode (real API key, real money)
```

### Email (Resend)

```
Local:      Resend test API key (emails only go to you)
Staging:    Resend test API key (emails only go to you)
Production: Resend live API key + verified domain (real recipients)
```

## Switching Environments

### Vercel CLI approach (recommended)
```bash
# Pull env vars for different environments
vercel env pull .env.local              # Development
vercel env pull .env.staging --environment preview
vercel env pull .env.production --environment production
```

### Manual approach
```bash
# Copy the right env file
cp .env.staging .env.local
# Edit as needed
```

## Safety Checklist

- [ ] `.env.local` is in `.gitignore`
- [ ] `.env.production` is in `.gitignore`
- [ ] No secrets in `NEXT_PUBLIC_` variables
- [ ] `.env.example` exists with empty values
- [ ] Production API keys are ONLY in Vercel dashboard, never in files
- [ ] Staging uses separate Supabase/Firebase project from production
