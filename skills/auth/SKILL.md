---
name: auth
description: Implement Supabase Auth end-to-end in a Next.js App Router SaaS app. Use for: login, signup, OAuth, session handling, middleware protection. Triggers on "add auth", "login page", "sign up flow", "protect routes", "auth callback", "Google login".
---

# auth

Implement Supabase Auth end-to-end in a Next.js App Router SaaS app. Use when adding authentication, building login/signup pages, protecting routes with middleware, setting up OAuth, handling auth callbacks, or saying "add auth", "login page", "protect routes", "Google login".

---

## Architecture Overview

| Layer | File | Purpose |
|-------|------|---------|
| Browser client | `lib/supabase/client.ts` | Client Components - singleton per tab |
| Server client | `lib/supabase/server.ts` | Server Components, Route Handlers, Server Actions |
| Middleware | `middleware.ts` | Cookie refresh, route protection |
| Auth context | `providers/AuthProvider.tsx` | React context for user state + auth methods |
| Auth callback | `app/auth/callback/route.ts` | OAuth code exchange |
| Login page | `app/(auth)/login/page.tsx` | Email/password + OAuth UI |
| Signup page | `app/(auth)/signup/page.tsx` | Registration UI |

---

## Environment Variables

```bash
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...  # Server-side only, NEVER prefix with NEXT_PUBLIC_
```

---

## Step 1 - Supabase Client Setup

Install the required packages:

```bash
pnpm add @supabase/supabase-js @supabase/ssr
```

### Browser Client (`lib/supabase/client.ts`)

```typescript
import { createBrowserClient } from "@supabase/ssr";

export function createSupabaseBrowserClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );
}
```

### Server Client (`lib/supabase/server.ts`)

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
            // The `setAll` method is called from a Server Component
            // where cookies cannot be set. This can be ignored if
            // you have middleware refreshing user sessions.
          }
        },
      },
    }
  );
}
```

### Middleware Client (`lib/supabase/middleware.ts`)

```typescript
import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

export async function updateSession(request: NextRequest) {
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

  // Refresh the session - this is what keeps the user logged in
  const {
    data: { user },
  } = await supabase.auth.getUser();

  return { supabaseResponse, user };
}
```

---

## Step 2 - Middleware (Route Protection)

### `middleware.ts` (project root)

```typescript
import { type NextRequest, NextResponse } from "next/server";
import { updateSession } from "@/lib/supabase/middleware";

// Routes that do not need session refresh
const SKIP_SESSION_ROUTES = ["/share/", "/auth/", "/api/"];

// Routes that require authentication
const PROTECTED_ROUTES = ["/dashboard", "/settings", "/billing"];

// Routes that authenticated users should not see
const AUTH_PAGES = ["/login", "/signup"];

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;

  // Skip session refresh for public and API routes
  if (SKIP_SESSION_ROUTES.some((route) => pathname.startsWith(route))) {
    return NextResponse.next();
  }

  const { supabaseResponse, user } = await updateSession(request);

  // Protected routes - redirect to login if not authenticated
  if (PROTECTED_ROUTES.some((route) => pathname.startsWith(route))) {
    if (!user) {
      const loginUrl = new URL("/login", request.url);
      loginUrl.searchParams.set("next", pathname);
      return NextResponse.redirect(loginUrl);
    }
  }

  // Auth pages - redirect to dashboard if already authenticated
  if (AUTH_PAGES.some((page) => pathname.startsWith(page))) {
    if (user) {
      return NextResponse.redirect(new URL("/dashboard", request.url));
    }
  }

  return supabaseResponse;
}

export const config = {
  matcher: [
    // Match all routes except static files and images
    "/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
};
```

---

## Step 3 - Auth Callback Route

### `app/auth/callback/route.ts`

Handles the OAuth redirect after the user signs in with Google (or any provider).

```typescript
import { createClient } from "@/lib/supabase/server";
import { NextResponse } from "next/server";

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get("code");
  const next = searchParams.get("next") ?? "/dashboard";

  // Sanitize redirect path - must start with "/" and not "//" (open redirect)
  const sanitizedNext =
    next.startsWith("/") && !next.startsWith("//") ? next : "/dashboard";

  if (code) {
    const supabase = await createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);

    if (!error) {
      return NextResponse.redirect(`${origin}${sanitizedNext}`);
    }
  }

  // Auth error - redirect to login with error indicator
  return NextResponse.redirect(`${origin}/login?error=auth_callback_failed`);
}
```

---

## Step 4 - AuthProvider (React Context)

### `providers/AuthProvider.tsx`

```tsx
"use client";

import {
  createContext,
  useContext,
  useEffect,
  useState,
  type ReactNode,
} from "react";
import { createSupabaseBrowserClient } from "@/lib/supabase/client";
import { useRouter } from "next/navigation";
import type { User, SupabaseClient } from "@supabase/supabase-js";

interface AuthContextType {
  user: User | null;
  isLoading: boolean;
  supabase: SupabaseClient;
  signInWithGoogle: () => Promise<void>;
  signInWithEmail: (email: string, password: string) => Promise<void>;
  signUp: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  // Singleton - one Supabase client per tab
  const [supabase] = useState(() => createSupabaseBrowserClient());
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const router = useRouter();

  useEffect(() => {
    // Get initial session
    supabase.auth.getSession().then(({ data: { session } }) => {
      setUser(session?.user ?? null);
      setIsLoading(false);
    });

    // Listen for auth state changes
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null);
      setIsLoading(false);

      if (_event === "SIGNED_IN" && session?.user) {
        // Detect new signup via Google OAuth - created_at within 60 seconds
        const createdAt = new Date(session.user.created_at).getTime();
        const isNewUser = Date.now() - createdAt < 60_000;

        // PostHog identify (if using PostHog)
        // posthog.identify(session.user.id, { email: session.user.email });

        if (isNewUser) {
          // posthog.capture("user_signed_up", { provider: "google" });
        }
      }

      if (_event === "SIGNED_OUT") {
        // posthog.reset();
      }
    });

    return () => subscription.unsubscribe();
  }, [supabase]);

  const signInWithGoogle = async () => {
    await supabase.auth.signInWithOAuth({
      provider: "google",
      options: {
        redirectTo: `${window.location.origin}/auth/callback`,
      },
    });
  };

  const signInWithEmail = async (email: string, password: string) => {
    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    if (error) throw error;
    router.push("/dashboard");
  };

  const signUp = async (email: string, password: string) => {
    const { error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        emailRedirectTo: `${window.location.origin}/auth/callback`,
      },
    });
    if (error) throw error;
    // User will receive confirmation email
  };

  const signOut = async () => {
    await supabase.auth.signOut();
    router.push("/");
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        isLoading,
        supabase,
        signInWithGoogle,
        signInWithEmail,
        signUp,
        signOut,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
}
```

### Wire into Layout (`app/layout.tsx`)

```tsx
import { AuthProvider } from "@/providers/AuthProvider";

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <AuthProvider>{children}</AuthProvider>
      </body>
    </html>
  );
}
```

---

## Step 5 - Server-Side Auth

### In Server Components

```typescript
import { createClient } from "@/lib/supabase/server";

export default async function DashboardPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    // Middleware should catch this, but double-check
    redirect("/login");
  }

  return <div>Welcome, {user.email}</div>;
}
```

### In Route Handlers

```typescript
import { createClient } from "@/lib/supabase/server";
import { NextResponse } from "next/server";

export async function GET() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  // Proceed with authenticated logic
}
```

---

## Step 6 - Database Trigger for Profiles

Auto-create a profile row when a new user signs up via Supabase Auth.

```sql
-- Create profiles table
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  email text not null,
  full_name text,
  avatar_url text,
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null
);

alter table public.profiles enable row level security;

-- Users can read their own profile
create policy "profiles_select_own"
  on public.profiles for select
  using (auth.uid() = id);

-- Users can update their own profile
create policy "profiles_update_own"
  on public.profiles for update
  using (auth.uid() = id);

-- Trigger function: auto-create profile on user signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, email, full_name, avatar_url)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name'),
    new.raw_user_meta_data ->> 'avatar_url'
  );
  return new;
end;
$$;

-- Attach trigger to auth.users
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
```

---

## Step 7 - Login Page Example

### `app/(auth)/login/page.tsx`

```tsx
"use client";

import { useState } from "react";
import { useAuth } from "@/providers/AuthProvider";

export default function LoginPage() {
  const { signInWithGoogle, signInWithEmail } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const handleEmailLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError("");
    try {
      await signInWithEmail(email, password);
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : "Login failed");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center">
      <div className="w-full max-w-sm space-y-6">
        <h1 className="text-2xl font-bold text-center">Sign in</h1>

        {error && (
          <div className="rounded bg-red-50 p-3 text-sm text-red-600">
            {error}
          </div>
        )}

        {/* Google OAuth */}
        <button
          onClick={signInWithGoogle}
          className="w-full rounded-lg border px-4 py-2 font-medium hover:bg-gray-50"
        >
          Continue with Google
        </button>

        <div className="relative">
          <div className="absolute inset-0 flex items-center">
            <div className="w-full border-t" />
          </div>
          <div className="relative flex justify-center text-sm">
            <span className="bg-white px-2 text-gray-500">or</span>
          </div>
        </div>

        {/* Email/Password */}
        <form onSubmit={handleEmailLogin} className="space-y-4">
          <input
            type="email"
            placeholder="Email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            className="w-full rounded-lg border px-4 py-2"
          />
          <input
            type="password"
            placeholder="Password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            className="w-full rounded-lg border px-4 py-2"
          />
          <button
            type="submit"
            disabled={loading}
            className="w-full rounded-lg bg-black px-4 py-2 text-white hover:bg-gray-800 disabled:opacity-50"
          >
            {loading ? "Signing in..." : "Sign in"}
          </button>
        </form>

        <p className="text-center text-sm text-gray-500">
          No account?{" "}
          <a href="/signup" className="text-black underline">
            Sign up
          </a>
        </p>
      </div>
    </div>
  );
}
```

---

## Common Mistakes

| Mistake | Why it breaks | Fix |
|---------|---------------|-----|
| Using `getSession()` for server-side auth checks | Session comes from cookies and can be spoofed by the client | Always use `getUser()` on the server - it verifies against Supabase Auth |
| Not refreshing cookies in middleware | Session expires silently, user gets random logouts | Call `updateSession(request)` on every request in middleware |
| Forgetting to sanitize redirect URLs | Open redirect vulnerability - attackers can craft URLs like `/auth/callback?next=//evil.com` | Validate that `next` starts with `/` and not `//` |
| Creating multiple browser clients | Memory leaks, auth state desync between components | Use `useState(() => createSupabaseBrowserClient())` for singleton |
| Missing the `try/catch` in server `setAll` | Server Components crash because cookies cannot be set outside of Route Handlers | Wrap `setAll` in try/catch (see server client code above) |
| Not setting `emailRedirectTo` on signup | Confirmation email link goes to default Supabase URL instead of your app | Always set `options.emailRedirectTo` to your `/auth/callback` URL |
| Checking auth only in middleware | Middleware can be bypassed via direct API calls | Double-check auth in Route Handlers and Server Components |
| Using `service_role` key in the browser client | Full admin access exposed to the client | Only use the `anon` key on the client, `service_role` stays server-side |
| Not handling `SIGNED_OUT` event in AuthProvider | Stale user state after logout in another tab | Listen to `onAuthStateChange` and update state on all events |
| Storing OAuth provider config in code | Cannot change redirect URLs across environments | Use environment variables for callback URLs, build them from `window.location.origin` |

---

## Auth Setup Checklist

### Supabase Dashboard Configuration
- [ ] Enable Google OAuth provider in Authentication - Providers
- [ ] Set Google Client ID and Client Secret
- [ ] Add redirect URL: `https://your-domain.com/auth/callback`
- [ ] Add redirect URL: `http://localhost:3000/auth/callback` (for local dev)
- [ ] Configure email templates (confirmation, magic link, password reset)
- [ ] Set password policy (minimum 8 characters)

### Codebase
- [ ] `lib/supabase/client.ts` - browser client
- [ ] `lib/supabase/server.ts` - server client with cookie handling
- [ ] `lib/supabase/middleware.ts` - session refresh utility
- [ ] `middleware.ts` - route protection and session refresh
- [ ] `app/auth/callback/route.ts` - OAuth code exchange
- [ ] `providers/AuthProvider.tsx` - React context with auth methods
- [ ] `app/layout.tsx` - AuthProvider wrapped around children
- [ ] `app/(auth)/login/page.tsx` - login UI
- [ ] `app/(auth)/signup/page.tsx` - signup UI

### Database
- [ ] `profiles` table created
- [ ] RLS enabled on `profiles`
- [ ] `handle_new_user()` trigger function created
- [ ] Trigger attached to `auth.users` on insert

### Environment Variables
- [ ] `NEXT_PUBLIC_SUPABASE_URL` set
- [ ] `NEXT_PUBLIC_SUPABASE_ANON_KEY` set
- [ ] `SUPABASE_SERVICE_ROLE_KEY` set (server-side only)

---

## File Structure

```
src/
  app/
    (auth)/
      login/page.tsx
      signup/page.tsx
    auth/
      callback/route.ts
    dashboard/
      page.tsx          # Protected route
  lib/
    supabase/
      client.ts         # Browser client
      server.ts         # Server client
      middleware.ts      # Session refresh
  providers/
    AuthProvider.tsx     # React context
middleware.ts           # Root middleware
```
