---
name: deploy
description: Deploy to Vercel with pre-flight checks, environment configuration, and post-deployment verification. Use for: production deployment, shipping, going live, custom domains. Triggers on "deploy this", "ship it to production", "push to Vercel", "go live".
---

# deploy

Deploy to Vercel with pre-flight checks, environment configuration, and post-deployment verification. Use when deploying a project, pushing to production, shipping, going live, setting up Vercel, configuring a custom domain, or saying "deploy this", "ship it to production".

---

## Quick Reference

| Step | What | Tool |
|------|------|------|
| 1 | Pre-flight checks | Local CLI |
| 2 | GitHub repo | `gh` CLI |
| 3 | Vercel project | `vercel` CLI |
| 4 | Environment variables | Vercel dashboard or CLI |
| 5 | Custom domain | Vercel CLI |
| 6 | Post-deploy verification | Browser + Lighthouse |

---

## Step 1 - Pre-Deployment Build Validation

Run these checks before deploying anything:

```bash
# 1. TypeScript type check
pnpm tsc --noEmit

# 2. Lint check
pnpm lint

# 3. Production build
pnpm build

# 4. Check for .env leaks in committed files
git log --all -p | grep -i "sk_live\|secret_key\|password=" || echo "No secrets found"

# 5. Verify .gitignore covers sensitive files
cat .gitignore | grep -E "\.env|node_modules|\.next"
```

### Pre-Flight Checklist

- [ ] `pnpm build` succeeds with no errors
- [ ] `pnpm tsc --noEmit` passes
- [ ] `pnpm lint` passes
- [ ] No secrets committed to git history
- [ ] `.env.local` is in `.gitignore`
- [ ] All API keys use environment variables (no hardcoded values)
- [ ] Database migrations are up to date
- [ ] Supabase cloud project has matching schema

---

## Step 2 - GitHub Repository

### Create the repo with gh CLI

```bash
# Public repo
gh repo create my-saas --public --source=. --remote=origin --push

# Private repo (recommended for SaaS)
gh repo create my-saas --private --source=. --remote=origin --push
```

If the repo already exists, just push:

```bash
git remote add origin https://github.com/USERNAME/my-saas.git
git push -u origin main
```

### Branch Protection (recommended)

```bash
gh api repos/OWNER/REPO/branches/main/protection -X PUT \
  -f "required_pull_request_reviews[required_approving_review_count]=1" \
  -F "enforce_admins=true" \
  -F "required_status_checks=null" \
  -F "restrictions=null"
```

---

## Step 3 - Vercel Project Setup

### Install Vercel CLI

```bash
pnpm add -g vercel
```

### Link and Deploy

```bash
# Link to Vercel (follow prompts)
vercel link

# First deploy (preview)
vercel

# Production deploy
vercel --prod
```

### vercel.json Configuration (optional)

Create `vercel.json` at the project root if you need custom settings:

```json
{
  "framework": "nextjs",
  "buildCommand": "pnpm build",
  "installCommand": "pnpm install",
  "regions": ["iad1"],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Frame-Options", "value": "DENY" },
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "Referrer-Policy", "value": "strict-origin-when-cross-origin" }
      ]
    }
  ]
}
```

---

## Step 4 - Environment Variables

### Via CLI

```bash
# Add each variable
vercel env add NEXT_PUBLIC_SUPABASE_URL production
vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY production
vercel env add SUPABASE_SERVICE_ROLE_KEY production
vercel env add STRIPE_SECRET_KEY production
vercel env add STRIPE_WEBHOOK_SECRET production
vercel env add NEXT_PUBLIC_POSTHOG_KEY production

# Add for preview environments too
vercel env add NEXT_PUBLIC_SUPABASE_URL preview
vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY preview
```

### Required Variables for a Typical SaaS

| Variable | Scope | Notes |
|----------|-------|-------|
| `NEXT_PUBLIC_SUPABASE_URL` | Production + Preview | Cloud project URL |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Production + Preview | Public anon key |
| `SUPABASE_SERVICE_ROLE_KEY` | Production only | Never expose to client |
| `NEXT_PUBLIC_APP_URL` | Production | Your domain (e.g., https://app.example.com) |
| `STRIPE_SECRET_KEY` | Production | Use `sk_live_` for prod |
| `STRIPE_WEBHOOK_SECRET` | Production | From Stripe dashboard |
| `NEXT_PUBLIC_POSTHOG_KEY` | Production + Preview | PostHog project key |

### Verify Variables Are Set

```bash
vercel env ls
```

---

## Step 5 - Custom Domain

### Add Domain via CLI

```bash
# Add your domain
vercel domains add app.example.com

# Check DNS configuration instructions
vercel domains inspect app.example.com
```

### DNS Records to Set

| Type | Name | Value |
|------|------|-------|
| CNAME | app | cname.vercel-dns.com |
| A | @ | 76.76.21.21 (if apex domain) |

For apex domains (no subdomain), use Vercel's recommended approach:

```bash
# Add apex domain
vercel domains add example.com

# Vercel will provide specific A records
```

### SSL

Vercel automatically provisions SSL certificates. No action needed - just wait a few minutes after DNS propagation.

---

## Step 6 - Post-Deployment Verification

### Automated Checks

```bash
# Check deployment status
vercel ls --prod

# Get production URL
vercel inspect --prod
```

### Manual Verification Checklist

- [ ] Homepage loads correctly
- [ ] Login/signup flow works
- [ ] Auth callback redirects properly
- [ ] Dashboard loads for authenticated users
- [ ] Unauthenticated users are redirected to login
- [ ] API routes respond correctly
- [ ] Stripe webhook endpoint is reachable (if applicable)
- [ ] Images and static assets load
- [ ] No console errors in browser devtools
- [ ] Mobile responsive layout works

### Core Web Vitals Check

```bash
# Quick Lighthouse audit (requires Chrome)
npx lighthouse https://app.example.com --output=json --quiet | \
  jq '.categories.performance.score, .audits["largest-contentful-paint"].numericValue'
```

Target scores:

| Metric | Good | Needs Work | Poor |
|--------|------|------------|------|
| LCP | < 2.5s | 2.5-4s | > 4s |
| FID | < 100ms | 100-300ms | > 300ms |
| CLS | < 0.1 | 0.1-0.25 | > 0.25 |

---

## Step 7 - Preview Deployments

Every push to a non-production branch creates a preview deployment automatically.

### Managing Preview Deployments

```bash
# List recent deployments
vercel ls

# Inspect a specific deployment
vercel inspect <deployment-url>

# Promote a preview to production
vercel promote <deployment-url>
```

### Preview Environment Best Practices

- Use separate Supabase project or branch for preview environments
- Set preview-specific env vars: `vercel env add VAR_NAME preview`
- Share preview URLs with stakeholders for review before merging

---

## Step 8 - Rollback Procedure

If something goes wrong after deploying to production:

### Quick Rollback

```bash
# List recent production deployments
vercel ls --prod

# Rollback to a previous deployment
vercel rollback
```

### Manual Rollback

```bash
# Find the last working deployment URL
vercel ls --prod

# Promote it back to production
vercel promote <last-working-deployment-url>
```

### Git-Based Rollback

```bash
# Revert the problematic commit
git revert HEAD
git push origin main
# Vercel will auto-deploy the revert
```

---

## Step 9 - CI/CD with GitHub Actions (Optional)

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Vercel

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v4
        with:
          version: 9

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm

      - run: pnpm install --frozen-lockfile
      - run: pnpm tsc --noEmit
      - run: pnpm lint
      - run: pnpm build

      - name: Deploy to Vercel
        if: github.ref == 'refs/heads/main'
        run: vercel --prod --token=${{ secrets.VERCEL_TOKEN }}
        env:
          VERCEL_ORG_ID: ${{ secrets.VERCEL_ORG_ID }}
          VERCEL_PROJECT_ID: ${{ secrets.VERCEL_PROJECT_ID }}
```

---

## Deployment Checklist (Full)

### Before First Deploy
- [ ] GitHub repo created (private recommended)
- [ ] Vercel project linked
- [ ] All env vars set for production scope
- [ ] Supabase cloud project schema matches local
- [ ] Custom domain added and DNS configured
- [ ] SSL certificate provisioned

### Every Deploy
- [ ] Build passes locally (`pnpm build`)
- [ ] Type check passes (`pnpm tsc --noEmit`)
- [ ] No new lint errors
- [ ] Tested critical paths locally
- [ ] Commit pushed to main (or PR merged)
- [ ] Deployment succeeded on Vercel dashboard
- [ ] Post-deploy verification passed
- [ ] Core Web Vitals within acceptable range

### After Deploy
- [ ] Smoke test critical user flows
- [ ] Check error monitoring (if set up)
- [ ] Verify analytics events fire correctly
- [ ] Confirm webhook endpoints respond
- [ ] Monitor logs for first 15 minutes

---

## Common Issues

| Problem | Solution |
|---------|----------|
| Build fails on Vercel but works locally | Check Node.js version matches, verify all env vars are set |
| 404 on dynamic routes | Ensure route segments use correct file naming (`[id]/page.tsx`) |
| Environment variables undefined | Verify scope (production vs preview), redeploy after adding vars |
| Domain not resolving | Check DNS propagation (use `dig` or https://dnschecker.org) |
| Middleware not running | Verify `matcher` config, check Vercel region supports Edge Runtime |
| Build timeout | Optimize build, check for large dependencies, consider `--max-old-space-size` |
