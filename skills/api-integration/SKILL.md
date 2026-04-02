---
name: api-integration
description: Connect payment providers and third-party APIs to your Next.js SaaS app. Use for Polar.sh integration, LemonSqueezy, webhooks, payments, subscriptions, email services. Triggers on "add payments", "connect API", "set up billing", "webhook handler", "integrate Polar", "integrate email".
---

# api-integration

Connect payment providers and third-party APIs to your Next.js SaaS app. Use when integrating Polar.sh, adding webhooks, connecting APIs, setting up billing, handling subscriptions, or saying "add payments", "connect API", "set up billing", "webhook handler", "integrate Polar", "integrate email".

---

## Quick Reference - Common SaaS Integrations

| Service | Purpose | Package |
|---------|---------|---------|
| Polar.sh | Payments, subscriptions, billing (MoR) | `@polar-sh/sdk`, `@polar-sh/nextjs` |
| LemonSqueezy | Payments (MoR alternative) | `@lemonsqueezy/lemonsqueezy.js` |
| Resend | Transactional email | `resend` |
| PostHog | Analytics, feature flags | `posthog-js`, `posthog-node` |
| Upstash Redis | Rate limiting, caching | `@upstash/redis`, `@upstash/ratelimit` |
| Sentry | Error monitoring | `@sentry/nextjs` |

---

## Polar.sh Integration (Primary Payment Provider)

### What is Polar?

Polar is a **Merchant of Record** (MoR) for developers. This means Polar handles:

- Sales tax collection and remittance worldwide
- Billing and invoicing
- Hosted customer portal (no need to build one)
- Subscription lifecycle management
- Refunds and disputes

You sell through Polar, not directly. Polar is the legal seller, handles compliance, and pays you out. This eliminates the need to manage tax registrations, VAT, or complex billing logic yourself.

### Installation

```bash
pnpm add @polar-sh/sdk @polar-sh/nextjs
```

### Environment Variables

```env
POLAR_ACCESS_TOKEN=polar_at_...
POLAR_WEBHOOK_SECRET=polar_whs_...
```

| Variable | Where to Get It | Notes |
|----------|----------------|-------|
| `POLAR_ACCESS_TOKEN` | Polar Dashboard > Settings > API Keys | Server-only, never expose to client |
| `POLAR_WEBHOOK_SECRET` | Polar Dashboard > Settings > Webhooks | Generated when you create a webhook endpoint |

### Sandbox vs Production

| Environment | API Base URL | Dashboard |
|-------------|-------------|-----------|
| Sandbox (testing) | `https://sandbox-api.polar.sh` | `https://sandbox.polar.sh` |
| Production | `https://api.polar.sh` | `https://polar.sh` |

Use sandbox for development. Create separate access tokens and webhook secrets for each environment. The `@polar-sh/nextjs` helpers accept a `server` parameter: `"sandbox"` or `"production"` (default).

### SDK Client Initialization (`src/lib/polar.ts`)

```typescript
import { Polar } from "@polar-sh/sdk";

export const polar = new Polar({
  accessToken: process.env.POLAR_ACCESS_TOKEN!,
  // For sandbox testing, uncomment the next line:
  // server: "sandbox",
});
```

### Key SDK Namespaces

| Namespace | Purpose | Example |
|-----------|---------|---------|
| `polar.checkouts` | Create and manage checkout sessions | `polar.checkouts.create(...)` |
| `polar.subscriptions` | List, get, update, cancel subscriptions | `polar.subscriptions.list(...)` |
| `polar.products` | List and manage products | `polar.products.list(...)` |
| `polar.customers` | Customer management and export | `polar.customers.get(...)` |
| `polar.orders` | Query orders and payment history | `polar.orders.list(...)` |

---

### Checkout Flow - Using `@polar-sh/nextjs` (Simple)

The easiest way to create a checkout. The `Checkout` helper returns a route handler that redirects the user to Polar's hosted checkout page.

```typescript
// src/app/api/checkout/route.ts
import { Checkout } from "@polar-sh/nextjs";

export const GET = Checkout({
  accessToken: process.env.POLAR_ACCESS_TOKEN!,
  successUrl: `${process.env.NEXT_PUBLIC_APP_URL}/dashboard?checkout=success`,
  returnUrl: `${process.env.NEXT_PUBLIC_APP_URL}/pricing`,
  server: "sandbox", // Remove or set to "production" for live
});
```

Link to it from your pricing page with the product ID as a query parameter:

```tsx
<a href="/api/checkout?productId=prod_xxx">Subscribe to Pro</a>
```

### Checkout Flow - Using SDK Directly (More Control)

Use the SDK directly when you need to attach metadata, set customer info, or customize the checkout.

```typescript
// src/app/api/checkout/route.ts
import { polar } from "@/lib/polar";
import { createClient } from "@/lib/supabase/server";
import { NextResponse } from "next/server";

export async function POST(request: Request) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const { productId } = await request.json();

  const checkout = await polar.checkouts.create({
    products: [productId],
    customerEmail: user.email!,
    customerName: user.user_metadata?.full_name,
    metadata: {
      supabase_user_id: user.id,
    },
    successUrl: `${process.env.NEXT_PUBLIC_APP_URL}/dashboard?checkout=success`,
  });

  return NextResponse.json({ url: checkout.url });
}
```

Client-side button:

```tsx
"use client";

export function CheckoutButton({ productId }: { productId: string }) {
  const handleCheckout = async () => {
    const response = await fetch("/api/checkout", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ productId }),
    });

    const { url } = await response.json();
    window.location.href = url;
  };

  return <button onClick={handleCheckout}>Subscribe</button>;
}
```

---

### Webhook Handling - Using `@polar-sh/nextjs` Webhooks Helper

The `Webhooks` helper from `@polar-sh/nextjs` handles signature verification automatically and provides typed event handlers. This is the recommended approach for Next.js apps.

```typescript
// src/app/api/webhook/polar/route.ts
import { Webhooks } from "@polar-sh/nextjs";
import { createClient } from "@supabase/supabase-js";

// Use service role for webhook handlers (no user context)
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

export const POST = Webhooks({
  webhookSecret: process.env.POLAR_WEBHOOK_SECRET!,

  // Catch-all handler for any event
  onPayload: async (payload) => {
    console.log("Received webhook:", payload.type);
  },

  // Subscription lifecycle
  onSubscriptionCreated: async (payload) => {
    const sub = payload.data;
    await supabase.from("subscriptions").insert({
      polar_subscription_id: sub.id,
      polar_customer_id: sub.customerId,
      polar_product_id: sub.productId,
      status: sub.status,
      user_id: sub.metadata?.supabase_user_id,
      current_period_start: sub.currentPeriodStart,
      current_period_end: sub.currentPeriodEnd,
    });
  },

  onSubscriptionActive: async (payload) => {
    const sub = payload.data;
    await supabase
      .from("subscriptions")
      .update({
        status: "active",
        current_period_start: sub.currentPeriodStart,
        current_period_end: sub.currentPeriodEnd,
      })
      .eq("polar_subscription_id", sub.id);
  },

  onSubscriptionCanceled: async (payload) => {
    const sub = payload.data;
    await supabase
      .from("subscriptions")
      .update({
        status: "canceled",
        cancel_at_period_end: true,
      })
      .eq("polar_subscription_id", sub.id);
  },

  onSubscriptionRevoked: async (payload) => {
    const sub = payload.data;
    await supabase
      .from("subscriptions")
      .update({ status: "revoked" })
      .eq("polar_subscription_id", sub.id);

    // Downgrade user access
    if (sub.metadata?.supabase_user_id) {
      await supabase
        .from("profiles")
        .update({ plan: "free" })
        .eq("id", sub.metadata.supabase_user_id);
    }
  },

  // Order events
  onOrderCreated: async (payload) => {
    console.log("New order:", payload.data.id);
  },

  onOrderPaid: async (payload) => {
    const order = payload.data;
    await supabase.from("orders").insert({
      polar_order_id: order.id,
      polar_customer_id: order.customerId,
      amount: order.amount,
      currency: order.currency,
      user_id: order.metadata?.supabase_user_id,
    });
  },

  // Customer events
  onCustomerCreated: async (payload) => {
    const customer = payload.data;
    console.log("New customer:", customer.email);
  },

  onCustomerStateChanged: async (payload) => {
    const customer = payload.data;
    // Update local customer record with latest state
    await supabase
      .from("customers")
      .upsert({
        polar_customer_id: customer.id,
        email: customer.email,
        name: customer.name,
      })
      .eq("polar_customer_id", customer.id);
  },

  // Benefit events
  onBenefitGrantCreated: async (payload) => {
    const grant = payload.data;
    console.log("Benefit granted:", grant.benefitId, "to customer:", grant.customerId);
  },

  onBenefitGrantRevoked: async (payload) => {
    const grant = payload.data;
    console.log("Benefit revoked:", grant.benefitId, "from customer:", grant.customerId);
  },
});
```

### Webhook Handling - Using SDK Directly (Non-Next.js)

For Express.js or other Node frameworks, use `validateEvent` from the SDK:

```typescript
import { validateEvent, WebhookVerificationError } from "@polar-sh/sdk/webhooks";

app.post("/webhooks/polar", express.raw({ type: "application/json" }), (req, res) => {
  try {
    const event = validateEvent(
      req.body,
      req.headers,
      process.env.POLAR_WEBHOOK_SECRET!
    );

    switch (event.type) {
      case "subscription.created":
        console.log("New subscription:", event.data.id);
        break;
      case "subscription.canceled":
        console.log("Subscription canceled:", event.data.id);
        break;
      case "order.paid":
        console.log("Order paid:", event.data.id);
        break;
    }

    res.status(202).send("");
  } catch (error) {
    if (error instanceof WebhookVerificationError) {
      res.status(403).send("");
      return;
    }
    throw error;
  }
});
```

### Available Webhook Event Types

| Event | When It Fires |
|-------|--------------|
| `subscription.created` | New subscription is created |
| `subscription.active` | Subscription becomes active (payment confirmed) |
| `subscription.canceled` | Customer cancels (still active until period end) |
| `subscription.uncanceled` | Customer re-activates a canceled subscription |
| `subscription.revoked` | Subscription fully terminated (access should be removed) |
| `subscription.past_due` | Payment failed, subscription at risk |
| `order.created` | New order placed |
| `order.paid` | Order payment confirmed |
| `order.refunded` | Order was refunded |
| `customer.created` | New customer record |
| `customer.state_changed` | Customer state updated (e.g. active subscriptions changed) |
| `benefit_grant.created` | Benefit granted to customer |
| `benefit_grant.revoked` | Benefit revoked from customer |

---

### Supabase Integration Pattern

Recommended `subscriptions` table schema:

```sql
create table public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  polar_subscription_id text unique not null,
  polar_customer_id text not null,
  polar_product_id text not null,
  status text not null default 'active',
  current_period_start timestamptz,
  current_period_end timestamptz,
  cancel_at_period_end boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Index for fast lookups
create index idx_subscriptions_user_id on public.subscriptions(user_id);
create index idx_subscriptions_polar_sub_id on public.subscriptions(polar_subscription_id);

-- RLS policy: users can read their own subscriptions
alter table public.subscriptions enable row level security;

create policy "Users can view own subscriptions"
  on public.subscriptions for select
  using (auth.uid() = user_id);
```

Helper to check subscription status in server components:

```typescript
// src/lib/subscription.ts
import { createClient } from "@/lib/supabase/server";

export async function getActiveSubscription() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) return null;

  const { data: subscription } = await supabase
    .from("subscriptions")
    .select("*")
    .eq("user_id", user.id)
    .in("status", ["active"])
    .single();

  return subscription;
}

export async function isPro(): Promise<boolean> {
  const sub = await getActiveSubscription();
  return sub !== null;
}
```

---

### Customer Portal

Polar hosts the customer portal for you. Customers can manage their subscriptions, update payment methods, and view invoices without you building any UI.

```typescript
// src/app/api/portal/route.ts
import { CustomerPortal } from "@polar-sh/nextjs";

export const GET = CustomerPortal({
  accessToken: process.env.POLAR_ACCESS_TOKEN!,
  getCustomerId: async (req) => {
    // Resolve the Polar customer ID for the current user
    // Example: look it up from your subscriptions table
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();

    if (!user) throw new Error("Unauthorized");

    const { data: sub } = await supabase
      .from("subscriptions")
      .select("polar_customer_id")
      .eq("user_id", user.id)
      .single();

    return sub?.polar_customer_id ?? "";
  },
  returnUrl: `${process.env.NEXT_PUBLIC_APP_URL}/settings/billing`,
  server: "sandbox", // Remove for production
});
```

Link to it from your billing settings:

```tsx
<a href="/api/portal">Manage Billing</a>
```

---

## LemonSqueezy (Alternative)

### When to Use LemonSqueezy vs Polar

| Factor | Polar.sh | LemonSqueezy |
|--------|----------|-------------|
| Target audience | Developer-first SaaS | Broader digital products |
| Merchant of Record | Yes | Yes |
| Next.js helpers | `@polar-sh/nextjs` (Checkout, Webhooks, Portal) | Manual setup |
| License key management | Built-in | Built-in |
| Open source | Yes (core platform) | No |
| Pricing | Competitive developer pricing | % per transaction |
| Customer portal | Hosted by Polar | Hosted by LemonSqueezy |

Use LemonSqueezy if you are already invested in their ecosystem, need their specific storefront features, or prefer their dashboard UX for non-technical team members.

### Basic Setup

```bash
pnpm add @lemonsqueezy/lemonsqueezy.js
```

```env
LEMONSQUEEZY_API_KEY=...
LEMONSQUEEZY_STORE_ID=...
LEMONSQUEEZY_WEBHOOK_SECRET=...
```

```typescript
// src/lib/lemonsqueezy.ts
import {
  lemonSqueezySetup,
  createCheckout,
} from "@lemonsqueezy/lemonsqueezy.js";

lemonSqueezySetup({ apiKey: process.env.LEMONSQUEEZY_API_KEY! });

// src/app/api/checkout/route.ts
import { NextResponse } from "next/server";

export async function POST(request: Request) {
  const { variantId, userId } = await request.json();

  const { data } = await createCheckout(
    process.env.LEMONSQUEEZY_STORE_ID!,
    variantId,
    {
      checkoutData: {
        custom: { user_id: userId },
      },
      productOptions: {
        redirectUrl: `${process.env.NEXT_PUBLIC_APP_URL}/dashboard`,
      },
    }
  );

  return NextResponse.json({ url: data?.data.attributes.url });
}
```

---

## Email Integration (Resend)

### Setup

```bash
pnpm add resend @react-email/components
```

```env
RESEND_API_KEY=re_...
```

### Email Client (`src/lib/resend.ts`)

```typescript
import { Resend } from "resend";

export const resend = new Resend(process.env.RESEND_API_KEY);
```

### Send Email with React Email Template

```typescript
// src/emails/welcome.tsx
import {
  Html,
  Head,
  Body,
  Container,
  Heading,
  Text,
  Link,
} from "@react-email/components";

export function WelcomeEmail({
  name,
  dashboardUrl,
}: {
  name: string;
  dashboardUrl: string;
}) {
  return (
    <Html>
      <Head />
      <Body style={{ fontFamily: "sans-serif" }}>
        <Container>
          <Heading>Welcome, {name}!</Heading>
          <Text>
            Thanks for signing up. Get started by visiting your dashboard.
          </Text>
          <Link href={dashboardUrl}>Go to Dashboard</Link>
        </Container>
      </Body>
    </Html>
  );
}
```

```typescript
// Usage in a route handler or webhook
import { resend } from "@/lib/resend";
import { WelcomeEmail } from "@/emails/welcome";

await resend.emails.send({
  from: "MyApp <hello@myapp.com>",
  to: user.email,
  subject: "Welcome to MyApp!",
  react: WelcomeEmail({
    name: user.name,
    dashboardUrl: `${process.env.NEXT_PUBLIC_APP_URL}/dashboard`,
  }),
});
```

---

## Webhook Best Practices

| Practice | Why |
|----------|-----|
| Always verify signatures | Prevents spoofed webhook events |
| Use raw body for signature verification | Parsing JSON first changes the body and breaks verification |
| Process events idempotently | Providers may send the same event more than once |
| Return 200/202 quickly | Providers retry on timeout (typically 20-30 seconds) |
| Use service role Supabase client | Webhooks have no user context, need admin access |
| Log unhandled event types | Helps you discover events you should handle |
| Store webhook payloads for debugging | Save raw payloads to a `webhook_events` table during development |

---

## API Key Management

### Storage Rules

| Key Type | Where to Store | Access Pattern |
|----------|----------------|----------------|
| Server-only API keys | Environment variables (no `NEXT_PUBLIC_` prefix) | Route handlers, server components |
| Public keys | `NEXT_PUBLIC_` env vars | Client components |
| User-provided API keys | Encrypted in database | Decrypt server-side per request |
| OAuth tokens | Supabase auth or encrypted DB column | Refresh server-side |

Never hardcode API keys in source code. Use `.env.local` for development and your hosting provider's environment variable management (Vercel, Fly.io, etc.) for production.

---

## Error Handling and Retry Patterns

### Retry with Exponential Backoff

```typescript
async function fetchWithRetry(
  url: string,
  options: RequestInit,
  maxRetries = 3
): Promise<Response> {
  let lastError: Error | null = null;

  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      const response = await fetch(url, options);

      // Do not retry client errors (4xx), only server errors (5xx)
      if (response.ok || (response.status >= 400 && response.status < 500)) {
        return response;
      }

      lastError = new Error(`HTTP ${response.status}`);
    } catch (error) {
      lastError = error as Error;
    }

    // Exponential backoff: 1s, 2s, 4s
    const delay = Math.pow(2, attempt) * 1000;
    await new Promise((resolve) => setTimeout(resolve, delay));
  }

  throw lastError;
}
```

### Typed API Error Handling

```typescript
type ApiResult<T> = { data: T; error: null } | { data: null; error: string };

async function apiCall<T>(
  url: string,
  options?: RequestInit
): Promise<ApiResult<T>> {
  try {
    const response = await fetch(url, options);
    if (!response.ok) {
      const errorBody = await response.text();
      return { data: null, error: `HTTP ${response.status}: ${errorBody}` };
    }
    const data = await response.json();
    return { data, error: null };
  } catch (err) {
    return { data: null, error: (err as Error).message };
  }
}

// Usage
const { data, error } = await apiCall<User[]>("/api/users");
if (error) {
  console.error("Failed to fetch users:", error);
  return;
}
// data is typed as User[]
```

---

## Integration Checklist

### Before Going Live

- [ ] All API keys stored in environment variables (never hardcoded)
- [ ] Sandbox/test keys used in development, production keys only in production
- [ ] Webhook signatures verified for all incoming webhooks
- [ ] Webhook endpoint registered in Polar dashboard with correct URL
- [ ] Error handling covers network failures and API errors
- [ ] Retry logic implemented for transient failures
- [ ] Subscription lifecycle tested (create, activate, cancel, revoke)
- [ ] Customer portal accessible and working
- [ ] Email sending verified (check spam folder)
- [ ] Supabase RLS policies configured for subscription data
- [ ] `POLAR_ACCESS_TOKEN` rotated from sandbox to production token

---

## Common Mistakes

| Mistake | Why It Breaks | Fix |
|---------|--------------|-----|
| Using sandbox token in production | Checkout creates test data, no real charges | Use separate env vars per environment |
| Parsing JSON before signature verification | Changes the raw body, signature check fails | Use `request.text()` or raw body first |
| Hardcoding product/price IDs | Breaks when IDs differ between sandbox and production | Store IDs in env vars or a config file |
| Not handling `subscription.revoked` | Users keep access after subscription ends | Always revoke access on this event |
| Building a custom billing portal | Wasted effort, Polar hosts one for free | Use `CustomerPortal` from `@polar-sh/nextjs` |
| Forgetting idempotency in webhooks | Duplicate events cause duplicate records | Use `polar_subscription_id` as a unique constraint, upsert instead of insert |
| Exposing `POLAR_ACCESS_TOKEN` to the client | Full API access leaked to browser | Never prefix with `NEXT_PUBLIC_`, only use server-side |
| Not setting up webhook retry handling | Missed events on transient server errors | Return 200/202 quickly, process async if needed |
| Skipping RLS on subscription tables | Any authenticated user can read all subscriptions | Add `auth.uid() = user_id` policy |
| Using `createClient()` in webhooks | Auth client has no user session in webhook context | Use service role client with `createClient(url, serviceRoleKey)` |
