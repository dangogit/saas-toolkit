---
name: secure
description: Security checklist and hardening for SaaS apps built with Next.js and Supabase before going live. Use for: security audits, app hardening, auth review, vulnerability checks. Triggers on "security audit", "is this secure", "pre-launch checklist", "harden my app".
---

# secure

Security checklist and hardening for SaaS apps built with Next.js + Supabase before going live. Use when auditing security, hardening an app, preparing for launch, reviewing auth, checking for vulnerabilities, or saying "security audit", "is this secure", "pre-launch checklist", "harden my app".

---

## OWASP Top 10 - Quick Reference for Next.js + Supabase

| # | Risk | Next.js/Supabase Impact | Key Defense |
|---|------|-------------------------|-------------|
| A01 | Broken Access Control | Missing RLS policies, unprotected API routes | RLS on every table, middleware auth checks |
| A02 | Cryptographic Failures | Exposed API keys, weak token storage | Env vars, httpOnly cookies |
| A03 | Injection | SQL injection via raw queries, XSS via dangerouslySetInnerHTML | Parameterized queries (Supabase client handles this), sanitize user input |
| A04 | Insecure Design | No rate limiting, missing input validation | Zod validation, rate limiting |
| A05 | Security Misconfiguration | Default Supabase settings, missing headers | Security headers, disable unused features |
| A06 | Vulnerable Components | Outdated npm packages | Regular `npm audit`, Snyk scans |
| A07 | Auth Failures | Weak password policy, no MFA | Supabase Auth defaults + custom policies |
| A08 | Data Integrity Failures | Unverified webhooks, unsigned data | Verify webhook signatures |
| A09 | Logging Failures | No audit trail | Log auth events, track anomalies |
| A10 | SSRF | Unvalidated URLs in server-side fetches | Validate and allowlist external URLs |

---

## Authentication Security

### Session Handling

```typescript
// GOOD: Supabase SSR handles session via httpOnly cookies
import { createServerClient } from "@supabase/ssr";

// GOOD: Always verify the user server-side
export async function getAuthenticatedUser() {
  const supabase = await createClient();
  const { data: { user }, error } = await supabase.auth.getUser();

  if (error || !user) {
    throw new Error("Unauthorized");
  }

  return user;
}
```

### Auth Best Practices

| Do | Do Not |
|----|--------|
| Use `supabase.auth.getUser()` for server-side verification | Use `supabase.auth.getSession()` for auth checks (session can be spoofed) |
| Store sessions in httpOnly cookies (Supabase SSR default) | Store tokens in localStorage |
| Implement refresh token rotation (Supabase does this automatically) | Roll your own JWT handling |
| Set password minimum length to 8+ characters | Allow passwords under 8 characters |
| Use PKCE flow for OAuth (Supabase default) | Use implicit OAuth flow |

### Password Policy

Configure in Supabase Dashboard - Authentication - Policies:

- Minimum length: 8 characters
- Require at least one uppercase, one number
- Enable leaked password detection (if available)

### Multi-Factor Authentication (MFA)

```typescript
// Enroll MFA
const { data, error } = await supabase.auth.mfa.enroll({
  factorType: "totp",
  friendlyName: "Authenticator App",
});

// Verify MFA
const { data: challengeData } = await supabase.auth.mfa.challenge({
  factorId: factor.id,
});

const { data: verifyData } = await supabase.auth.mfa.verify({
  factorId: factor.id,
  challengeId: challengeData.id,
  code: userProvidedCode,
});
```

---

## Authorization Patterns

### Role-Based Access Control (RBAC)

```sql
-- Roles stored in team_members table
create table public.team_members (
  id uuid default uuid_generate_v4() primary key,
  team_id uuid references public.teams on delete cascade not null,
  user_id uuid references auth.users on delete cascade not null,
  role text not null check (role in ('owner', 'admin', 'member', 'viewer')),
  unique(team_id, user_id)
);

-- RLS policy using role
create policy "admins_can_delete"
  on public.resources for delete
  using (
    exists (
      select 1 from public.team_members
      where team_id = resources.team_id
      and user_id = auth.uid()
      and role in ('owner', 'admin')
    )
  );
```

### Permission Check Helper (Server-Side)

```typescript
type Role = "owner" | "admin" | "member" | "viewer";

const ROLE_HIERARCHY: Record<Role, number> = {
  viewer: 0,
  member: 1,
  admin: 2,
  owner: 3,
};

export async function requireRole(teamId: string, minimumRole: Role) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) throw new Error("Unauthorized");

  const { data: membership } = await supabase
    .from("team_members")
    .select("role")
    .eq("team_id", teamId)
    .eq("user_id", user.id)
    .single();

  if (!membership || ROLE_HIERARCHY[membership.role as Role] < ROLE_HIERARCHY[minimumRole]) {
    throw new Error("Forbidden");
  }

  return user;
}
```

---

## Input Validation and Sanitization

### Validate All Inputs with Zod

```typescript
import { z } from "zod";

// Define schema
const createTeamSchema = z.object({
  name: z.string().min(2).max(100).trim(),
  slug: z.string().min(2).max(50).regex(/^[a-z0-9-]+$/),
});

// Use in route handler
export async function POST(request: Request) {
  const body = await request.json();
  const result = createTeamSchema.safeParse(body);

  if (!result.success) {
    return NextResponse.json(
      { error: "Validation failed", details: result.error.flatten() },
      { status: 400 }
    );
  }

  // Use result.data (typed and validated)
  const { name, slug } = result.data;
}
```

### XSS Prevention

```typescript
// NEVER do this
<div dangerouslySetInnerHTML={{ __html: userInput }} />

// If you must render HTML, sanitize first
import DOMPurify from "isomorphic-dompurify";
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userInput) }} />

// Better: use a markdown renderer with sanitization
import ReactMarkdown from "react-markdown";
<ReactMarkdown>{userInput}</ReactMarkdown>
```

---

## API Route Protection

### Protect Every Route Handler

```typescript
import { createClient } from "@/lib/supabase/server";
import { NextResponse } from "next/server";

export async function POST(request: Request) {
  // 1. Authenticate
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  // 2. Validate input
  const body = await request.json();
  const parsed = schema.safeParse(body);
  if (!parsed.success) {
    return NextResponse.json({ error: "Invalid input" }, { status: 400 });
  }

  // 3. Authorize (check permissions)
  const { data: membership } = await supabase
    .from("team_members")
    .select("role")
    .eq("team_id", parsed.data.teamId)
    .eq("user_id", user.id)
    .single();

  if (!membership) {
    return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  }

  // 4. Execute business logic
  // ...
}
```

### API Route Security Checklist

- [ ] Every route checks authentication
- [ ] Every mutation validates input with Zod
- [ ] Authorization verified (user has permission for this resource)
- [ ] Error responses do not leak internal details
- [ ] File uploads validate type and size

---

## Environment Variable Security

### Rules

| Rule | Example |
|------|---------|
| Never commit `.env.local` | Add to `.gitignore` |
| Prefix public vars with `NEXT_PUBLIC_` | `NEXT_PUBLIC_SUPABASE_URL` |
| Never prefix secrets with `NEXT_PUBLIC_` | `SUPABASE_SERVICE_ROLE_KEY` (no prefix) |
| Use different keys per environment | Separate dev/staging/prod Stripe keys |
| Rotate keys if exposed | Regenerate in provider dashboard immediately |

### Audit for Leaked Secrets

```bash
# Check if any secrets are in git history
git log --all --diff-filter=A -- "*.env*"

# Search for common secret patterns
grep -rn "sk_live\|sk_test\|password\|secret" --include="*.ts" --include="*.tsx" src/

# Use git-secrets or similar tools
# brew install git-secrets
# git secrets --scan
```

---

## CORS Configuration

### Next.js API Route CORS

```typescript
// src/app/api/public/route.ts
import { NextResponse } from "next/server";

const ALLOWED_ORIGINS = [
  "https://app.example.com",
  "https://www.example.com",
];

export async function OPTIONS(request: Request) {
  const origin = request.headers.get("origin") ?? "";
  const isAllowed = ALLOWED_ORIGINS.includes(origin);

  return new NextResponse(null, {
    status: 204,
    headers: {
      "Access-Control-Allow-Origin": isAllowed ? origin : "",
      "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type, Authorization",
      "Access-Control-Max-Age": "86400",
    },
  });
}
```

---

## Rate Limiting

### Using Vercel KV or Upstash Redis

```typescript
import { Ratelimit } from "@upstash/ratelimit";
import { Redis } from "@upstash/redis";

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, "10 s"), // 10 requests per 10 seconds
  analytics: true,
});

export async function POST(request: Request) {
  const ip = request.headers.get("x-forwarded-for") ?? "127.0.0.1";
  const { success, limit, remaining, reset } = await ratelimit.limit(ip);

  if (!success) {
    return NextResponse.json(
      { error: "Rate limit exceeded" },
      {
        status: 429,
        headers: {
          "X-RateLimit-Limit": limit.toString(),
          "X-RateLimit-Remaining": remaining.toString(),
          "X-RateLimit-Reset": reset.toString(),
        },
      }
    );
  }

  // Continue with request...
}
```

### Rate Limit Recommendations

| Endpoint Type | Limit |
|---------------|-------|
| Login/signup | 5 requests per minute per IP |
| API mutations | 30 requests per minute per user |
| API reads | 100 requests per minute per user |
| Webhook receivers | 100 requests per minute per source |
| File uploads | 10 requests per minute per user |

---

## Security Headers

### Next.js Configuration (`next.config.ts`)

```typescript
const securityHeaders = [
  { key: "X-DNS-Prefetch-Control", value: "on" },
  { key: "Strict-Transport-Security", value: "max-age=63072000; includeSubDomains; preload" },
  { key: "X-Frame-Options", value: "DENY" },
  { key: "X-Content-Type-Options", value: "nosniff" },
  { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
  { key: "Permissions-Policy", value: "camera=(), microphone=(), geolocation=()" },
];

const nextConfig = {
  async headers() {
    return [
      {
        source: "/(.*)",
        headers: securityHeaders,
      },
    ];
  },
};

export default nextConfig;
```

### Content Security Policy (CSP)

```typescript
// In next.config.ts headers or middleware
const cspHeader = `
  default-src 'self';
  script-src 'self' 'unsafe-eval' 'unsafe-inline' https://us.i.posthog.com;
  style-src 'self' 'unsafe-inline';
  img-src 'self' blob: data: https://*.supabase.co;
  font-src 'self';
  connect-src 'self' https://*.supabase.co https://us.i.posthog.com;
  frame-ancestors 'none';
  form-action 'self';
  base-uri 'self';
`.replace(/\n/g, "");
```

Add PostHog, Supabase, Stripe, and any other third-party domains to the appropriate CSP directives.

---

## Dependency Vulnerability Scanning

### npm audit

```bash
# Check for vulnerabilities
pnpm audit

# Fix automatically where possible
pnpm audit --fix

# Check production dependencies only
pnpm audit --prod
```

### Snyk (recommended)

```bash
# Install Snyk CLI
npm install -g snyk

# Test for vulnerabilities
snyk test

# Monitor continuously
snyk monitor
```

### Automated Scanning

Set up Dependabot or Snyk in your GitHub repo:

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
```

---

## Webhook Security

### Verify Stripe Webhook Signatures

```typescript
import Stripe from "stripe";

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);

export async function POST(request: Request) {
  const body = await request.text();
  const signature = request.headers.get("stripe-signature")!;

  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET!
    );
  } catch (err) {
    console.error("Webhook signature verification failed");
    return new Response("Invalid signature", { status: 400 });
  }

  // Process verified event
  switch (event.type) {
    case "checkout.session.completed":
      // Handle checkout
      break;
  }

  return new Response("OK");
}
```

---

## Pre-Launch Security Checklist

### Authentication and Authorization
- [ ] All API routes require authentication
- [ ] RLS enabled on every Supabase table
- [ ] RLS policies tested (can user A access user B's data?)
- [ ] Password policy enforced (min 8 chars)
- [ ] OAuth callback URLs restricted to your domain
- [ ] MFA available for user accounts (optional but recommended)

### Data Protection
- [ ] No secrets in git history
- [ ] Environment variables properly scoped (no `NEXT_PUBLIC_` prefix on secrets)
- [ ] Service role key only used server-side
- [ ] User inputs validated with Zod
- [ ] File uploads validated (type, size, content)

### Infrastructure
- [ ] Security headers configured (HSTS, X-Frame-Options, CSP)
- [ ] CORS restricted to known origins
- [ ] Rate limiting on auth and API endpoints
- [ ] SSL/TLS enforced (Vercel handles this)
- [ ] Dependencies scanned for vulnerabilities

### Monitoring
- [ ] Auth failures logged
- [ ] Rate limit violations logged
- [ ] Error monitoring set up (Sentry or similar)
- [ ] Webhook failures alerted

### Compliance
- [ ] Privacy policy page published
- [ ] Cookie consent banner (if required by jurisdiction)
- [ ] Data deletion endpoint available
- [ ] Terms of service published
- [ ] Stripe webhook signatures verified

---

## Common Vulnerabilities by Component

| Component | Vulnerability | Fix |
|-----------|---------------|-----|
| Next.js Server Actions | CSRF without proper validation | Use Supabase auth tokens, validate origin |
| Supabase client | Exposing service role key | Never use `NEXT_PUBLIC_` prefix for service role |
| API routes | Missing auth check | Always call `getUser()` first |
| File uploads | Malicious file types | Validate MIME type and extension server-side |
| Redirects | Open redirect attacks | Validate redirect URLs against allowlist |
| Error messages | Information leakage | Return generic errors to client, log details server-side |
| Search/filters | SQL injection via raw queries | Always use parameterized queries (Supabase client does this) |
