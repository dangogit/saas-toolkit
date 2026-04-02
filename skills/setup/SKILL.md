---
name: setup
description: Bootstrap a new SaaS project with Next.js App Router, Supabase, Tailwind CSS, and shadcn/ui. Use for: project initialization, scaffolding, bootstrapping. Triggers on "set up a new project", "bootstrap", "create a new SaaS app", "initialize project".
---

# setup

Bootstrap a new SaaS project from scratch with Next.js App Router + Supabase + Tailwind CSS + shadcn/ui. Use when starting a new SaaS, initializing a project, scaffolding an app, or saying "set up a new project", "bootstrap", "create a new SaaS app".

---

## Quick Reference

| Layer | Tool | Version |
|-------|------|---------|
| Framework | Next.js (App Router) | Latest stable |
| Database | Supabase (Postgres + Auth) | Latest CLI |
| Styling | Tailwind CSS + shadcn/ui | v4+ / Latest |
| Language | TypeScript | Strict mode |
| Package Manager | pnpm (preferred) or npm | Latest |

---

## Step 1 - Initialize Next.js Project

```bash
pnpm create next-app@latest my-saas \
  --typescript \
  --tailwind \
  --eslint \
  --app \
  --src-dir \
  --import-alias "@/*" \
  --use-pnpm
```

After creation, verify the project runs:

```bash
cd my-saas && pnpm dev
```

---

## Step 2 - Install Core Dependencies

```bash
# Supabase client
pnpm add @supabase/supabase-js @supabase/ssr

# shadcn/ui (init will prompt for config)
pnpm dlx shadcn@latest init

# Commonly needed shadcn components
pnpm dlx shadcn@latest add button card input label toast dialog dropdown-menu avatar

# Utility libraries
pnpm add zod lucide-react
```

---

## Step 2b - Install Common Packages

These packages cover data fetching, forms, UI utilities, and visualization needs for most SaaS apps:

```bash
# Data fetching and forms
pnpm add @tanstack/react-query react-hook-form @hookform/resolvers zod

# Utilities
pnpm add date-fns clsx tailwind-merge lucide-react

# Optional but common
pnpm add framer-motion recharts sonner cmdk
```

**TanStack Query provider setup** - wrap your root layout with the QueryClientProvider so queries work across the entire app:

```tsx
// components/providers.tsx
"use client";

import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { useState } from "react";

export function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 60 * 1000,
            refetchOnWindowFocus: false,
          },
        },
      })
  );

  return (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  );
}
```

Then wrap `{children}` in your `app/layout.tsx`:

```tsx
import { Providers } from "@/components/providers";

// Inside the body tag:
<Providers>{children}</Providers>
```

---

## Step 3 - Folder Structure

Set up the following directory structure inside `src/`:

```
src/
  app/
    (auth)/
      login/page.tsx
      signup/page.tsx
      callback/route.ts        # Supabase auth callback
    (dashboard)/
      dashboard/page.tsx
      settings/page.tsx
    api/
      webhooks/
        stripe/route.ts
    layout.tsx
    page.tsx                   # Landing page
    globals.css
  components/
    ui/                        # shadcn/ui components (auto-generated)
    layout/
      header.tsx
      footer.tsx
      sidebar.tsx
    forms/
    shared/
  lib/
    supabase/
      client.ts                # Browser client
      server.ts                # Server component client
      middleware.ts            # Auth middleware helper
      admin.ts                 # Service role client (server only)
    utils.ts
    constants.ts
  types/
    database.types.ts          # Generated from Supabase
    index.ts
  hooks/
    use-user.ts
  middleware.ts                # Next.js middleware (auth guard)
```

Create the directories:

```bash
mkdir -p src/{components/{layout,forms,shared},lib/supabase,types,hooks}
mkdir -p src/app/{"\(auth\)"/{login,signup,callback},"\(dashboard\)"/{dashboard,settings},api/webhooks/stripe}
```

---

## Step 4 - Environment Variables

Create `.env.local` at the project root:

```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=http://127.0.0.1:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# App
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_APP_NAME=MySaaS

# Stripe (add when ready)
# STRIPE_SECRET_KEY=sk_test_...
# STRIPE_WEBHOOK_SECRET=whsec_...
# NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...

# PostHog (add when ready)
# NEXT_PUBLIC_POSTHOG_KEY=phc_...
# NEXT_PUBLIC_POSTHOG_HOST=https://us.i.posthog.com
```

Add `.env.local` to `.gitignore` (should already be there from create-next-app).

Create `.env.example` with the same keys but no values, for documentation.

---

## Step 5 - Supabase Setup

### Local Development

```bash
# Install Supabase CLI if not present
pnpm add -D supabase

# Initialize Supabase in the project
pnpm supabase init

# Start local Supabase (Docker required)
pnpm supabase start
```

After `supabase start`, copy the printed `anon key` and `API URL` into `.env.local`.

### Cloud Project

1. Go to https://supabase.com/dashboard and create a new project
2. Copy the project URL and anon key into `.env.local` for production
3. Link your local project:

```bash
pnpm supabase link --project-ref <your-project-ref>
```

---

## Step 6 - Supabase Client Setup

### Browser Client (`src/lib/supabase/client.ts`)

```typescript
import { createBrowserClient } from "@supabase/ssr";

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );
}
```

### Server Client (`src/lib/supabase/server.ts`)

```typescript
import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";

export async function createClient() {
  const cookieStore = await cookies();

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            );
          } catch {
            // Called from Server Component - ignore
          }
        },
      },
    }
  );
}
```

### Middleware (`src/middleware.ts`)

```typescript
import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

export async function middleware(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value)
          );
          supabaseResponse = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          );
        },
      },
    }
  );

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (
    !user &&
    request.nextUrl.pathname.startsWith("/dashboard")
  ) {
    const url = request.nextUrl.clone();
    url.pathname = "/login";
    return NextResponse.redirect(url);
  }

  return supabaseResponse;
}

export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
};
```

---

## Step 7 - Database Schema Starter

Create the initial migration:

```bash
pnpm supabase migration new init_schema
```

Add this SQL to the generated migration file:

```sql
-- Enable UUID generation
create extension if not exists "uuid-ossp";

-- Profiles table (extends Supabase auth.users)
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  email text not null,
  full_name text,
  avatar_url text,
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null
);

-- Enable RLS
alter table public.profiles enable row level security;

-- Policies
create policy "Users can view their own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, email, full_name, avatar_url)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data ->> 'full_name',
    new.raw_user_meta_data ->> 'avatar_url'
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Updated_at trigger
create or replace function public.update_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger update_profiles_updated_at
  before update on public.profiles
  for each row execute procedure public.update_updated_at();
```

Apply the migration locally:

```bash
pnpm supabase db reset
```

---

## Step 8 - Generate TypeScript Types

```bash
pnpm supabase gen types typescript --local > src/types/database.types.ts
```

Re-run this command whenever you change your schema.

---

## Step 9 - Auth Pages

### Login Page (`src/app/(auth)/login/page.tsx`)

```typescript
"use client";

import { createClient } from "@/lib/supabase/client";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const router = useRouter();
  const supabase = createClient();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      setError(error.message);
      setLoading(false);
      return;
    }

    router.push("/dashboard");
    router.refresh();
  };

  return (
    <form onSubmit={handleLogin} className="mx-auto max-w-sm space-y-4 p-8">
      <h1 className="text-2xl font-bold">Log In</h1>
      {error && <p className="text-sm text-red-500">{error}</p>}
      <div className="space-y-2">
        <Label htmlFor="email">Email</Label>
        <Input id="email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
      </div>
      <div className="space-y-2">
        <Label htmlFor="password">Password</Label>
        <Input id="password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} required />
      </div>
      <Button type="submit" className="w-full" disabled={loading}>
        {loading ? "Signing in..." : "Sign In"}
      </Button>
    </form>
  );
}
```

### Auth Callback (`src/app/(auth)/callback/route.ts`)

```typescript
import { createClient } from "@/lib/supabase/server";
import { NextResponse } from "next/server";

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get("code");
  const next = searchParams.get("next") ?? "/dashboard";

  if (code) {
    const supabase = await createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);
    if (!error) {
      return NextResponse.redirect(`${origin}${next}`);
    }
  }

  return NextResponse.redirect(`${origin}/login?error=auth_failed`);
}
```

---

## Step 10 - Git Init

```bash
git init
git add .
git commit -m "feat: initial SaaS scaffold with Next.js, Supabase, shadcn/ui"
```

Ensure `.gitignore` includes at minimum:

```
node_modules/
.next/
.env.local
.env*.local
supabase/.temp/
```

---

## Setup Checklist

- [ ] Next.js project created with App Router + TypeScript
- [ ] Tailwind CSS configured and working
- [ ] shadcn/ui initialized with base components
- [ ] Folder structure created (app, components, lib, types, hooks)
- [ ] `.env.local` created with Supabase keys
- [ ] `.env.example` created for team reference
- [ ] Supabase local instance running
- [ ] Supabase cloud project created and linked
- [ ] Browser and server Supabase clients set up
- [ ] Middleware configured for auth protection
- [ ] Database schema created (profiles table + trigger)
- [ ] TypeScript types generated from Supabase
- [ ] Login and signup pages created
- [ ] Auth callback route handler created
- [ ] Git initialized with clean first commit
- [ ] Dev server runs without errors

---

## Common Issues

| Problem | Solution |
|---------|----------|
| Supabase `start` fails | Ensure Docker Desktop is running |
| Types import errors | Re-run `supabase gen types typescript --local` |
| Auth redirect loop | Check middleware matcher pattern, ensure callback route exists |
| shadcn components not styled | Verify `components.json` has correct paths, check Tailwind config |
| Cookies error in Server Components | The `setAll` try/catch in server client handles this - it is expected |

---

## Next Steps

After setup is complete, continue with:

1. **database** skill - design your full schema with RLS policies
2. **analytics** skill - add PostHog tracking
3. **api-integration** skill - connect Stripe for payments
4. **secure** skill - security hardening before launch
5. **deploy** skill - ship to Vercel
