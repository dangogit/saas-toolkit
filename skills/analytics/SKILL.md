---
name: analytics
description: Set up PostHog analytics, custom events, funnels, and feature flags in a Next.js App Router project. Use for: analytics setup, event tracking, feature flags, session recording, A/B testing. Triggers on "add PostHog", "track conversions", "set up feature flags", "analytics setup".
---

# analytics

Set up PostHog analytics, custom events, funnels, and feature flags in a Next.js App Router project. Use when adding analytics, tracking events, setting up feature flags, configuring session recording, A/B testing, or saying "add PostHog", "track conversions", "set up feature flags", "analytics setup".

---

## Quick Reference

| Capability | PostHog Feature |
|------------|-----------------|
| Page views | Autocapture |
| Custom events | `posthog.capture()` |
| User identification | `posthog.identify()` |
| Feature flags | `posthog.isFeatureEnabled()` |
| Session recording | Built-in, toggle in settings |
| A/B testing | Experiments |
| Funnels | Insights - Funnels |

---

## Step 1 - Installation

```bash
pnpm add posthog-js posthog-node
```

Add environment variables to `.env.local`:

```env
NEXT_PUBLIC_POSTHOG_KEY=phc_your_project_key
NEXT_PUBLIC_POSTHOG_HOST=https://us.i.posthog.com
```

---

## Step 2 - Provider Setup (App Router)

### PostHog Provider (`src/components/providers/posthog-provider.tsx`)

```typescript
"use client";

import posthog from "posthog-js";
import { PostHogProvider as PHProvider, usePostHog } from "posthog-js/react";
import { useEffect } from "react";
import { usePathname, useSearchParams } from "next/navigation";

if (typeof window !== "undefined") {
  posthog.init(process.env.NEXT_PUBLIC_POSTHOG_KEY!, {
    api_host: process.env.NEXT_PUBLIC_POSTHOG_HOST,
    person_profiles: "identified_only",
    capture_pageview: false, // We handle this manually for Next.js
    capture_pageleave: true,
  });
}

function PostHogPageView() {
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const posthogClient = usePostHog();

  useEffect(() => {
    if (pathname && posthogClient) {
      let url = window.origin + pathname;
      if (searchParams.toString()) {
        url = url + "?" + searchParams.toString();
      }
      posthogClient.capture("$pageview", { $current_url: url });
    }
  }, [pathname, searchParams, posthogClient]);

  return null;
}

export function PostHogProvider({ children }: { children: React.ReactNode }) {
  return (
    <PHProvider client={posthog}>
      <PostHogPageView />
      {children}
    </PHProvider>
  );
}
```

### Add to Root Layout (`src/app/layout.tsx`)

```typescript
import { PostHogProvider } from "@/components/providers/posthog-provider";
import { Suspense } from "react";

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <PostHogProvider>
          <Suspense>{children}</Suspense>
        </PostHogProvider>
      </body>
    </html>
  );
}
```

### Wrap PageView in Suspense

The `useSearchParams()` hook requires a Suspense boundary. Wrap it:

```typescript
import { Suspense } from "react";

function PostHogPageViewWrapper() {
  return (
    <Suspense fallback={null}>
      <PostHogPageView />
    </Suspense>
  );
}
```

---

## Step 3 - Custom Event Tracking

### Client-Side Events

```typescript
"use client";

import { usePostHog } from "posthog-js/react";

export function PricingCard({ plan }: { plan: string }) {
  const posthog = usePostHog();

  const handleClick = () => {
    posthog.capture("pricing_plan_selected", {
      plan_name: plan,
      source: "pricing_page",
    });
  };

  return <button onClick={handleClick}>Select {plan}</button>;
}
```

### Key SaaS Events to Track

| Event Name | When to Fire | Properties |
|------------|--------------|------------|
| `user_signed_up` | After successful registration | `method` (email, google, github) |
| `user_logged_in` | After successful login | `method` |
| `onboarding_step_completed` | Each onboarding step | `step_number`, `step_name` |
| `onboarding_completed` | Final onboarding step | `total_time_seconds` |
| `pricing_plan_selected` | Click on pricing plan | `plan_name`, `billing_period` |
| `checkout_started` | Redirect to Stripe checkout | `plan_name`, `price` |
| `subscription_created` | Webhook from Stripe | `plan_name`, `price`, `interval` |
| `feature_used` | User uses a key feature | `feature_name`, `context` |
| `team_created` | New team/org created | `team_size` |
| `team_member_invited` | Invite sent | `role` |
| `upgrade_prompt_shown` | Paywall/limit shown | `feature_name`, `current_plan` |
| `support_ticket_created` | User contacts support | `category` |

### Server-Side Events (Route Handlers / Webhooks)

```typescript
import { PostHog } from "posthog-node";

const posthog = new PostHog(process.env.NEXT_PUBLIC_POSTHOG_KEY!, {
  host: process.env.NEXT_PUBLIC_POSTHOG_HOST,
});

// In a webhook handler or route handler
export async function POST(request: Request) {
  // ... process webhook

  posthog.capture({
    distinctId: userId,
    event: "subscription_created",
    properties: {
      plan_name: "pro",
      price: 29,
      interval: "monthly",
    },
  });

  // Important: flush before the function ends
  await posthog.shutdown();

  return new Response("OK");
}
```

---

## Step 4 - Identifying Users

### After Login or Signup

```typescript
"use client";

import { usePostHog } from "posthog-js/react";
import { useEffect } from "react";

export function IdentifyUser({ user }: { user: { id: string; email: string; name: string } }) {
  const posthog = usePostHog();

  useEffect(() => {
    if (user) {
      posthog.identify(user.id, {
        email: user.email,
        name: user.name,
      });
    }
  }, [user, posthog]);

  return null;
}
```

### On Logout

```typescript
posthog.reset(); // Clears identified user, generates new anonymous ID
```

### Group Analytics (Team/Org Level)

```typescript
posthog.group("company", teamId, {
  name: teamName,
  plan: "pro",
  member_count: 5,
});
```

---

## Step 5 - Feature Flags

### Create Flags in PostHog Dashboard

1. Go to Feature Flags in PostHog
2. Create a new flag (e.g., `new-dashboard-ui`)
3. Set rollout conditions (percentage, user properties, etc.)

### Client-Side Usage

```typescript
"use client";

import { useFeatureFlagEnabled } from "posthog-js/react";

export function Dashboard() {
  const showNewUI = useFeatureFlagEnabled("new-dashboard-ui");

  if (showNewUI) {
    return <NewDashboard />;
  }

  return <LegacyDashboard />;
}
```

### Server-Side Usage

```typescript
import { PostHog } from "posthog-node";

const posthog = new PostHog(process.env.NEXT_PUBLIC_POSTHOG_KEY!, {
  host: process.env.NEXT_PUBLIC_POSTHOG_HOST,
});

export async function getFeatureFlag(userId: string, flagName: string) {
  const isEnabled = await posthog.isFeatureEnabled(flagName, userId);
  await posthog.shutdown();
  return isEnabled;
}
```

### Feature Flag with Payload

```typescript
import { useFeatureFlagPayload } from "posthog-js/react";

export function PricingPage() {
  const pricingConfig = useFeatureFlagPayload("pricing-experiment") as {
    headline: string;
    cta_text: string;
  } | undefined;

  return (
    <div>
      <h1>{pricingConfig?.headline ?? "Simple Pricing"}</h1>
      <button>{pricingConfig?.cta_text ?? "Get Started"}</button>
    </div>
  );
}
```

---

## Step 6 - Session Recording

### Enable in PostHog Dashboard

1. Go to Settings - Session Recording
2. Toggle recording on
3. Configure sampling rate (start with 100% for low traffic, reduce as you scale)

### Client Config Options

```typescript
posthog.init(process.env.NEXT_PUBLIC_POSTHOG_KEY!, {
  api_host: process.env.NEXT_PUBLIC_POSTHOG_HOST,
  // Session recording options
  session_recording: {
    maskAllInputs: true,       // Mask form inputs by default
    maskTextSelector: ".sensitive", // Mask elements with this class
  },
});
```

### Mask Sensitive Content

```html
<!-- These inputs will be masked in recordings -->
<input type="password" />
<input data-ph-no-capture />

<!-- Mask entire sections -->
<div className="sensitive">
  Credit card details here
</div>
```

---

## Step 7 - Funnel Analysis

### Define Your Core SaaS Funnel

Set up this funnel in PostHog Insights - Funnels:

| Step | Event | Expected Drop-off |
|------|-------|--------------------|
| 1 | `$pageview` (landing page) | - |
| 2 | `user_signed_up` | 70-90% |
| 3 | `onboarding_completed` | 30-50% |
| 4 | `feature_used` | 20-40% |
| 5 | `checkout_started` | 60-80% |
| 6 | `subscription_created` | 20-40% |

### Conversion Funnel Events

Make sure you are capturing events at each stage:

```typescript
// Landing page visit - automatic with pageview tracking

// Signup
posthog.capture("user_signed_up", { method: "email" });

// Onboarding
posthog.capture("onboarding_completed", { steps_completed: 3 });

// Core feature usage
posthog.capture("feature_used", { feature: "create_project" });

// Checkout
posthog.capture("checkout_started", { plan: "pro", price: 29 });

// Subscription (server-side from Stripe webhook)
posthog.capture({
  distinctId: userId,
  event: "subscription_created",
  properties: { plan: "pro" },
});
```

---

## Step 8 - A/B Testing (Experiments)

### Create an Experiment

1. In PostHog, go to Experiments
2. Create a new experiment
3. Define variants (control + test)
4. Set the goal metric (e.g., `subscription_created`)
5. Set minimum sample size

### Implement in Code

```typescript
"use client";

import { useFeatureFlagVariantKey } from "posthog-js/react";

export function HeroSection() {
  const variant = useFeatureFlagVariantKey("hero-copy-test");

  const headlines: Record<string, string> = {
    control: "Build your SaaS faster",
    test: "Ship your product in days, not months",
  };

  return (
    <h1 className="text-4xl font-bold">
      {headlines[variant as string] ?? headlines.control}
    </h1>
  );
}
```

### Track the Goal Event

```typescript
// This event is what PostHog uses to measure experiment success
posthog.capture("subscription_created", {
  plan: "pro",
  experiment_variant: variant, // Optional but helpful for debugging
});
```

---

## Step 9 - Key SaaS Metrics

### Metrics to Track in PostHog

| Metric | How to Measure | PostHog Feature |
|--------|----------------|-----------------|
| **Activation Rate** | % of signups who complete onboarding | Funnel: `user_signed_up` to `onboarding_completed` |
| **Feature Adoption** | % of users using a key feature in first 7 days | Funnel with time window |
| **Retention** | % of users returning weekly/monthly | Retention insight |
| **Churn Rate** | % of paying users who cancel | Trend: `subscription_canceled` / total active |
| **MRR** | Monthly recurring revenue | Track via server-side events from Stripe |
| **Trial-to-Paid** | % of trial users who convert | Funnel: `trial_started` to `subscription_created` |
| **Time to Value** | How long until first "aha moment" | Funnel with conversion time |
| **NPS Score** | User satisfaction | PostHog Surveys |

### Create a SaaS Dashboard in PostHog

Recommended widgets:

1. **Trends** - Daily active users (DAU)
2. **Trends** - New signups per day
3. **Funnel** - Signup to paid conversion
4. **Retention** - Weekly retention cohort
5. **Trends** - Feature usage breakdown
6. **Trends** - Churn events over time

---

## Step 10 - Privacy and GDPR

### Cookie Consent Banner

```typescript
"use client";

import posthog from "posthog-js";
import { useState } from "react";

export function CookieConsent() {
  const [shown, setShown] = useState(true);

  const handleAccept = () => {
    posthog.opt_in_capturing();
    setShown(false);
  };

  const handleDecline = () => {
    posthog.opt_out_capturing();
    setShown(false);
  };

  if (!shown) return null;

  return (
    <div className="fixed bottom-4 left-4 right-4 bg-white p-4 shadow-lg rounded-lg border z-50">
      <p className="text-sm">
        We use cookies to improve your experience. See our privacy policy.
      </p>
      <div className="mt-2 flex gap-2">
        <button onClick={handleAccept} className="bg-black text-white px-4 py-2 rounded text-sm">
          Accept
        </button>
        <button onClick={handleDecline} className="border px-4 py-2 rounded text-sm">
          Decline
        </button>
      </div>
    </div>
  );
}
```

### PostHog Privacy Config

```typescript
posthog.init(process.env.NEXT_PUBLIC_POSTHOG_KEY!, {
  api_host: process.env.NEXT_PUBLIC_POSTHOG_HOST,
  persistence: "localStorage+cookie",
  opt_out_capturing_by_default: true, // Require explicit opt-in (GDPR)
  respect_dnt: true,                  // Respect Do Not Track header
  mask_all_text: false,
  mask_all_element_attributes: false,
  session_recording: {
    maskAllInputs: true,
    maskTextSelector: ".ph-no-capture",
  },
});
```

### GDPR Compliance Checklist

- [ ] Cookie consent banner shown before tracking
- [ ] `opt_out_capturing_by_default: true` for EU users
- [ ] Privacy policy page exists and is linked
- [ ] Session recordings mask sensitive inputs
- [ ] User data deletion endpoint exists (via PostHog API)
- [ ] No PII stored in event properties (use IDs, not emails, in properties when possible)
- [ ] Data processing agreement signed with PostHog

---

## Common Issues

| Problem | Solution |
|---------|----------|
| Events not appearing | Check PostHog project key, verify provider is in layout |
| Pageviews double-counted | Set `capture_pageview: false` in init, use manual pageview component |
| Feature flags return undefined | Ensure user is identified, check flag conditions in dashboard |
| Session recordings not working | Verify recording is enabled in PostHog settings, check sampling rate |
| Events firing in development | Use `posthog.init()` conditionally: skip if `NODE_ENV === "development"` or use a dev PostHog project |
| CORS errors | Verify `api_host` matches your PostHog instance |
