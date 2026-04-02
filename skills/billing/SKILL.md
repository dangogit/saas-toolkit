---
name: billing
description: Implement subscription billing and feature gating with Polar.sh + Supabase. Use for: pricing, subscriptions, checkout, webhooks, usage limits. Triggers on "add billing", "subscription plans", "checkout flow", "feature gating", "usage limits", "Polar integration".
---

# billing

Implement subscription billing and feature gating with Polar.sh + Supabase. Use when adding subscription plans, building checkout flows, handling webhooks, gating features by plan, tracking usage, or saying "add billing", "pricing page", "checkout", "feature gating", "Polar integration".

---

## Architecture Overview

| Layer | File | Purpose |
|-------|------|---------|
| Plan definitions | `subscription_plans` table | Plan slugs, prices, limits, features |
| User subscriptions | `user_subscriptions` table | Active subscription state per user |
| Usage tracking | `usage_monthly` table | Monthly usage counters |
| Checkout | `app/api/checkout/route.ts` | Create Polar checkout sessions |
| Webhooks | `app/api/webhook/polar/route.ts` | Sync subscription state from Polar |
| Feature gating | `lib/billing/limits.ts` | Check plan limits before actions |
| Billing page | `app/(dashboard)/billing/page.tsx` | Plan cards, usage, upgrade CTAs |
| Customer portal | `app/api/billing/portal/route.ts` | Redirect to Polar's hosted portal |

---

## Environment Variables

```bash
POLAR_ACCESS_TOKEN=polar_at_...          # Polar API access token
POLAR_WEBHOOK_SECRET=whsec_...           # Webhook signature verification
POLAR_PRODUCT_ID_PRO=prod_...            # Polar product ID for Pro plan
POLAR_PRODUCT_ID_AGENCY=prod_...         # Polar product ID for Agency plan
NEXT_PUBLIC_APP_URL=https://your-app.com # For checkout success/cancel URLs
```

---

## Step 1 - Database Schema

### Plans Table

```sql
create table public.subscription_plans (
  id uuid default gen_random_uuid() primary key,
  slug text unique not null,           -- "pro", "agency"
  name text not null,                  -- "Pro", "Agency"
  price integer not null,              -- Price in cents (e.g., 2900 = $29)
  credits integer default 0,           -- Monthly credit allocation
  max_businesses integer default 1,    -- Max businesses/workspaces
  max_creatives_per_month integer default 10, -- Monthly creative limit
  features jsonb default '[]'::jsonb,  -- Feature list for pricing page
  is_active boolean default true,      -- Soft disable plans
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null
);

-- Seed plans
insert into public.subscription_plans (slug, name, price, credits, max_businesses, max_creatives_per_month, features)
values
  ('pro', 'Pro', 2900, 100, 3, 50, '["Unlimited analytics", "Priority support", "Custom branding"]'),
  ('agency', 'Agency', 7900, 500, 10, 200, '["Everything in Pro", "White-label", "API access", "Dedicated support"]');
```

### User Subscriptions Table

```sql
create table public.user_subscriptions (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade not null,
  plan_id uuid references public.subscription_plans on delete set null,
  status text not null default 'active'
    check (status in ('active', 'canceled', 'expired', 'past_due', 'incomplete')),
  polar_subscription_id text unique,     -- Polar's subscription ID
  polar_customer_id text,                -- Polar's customer ID
  current_period_start timestamptz,
  current_period_end timestamptz,
  canceled_at timestamptz,               -- When user requested cancellation
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null,
  unique(user_id)                        -- One active subscription per user
);

-- Indexes
create index idx_user_subscriptions_user_id on public.user_subscriptions(user_id);
create index idx_user_subscriptions_polar_sub_id on public.user_subscriptions(polar_subscription_id);
create index idx_user_subscriptions_status on public.user_subscriptions(status);
```

### Monthly Usage Table

```sql
create table public.usage_monthly (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade not null,
  month date not null,                   -- First day of month (e.g., 2026-04-01)
  creatives_count integer default 0,
  credits_used integer default 0,
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null,
  unique(user_id, month)
);

create index idx_usage_monthly_user_month on public.usage_monthly(user_id, month);
```

### RLS Policies

```sql
alter table public.subscription_plans enable row level security;
alter table public.user_subscriptions enable row level security;
alter table public.usage_monthly enable row level security;

-- Plans are readable by everyone (pricing page)
create policy "plans_select_all"
  on public.subscription_plans for select
  using (true);

-- Users can only read their own subscription
create policy "subscriptions_select_own"
  on public.user_subscriptions for select
  using (auth.uid() = user_id);

-- Users can only read their own usage
create policy "usage_select_own"
  on public.usage_monthly for select
  using (auth.uid() = user_id);
```

---

## Step 2 - Plan Query Helpers

### `lib/billing/plans.ts`

```typescript
import { createClient } from "@/lib/supabase/server";

export async function getPlans() {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("subscription_plans")
    .select("*")
    .eq("is_active", true)
    .order("price", { ascending: true });

  if (error) throw error;
  return data;
}

export async function getPlanBySlug(slug: string) {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("subscription_plans")
    .select("*")
    .eq("slug", slug)
    .single();

  if (error) throw error;
  return data;
}
```

---

## Step 3 - Polar Checkout Route

### `app/api/checkout/route.ts`

Supports two flows:
- **GET** - Redirects the user to Polar's hosted checkout page
- **POST** - Returns a checkout URL for embedded or client-side redirect

```typescript
import { Polar } from "@polar-sh/sdk";
import { createClient } from "@/lib/supabase/server";
import { NextResponse } from "next/server";

const polar = new Polar({ accessToken: process.env.POLAR_ACCESS_TOKEN! });

// Map plan slugs to Polar product IDs
const PLAN_PRODUCT_MAP: Record<string, string> = {
  pro: process.env.POLAR_PRODUCT_ID_PRO!,
  agency: process.env.POLAR_PRODUCT_ID_AGENCY!,
};

export async function POST(request: Request) {
  // 1. Authenticate
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  // 2. Parse and validate
  const { planSlug } = await request.json();
  const productId = PLAN_PRODUCT_MAP[planSlug];

  if (!productId) {
    return NextResponse.json({ error: "Invalid plan" }, { status: 400 });
  }

  // 3. Create checkout session
  const checkout = await polar.checkouts.create({
    products: [productId],
    successUrl: `${process.env.NEXT_PUBLIC_APP_URL}/billing?success=true`,
    customerEmail: user.email!,
    externalCustomerId: user.id,  // Links Polar customer to Supabase user
    metadata: {
      supabase_user_id: user.id,
      plan_slug: planSlug,
    },
  });

  return NextResponse.json({ checkoutUrl: checkout.url });
}

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const planSlug = searchParams.get("plan");

  if (!planSlug) {
    return NextResponse.json({ error: "Missing plan parameter" }, { status: 400 });
  }

  // Authenticate
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return NextResponse.redirect(
      new URL(`/login?next=/api/checkout?plan=${planSlug}`, request.url)
    );
  }

  const productId = PLAN_PRODUCT_MAP[planSlug];
  if (!productId) {
    return NextResponse.redirect(new URL("/billing?error=invalid_plan", request.url));
  }

  const checkout = await polar.checkouts.create({
    products: [productId],
    successUrl: `${process.env.NEXT_PUBLIC_APP_URL}/billing?success=true`,
    customerEmail: user.email!,
    externalCustomerId: user.id,
    metadata: {
      supabase_user_id: user.id,
      plan_slug: planSlug,
    },
  });

  return NextResponse.redirect(checkout.url);
}
```

---

## Step 4 - Polar Webhook Handler

### `app/api/webhook/polar/route.ts`

```typescript
import { validateEvent } from "@polar-sh/sdk/webhooks";
import { createClient } from "@supabase/supabase-js";
import { NextResponse } from "next/server";

// Use service role client for webhook - no user context
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

export async function POST(request: Request) {
  const body = await request.text();
  const headers = Object.fromEntries(request.headers.entries());

  // 1. Verify webhook signature
  let event;
  try {
    event = validateEvent(body, headers, process.env.POLAR_WEBHOOK_SECRET!);
  } catch (err) {
    console.error("Webhook signature verification failed:", err);
    return NextResponse.json({ error: "Invalid signature" }, { status: 400 });
  }

  // 2. Handle subscription events
  switch (event.type) {
    case "subscription.created":
    case "subscription.updated":
    case "subscription.active": {
      const subscription = event.data;

      // Resolve user via externalId or metadata
      const userId =
        subscription.customer?.externalId ??
        subscription.metadata?.supabase_user_id;

      if (!userId) {
        console.error("No user ID found in subscription:", subscription.id);
        return NextResponse.json({ error: "No user mapping" }, { status: 400 });
      }

      // Map product name to plan slug
      const planSlug = mapProductToPlanSlug(subscription.product?.name);
      const plan = await getPlanBySlug(planSlug);

      // Upsert subscription record
      await supabase.from("user_subscriptions").upsert(
        {
          user_id: userId,
          plan_id: plan?.id,
          status: "active",
          polar_subscription_id: subscription.id,
          polar_customer_id: subscription.customerId,
          current_period_start: subscription.currentPeriodStart,
          current_period_end: subscription.currentPeriodEnd,
          canceled_at: null,
        },
        { onConflict: "user_id" }
      );

      break;
    }

    case "subscription.canceled": {
      const subscription = event.data;

      await supabase
        .from("user_subscriptions")
        .update({
          status: "canceled",
          canceled_at: new Date().toISOString(),
        })
        .eq("polar_subscription_id", subscription.id);

      break;
    }

    case "subscription.revoked": {
      const subscription = event.data;

      await supabase
        .from("user_subscriptions")
        .update({
          status: "expired",
          canceled_at: new Date().toISOString(),
        })
        .eq("polar_subscription_id", subscription.id);

      break;
    }

    case "order.created": {
      // One-time purchases (e.g., credit packs)
      const order = event.data;
      const userId =
        order.customer?.externalId ?? order.metadata?.supabase_user_id;

      if (userId && order.product?.name?.toLowerCase().includes("credit")) {
        const creditsToAdd = order.metadata?.credits
          ? parseInt(order.metadata.credits as string)
          : 100;

        // Add credits to current month usage (negative credits_used = bonus)
        const month = new Date().toISOString().slice(0, 7) + "-01";
        const { data: existing } = await supabase
          .from("usage_monthly")
          .select("credits_used")
          .eq("user_id", userId)
          .eq("month", month)
          .single();

        if (existing) {
          await supabase
            .from("usage_monthly")
            .update({ credits_used: existing.credits_used - creditsToAdd })
            .eq("user_id", userId)
            .eq("month", month);
        }
      }

      break;
    }
  }

  return NextResponse.json({ received: true });
}

// Map Polar product names to your plan slugs
function mapProductToPlanSlug(productName?: string): string {
  if (!productName) return "pro";
  const name = productName.toLowerCase();
  if (name.includes("agency")) return "agency";
  if (name.includes("pro")) return "pro";
  return "pro";
}

async function getPlanBySlug(slug: string) {
  const { data } = await supabase
    .from("subscription_plans")
    .select("id")
    .eq("slug", slug)
    .single();
  return data;
}
```

---

## Step 5 - Feature Gating Functions

### `lib/billing/limits.ts`

```typescript
import { createClient } from "@/lib/supabase/server";

// Free tier defaults - no DB row needed
const FREE_LIMITS = {
  max_businesses: 1,
  max_creatives_per_month: 5,
  credits: 0,
};

export async function getUserSubscription(userId: string) {
  const supabase = await createClient();
  const { data } = await supabase
    .from("user_subscriptions")
    .select("*, plan:subscription_plans(*)")
    .eq("user_id", userId)
    .eq("status", "active")
    .single();

  return data;
}

export async function isOnFreePlan(userId: string): Promise<boolean> {
  const subscription = await getUserSubscription(userId);
  return !subscription;
}

export async function canCreateBusiness(userId: string): Promise<{
  allowed: boolean;
  current: number;
  limit: number;
}> {
  const supabase = await createClient();
  const subscription = await getUserSubscription(userId);

  const limit = subscription?.plan?.max_businesses ?? FREE_LIMITS.max_businesses;

  const { count } = await supabase
    .from("businesses")
    .select("*", { count: "exact", head: true })
    .eq("user_id", userId);

  return {
    allowed: (count ?? 0) < limit,
    current: count ?? 0,
    limit,
  };
}

export async function canCreateCreative(userId: string): Promise<{
  allowed: boolean;
  current: number;
  limit: number;
}> {
  const supabase = await createClient();
  const subscription = await getUserSubscription(userId);

  const limit =
    subscription?.plan?.max_creatives_per_month ??
    FREE_LIMITS.max_creatives_per_month;

  // Get current month usage
  const month = new Date().toISOString().slice(0, 7) + "-01";
  const { data: usage } = await supabase
    .from("usage_monthly")
    .select("creatives_count")
    .eq("user_id", userId)
    .eq("month", month)
    .single();

  const current = usage?.creatives_count ?? 0;

  return {
    allowed: current < limit,
    current,
    limit,
  };
}

export async function incrementUsage(
  userId: string,
  field: "creatives_count" | "credits_used",
  amount: number = 1
) {
  const supabase = await createClient();
  const month = new Date().toISOString().slice(0, 7) + "-01";

  // Upsert with increment
  const { data: existing } = await supabase
    .from("usage_monthly")
    .select("id, " + field)
    .eq("user_id", userId)
    .eq("month", month)
    .single();

  if (existing) {
    await supabase
      .from("usage_monthly")
      .update({ [field]: (existing[field] as number) + amount })
      .eq("id", existing.id);
  } else {
    await supabase.from("usage_monthly").insert({
      user_id: userId,
      month,
      [field]: amount,
    });
  }
}
```

### Using Feature Gates in Route Handlers

```typescript
import { canCreateCreative, incrementUsage } from "@/lib/billing/limits";
import { createClient } from "@/lib/supabase/server";
import { NextResponse } from "next/server";

export async function POST(request: Request) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  // Check limits before allowing the action
  const { allowed, current, limit } = await canCreateCreative(user.id);
  if (!allowed) {
    return NextResponse.json(
      {
        error: "Monthly limit reached",
        current,
        limit,
        upgradeUrl: "/billing",
      },
      { status: 403 }
    );
  }

  // Perform the action...
  // const creative = await createCreative(user.id, body);

  // Track usage
  await incrementUsage(user.id, "creatives_count");

  return NextResponse.json({ success: true });
}
```

---

## Step 6 - Customer Portal

### `app/api/billing/portal/route.ts`

Redirects users to Polar's hosted customer portal where they can manage their subscription, update payment methods, and view invoices.

```typescript
import { Polar } from "@polar-sh/sdk";
import { createClient } from "@/lib/supabase/server";
import { NextResponse } from "next/server";

const polar = new Polar({ accessToken: process.env.POLAR_ACCESS_TOKEN! });

export async function GET() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  // Get user's Polar customer ID
  const { data: subscription } = await supabase
    .from("user_subscriptions")
    .select("polar_customer_id")
    .eq("user_id", user.id)
    .single();

  if (!subscription?.polar_customer_id) {
    return NextResponse.json(
      { error: "No active subscription" },
      { status: 404 }
    );
  }

  // Create portal session
  const session = await polar.customerPortal.sessions.create({
    customerId: subscription.polar_customer_id,
  });

  return NextResponse.redirect(session.customerPortalUrl);
}
```

---

## Step 7 - Billing Page Component

### `app/(dashboard)/billing/page.tsx`

```tsx
import { createClient } from "@/lib/supabase/server";
import { getPlans } from "@/lib/billing/plans";
import { getUserSubscription } from "@/lib/billing/limits";
import { redirect } from "next/navigation";

export default async function BillingPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const [plans, subscription] = await Promise.all([
    getPlans(),
    getUserSubscription(user.id),
  ]);

  // Get current month usage
  const month = new Date().toISOString().slice(0, 7) + "-01";
  const { data: usage } = await supabase
    .from("usage_monthly")
    .select("*")
    .eq("user_id", user.id)
    .eq("month", month)
    .single();

  const currentPlanSlug = subscription?.plan?.slug ?? "free";
  const limits = {
    creatives: subscription?.plan?.max_creatives_per_month ?? 5,
    businesses: subscription?.plan?.max_businesses ?? 1,
  };

  return (
    <div className="mx-auto max-w-4xl space-y-8 p-6">
      <h1 className="text-2xl font-bold">Billing</h1>

      {/* Current Plan Banner */}
      <div className="rounded-lg border bg-gray-50 p-4">
        <p className="text-sm text-gray-500">Current plan</p>
        <p className="text-lg font-semibold capitalize">{currentPlanSlug}</p>
        {subscription?.current_period_end && (
          <p className="text-sm text-gray-500">
            Renews {new Date(subscription.current_period_end).toLocaleDateString()}
          </p>
        )}
        {subscription?.polar_customer_id && (
          <a
            href="/api/billing/portal"
            className="mt-2 inline-block text-sm text-blue-600 underline"
          >
            Manage subscription
          </a>
        )}
      </div>

      {/* Usage */}
      <div className="space-y-4">
        <h2 className="text-lg font-semibold">Usage this month</h2>
        <UsageBar
          label="Creatives"
          current={usage?.creatives_count ?? 0}
          limit={limits.creatives}
        />
      </div>

      {/* Plan Cards */}
      <div className="grid gap-6 md:grid-cols-3">
        {/* Free tier card */}
        <PlanCard
          name="Free"
          price={0}
          features={["1 business", "5 creatives/month", "Basic analytics"]}
          isCurrent={currentPlanSlug === "free"}
        />

        {/* Paid plan cards */}
        {plans.map((plan) => (
          <PlanCard
            key={plan.id}
            name={plan.name}
            price={plan.price / 100}
            features={plan.features as string[]}
            isCurrent={currentPlanSlug === plan.slug}
            checkoutUrl={
              currentPlanSlug === "free"
                ? `/api/checkout?plan=${plan.slug}`
                : undefined
            }
          />
        ))}
      </div>
    </div>
  );
}

function UsageBar({
  label,
  current,
  limit,
}: {
  label: string;
  current: number;
  limit: number;
}) {
  const percentage = Math.min((current / limit) * 100, 100);
  const color =
    percentage >= 90
      ? "bg-red-500"
      : percentage >= 70
        ? "bg-amber-500"
        : "bg-green-500";

  return (
    <div>
      <div className="flex justify-between text-sm">
        <span>{label}</span>
        <span>
          {current} / {limit}
        </span>
      </div>
      <div className="mt-1 h-2 w-full rounded-full bg-gray-200">
        <div
          className={`h-2 rounded-full ${color}`}
          style={{ width: `${percentage}%` }}
        />
      </div>
    </div>
  );
}

function PlanCard({
  name,
  price,
  features,
  isCurrent,
  checkoutUrl,
}: {
  name: string;
  price: number;
  features: string[];
  isCurrent: boolean;
  checkoutUrl?: string;
}) {
  return (
    <div
      className={`rounded-lg border p-6 ${
        isCurrent ? "border-black ring-1 ring-black" : ""
      }`}
    >
      <h3 className="text-lg font-semibold">{name}</h3>
      <p className="mt-2 text-3xl font-bold">
        ${price}
        <span className="text-base font-normal text-gray-500">/mo</span>
      </p>
      <ul className="mt-4 space-y-2">
        {features.map((feature) => (
          <li key={feature} className="flex items-center gap-2 text-sm">
            <span className="text-green-500">✓</span>
            {feature}
          </li>
        ))}
      </ul>
      {isCurrent ? (
        <div className="mt-6 rounded-lg bg-gray-100 px-4 py-2 text-center text-sm font-medium">
          Current plan
        </div>
      ) : checkoutUrl ? (
        <a
          href={checkoutUrl}
          className="mt-6 block rounded-lg bg-black px-4 py-2 text-center text-sm font-medium text-white hover:bg-gray-800"
        >
          Upgrade to {name}
        </a>
      ) : null}
    </div>
  );
}
```

---

## Free Tier Pattern

Users without a subscription row are on the free plan. No database record is created for free users.

```
getUserSubscription(userId) returns null  -->  user is on free plan
```

Free limits are hardcoded constants in `lib/billing/limits.ts`:

```typescript
const FREE_LIMITS = {
  max_businesses: 1,
  max_creatives_per_month: 5,
  credits: 0,
};
```

This avoids orphaned records and simplifies onboarding - users get free access immediately without any billing setup.

---

## Cancellation Grace Period

When a user cancels, their subscription remains active until `current_period_end`. Handle this in your feature gates:

```typescript
export async function hasActiveAccess(userId: string): Promise<boolean> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("user_subscriptions")
    .select("status, current_period_end")
    .eq("user_id", userId)
    .single();

  if (!data) return false; // Free plan - use free limits

  // Active subscription
  if (data.status === "active") return true;

  // Canceled but still within paid period
  if (
    data.status === "canceled" &&
    data.current_period_end &&
    new Date(data.current_period_end) > new Date()
  ) {
    return true;
  }

  return false;
}
```

---

## Common Mistakes

| Mistake | Why it breaks | Fix |
|---------|---------------|-----|
| Not verifying webhook signatures | Attackers can forge subscription events and grant themselves paid plans | Always use `validateEvent` from `@polar-sh/sdk/webhooks` |
| Not setting `externalCustomerId` at checkout | Cannot link Polar customer back to Supabase user in webhooks | Always pass `externalCustomerId: user.id` when creating checkouts |
| Caching subscription status in the JWT or cookie | Stale data - user upgrades but still sees free limits until re-login | Query the database on each protected action, or use short-lived cache with revalidation |
| Not handling the cancellation grace period | User loses access immediately on cancel instead of at period end | Check `current_period_end` date, not just `status === "canceled"` |
| Using anon key in webhook handler | RLS blocks the webhook from writing subscription records | Use `SUPABASE_SERVICE_ROLE_KEY` in the webhook route (no user context) |
| Hardcoding product IDs | Cannot change plans or switch Polar environments without code changes | Store product IDs in environment variables |
| Not handling `subscription.revoked` | Users who fail payment keep access indefinitely | Handle revoked events by setting status to `expired` |
| Missing `onConflict` in subscription upsert | Duplicate subscription rows per user, race conditions | Use `upsert` with `onConflict: "user_id"` for one-subscription-per-user |
| Checking limits only on the client | Users can bypass limits by calling the API directly | Always enforce limits server-side in Route Handlers |
| No usage reset at month boundary | Usage accumulates forever, users hit lifetime limits | Use `month` column in `usage_monthly` and query current month only |

---

## Billing Setup Checklist

### Polar Dashboard
- [ ] Create organization in Polar
- [ ] Create products for each plan (Pro, Agency, etc.)
- [ ] Note product IDs for environment variables
- [ ] Set up webhook endpoint: `https://your-domain.com/api/webhook/polar`
- [ ] Enable webhook events: `subscription.*`, `order.created`
- [ ] Copy webhook secret for `POLAR_WEBHOOK_SECRET`
- [ ] Generate access token for `POLAR_ACCESS_TOKEN`

### Database
- [ ] `subscription_plans` table created and seeded
- [ ] `user_subscriptions` table created with indexes
- [ ] `usage_monthly` table created with indexes
- [ ] RLS enabled on all billing tables
- [ ] RLS policies tested

### Codebase
- [ ] `lib/billing/plans.ts` - plan query helpers
- [ ] `lib/billing/limits.ts` - feature gating functions
- [ ] `app/api/checkout/route.ts` - checkout endpoint
- [ ] `app/api/webhook/polar/route.ts` - webhook handler
- [ ] `app/api/billing/portal/route.ts` - customer portal redirect
- [ ] `app/(dashboard)/billing/page.tsx` - billing UI

### Environment Variables
- [ ] `POLAR_ACCESS_TOKEN` set
- [ ] `POLAR_WEBHOOK_SECRET` set
- [ ] `POLAR_PRODUCT_ID_PRO` set
- [ ] `POLAR_PRODUCT_ID_AGENCY` set
- [ ] `NEXT_PUBLIC_APP_URL` set

### Testing
- [ ] Checkout creates a Polar session and redirects
- [ ] Webhook receives events and updates `user_subscriptions`
- [ ] Free users see correct limits
- [ ] Paid users see upgraded limits after checkout
- [ ] Feature gates block actions when limits are reached
- [ ] Cancellation preserves access until period end
- [ ] Customer portal link works for subscribed users
- [ ] Usage resets at the start of each month

---

## File Structure

```
src/
  app/
    (dashboard)/
      billing/
        page.tsx              # Billing page with plans + usage
    api/
      checkout/
        route.ts              # Create Polar checkout sessions
      webhook/
        polar/
          route.ts            # Handle Polar webhook events
      billing/
        portal/
          route.ts            # Redirect to Polar customer portal
  lib/
    billing/
      plans.ts                # Plan query helpers
      limits.ts               # Feature gating + usage tracking
```
