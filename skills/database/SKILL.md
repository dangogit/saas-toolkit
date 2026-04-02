---
name: database
description: Supabase database operations, schema design, and RLS policies for SaaS applications. Use for: schema design, migrations, RLS setup, storage, real-time. Triggers on "create a table", "add RLS", "database schema", "write a migration", "set up real-time".
---

# database

Supabase database operations, schema design, and RLS policies for SaaS applications. Use when designing database schemas, writing migrations, setting up RLS, configuring storage, or saying "create a table", "add RLS", "database schema", "write a migration", "set up real-time".

---

## Schema Design Principles for SaaS

### Multi-Tenant Patterns

| Pattern | When to Use | Complexity |
|---------|-------------|------------|
| Row-level isolation | Most SaaS apps, shared tables with tenant_id column | Low |
| Schema-per-tenant | Strong isolation requirements, enterprise customers | High |
| Database-per-tenant | Regulatory compliance, maximum isolation | Very High |

**Recommended for most SaaS:** Row-level isolation with RLS policies. Supabase makes this straightforward.

### Naming Conventions

- Tables: `snake_case`, plural (e.g., `users`, `team_members`)
- Columns: `snake_case` (e.g., `created_at`, `team_id`)
- Primary keys: `id` as UUID
- Foreign keys: `<table_singular>_id` (e.g., `team_id`, `user_id`)
- Timestamps: always include `created_at` and `updated_at`
- Soft deletes: use `deleted_at` timestamptz (nullable)

---

## Common SaaS Tables

### Core Schema Migration

```sql
-- Enable extensions
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- Teams / Organizations
create table public.teams (
  id uuid default uuid_generate_v4() primary key,
  name text not null,
  slug text unique not null,
  logo_url text,
  plan text default 'free' not null,
  stripe_customer_id text unique,
  stripe_subscription_id text unique,
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null
);

-- Team Members (join table)
create table public.team_members (
  id uuid default uuid_generate_v4() primary key,
  team_id uuid references public.teams on delete cascade not null,
  user_id uuid references auth.users on delete cascade not null,
  role text default 'member' not null check (role in ('owner', 'admin', 'member')),
  created_at timestamptz default now() not null,
  unique(team_id, user_id)
);

-- Profiles (extends auth.users)
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  email text not null,
  full_name text,
  avatar_url text,
  current_team_id uuid references public.teams on delete set null,
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null
);

-- Subscriptions
create table public.subscriptions (
  id uuid default uuid_generate_v4() primary key,
  team_id uuid references public.teams on delete cascade not null unique,
  stripe_subscription_id text unique,
  stripe_price_id text,
  status text not null check (status in ('active', 'canceled', 'past_due', 'trialing', 'incomplete')),
  current_period_start timestamptz,
  current_period_end timestamptz,
  cancel_at_period_end boolean default false,
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null
);

-- Indexes
create index idx_team_members_team_id on public.team_members(team_id);
create index idx_team_members_user_id on public.team_members(user_id);
create index idx_subscriptions_team_id on public.subscriptions(team_id);
create index idx_teams_slug on public.teams(slug);
```

### Auto-Update Timestamps Trigger

```sql
create or replace function public.update_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- Apply to all tables with updated_at
create trigger update_teams_updated_at
  before update on public.teams
  for each row execute procedure public.update_updated_at();

create trigger update_profiles_updated_at
  before update on public.profiles
  for each row execute procedure public.update_updated_at();

create trigger update_subscriptions_updated_at
  before update on public.subscriptions
  for each row execute procedure public.update_updated_at();
```

---

## Row Level Security (RLS)

### Enable RLS on All Tables

```sql
alter table public.teams enable row level security;
alter table public.team_members enable row level security;
alter table public.profiles enable row level security;
alter table public.subscriptions enable row level security;
```

### Helper Function - Check Team Membership

```sql
create or replace function public.is_team_member(check_team_id uuid)
returns boolean
language sql
security definer
stable
as $$
  select exists (
    select 1 from public.team_members
    where team_id = check_team_id
    and user_id = auth.uid()
  );
$$;

create or replace function public.is_team_admin(check_team_id uuid)
returns boolean
language sql
security definer
stable
as $$
  select exists (
    select 1 from public.team_members
    where team_id = check_team_id
    and user_id = auth.uid()
    and role in ('owner', 'admin')
  );
$$;
```

### RLS Policy Patterns

#### Profile Policies

```sql
-- Users can read their own profile
create policy "profiles_select_own"
  on public.profiles for select
  using (auth.uid() = id);

-- Users can update their own profile
create policy "profiles_update_own"
  on public.profiles for update
  using (auth.uid() = id);

-- Users can read profiles of their team members
create policy "profiles_select_team"
  on public.profiles for select
  using (
    id in (
      select tm.user_id from public.team_members tm
      where tm.team_id in (
        select team_id from public.team_members where user_id = auth.uid()
      )
    )
  );
```

#### Team Policies

```sql
-- Team members can read their team
create policy "teams_select_member"
  on public.teams for select
  using (public.is_team_member(id));

-- Only admins/owners can update team
create policy "teams_update_admin"
  on public.teams for update
  using (public.is_team_admin(id));

-- Any authenticated user can create a team
create policy "teams_insert_auth"
  on public.teams for insert
  with check (auth.uid() is not null);
```

#### Team Member Policies

```sql
-- Members can see other members of their team
create policy "team_members_select"
  on public.team_members for select
  using (public.is_team_member(team_id));

-- Only admins can add members
create policy "team_members_insert"
  on public.team_members for insert
  with check (public.is_team_admin(team_id));

-- Only admins can remove members (not themselves)
create policy "team_members_delete"
  on public.team_members for delete
  using (public.is_team_admin(team_id) and user_id != auth.uid());
```

### RLS Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Forgetting to enable RLS | All data is publicly accessible | Always `alter table ... enable row level security` |
| Using `security invoker` in helper functions | Function runs as the calling user, may lack permissions | Use `security definer` for RLS helper functions |
| No policy for INSERT | Users cannot create records even with RLS enabled | Add explicit INSERT policies with `with check` |
| Overly permissive SELECT | Data leaks across tenants | Always scope SELECT to authenticated user's context |
| Missing index on foreign key used in RLS | Slow queries on every request | Add indexes on columns used in RLS checks |

---

## Supabase Client Usage Patterns

### Server Components (read-only)

```typescript
import { createClient } from "@/lib/supabase/server";

export default async function TeamsPage() {
  const supabase = await createClient();
  const { data: teams } = await supabase
    .from("teams")
    .select("*, team_members(count)")
    .order("created_at", { ascending: false });

  return <TeamList teams={teams} />;
}
```

### Client Components (interactive)

```typescript
"use client";
import { createClient } from "@/lib/supabase/client";

export function CreateTeamForm() {
  const supabase = createClient();

  const handleSubmit = async (formData: FormData) => {
    const { data, error } = await supabase
      .from("teams")
      .insert({ name: formData.get("name") as string, slug: generateSlug(name) })
      .select()
      .single();

    if (error) throw error;
    // handle success
  };
}
```

### Route Handlers (API routes)

```typescript
import { createClient } from "@/lib/supabase/server";
import { NextResponse } from "next/server";

export async function POST(request: Request) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const body = await request.json();
  const { data, error } = await supabase
    .from("teams")
    .insert(body)
    .select()
    .single();

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 400 });
  }

  return NextResponse.json(data);
}
```

---

## Database Migrations Workflow

```bash
# Create a new migration
pnpm supabase migration new add_feature_table

# Edit the generated SQL file in supabase/migrations/

# Apply locally
pnpm supabase db reset

# Check diff between local and remote
pnpm supabase db diff

# Push to cloud
pnpm supabase db push

# Regenerate types after schema changes
pnpm supabase gen types typescript --local > src/types/database.types.ts
```

### Migration Best Practices

- One migration per logical change (do not bundle unrelated changes)
- Never modify an existing migration that has been pushed to cloud
- Always test migrations with `db reset` locally before pushing
- Include rollback comments at the top of complex migrations
- Name migrations descriptively: `add_team_invites_table`, `add_index_on_email`

---

## Storage Buckets

### Create a Storage Bucket

```sql
-- In a migration file
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true);

-- Storage policy: users can upload their own avatar
create policy "avatar_upload"
  on storage.objects for insert
  with check (
    bucket_id = 'avatars' and
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Anyone can view avatars (public bucket)
create policy "avatar_select"
  on storage.objects for select
  using (bucket_id = 'avatars');
```

### Upload from Client

```typescript
const { data, error } = await supabase.storage
  .from("avatars")
  .upload(`${user.id}/avatar.png`, file, {
    cacheControl: "3600",
    upsert: true,
  });
```

---

## Real-Time Subscriptions

### Enable Real-Time on a Table

```sql
alter publication supabase_realtime add table public.messages;
```

### Subscribe from Client

```typescript
"use client";
import { createClient } from "@/lib/supabase/client";
import { useEffect, useState } from "react";

export function LiveMessages({ channelId }: { channelId: string }) {
  const [messages, setMessages] = useState<Message[]>([]);
  const supabase = createClient();

  useEffect(() => {
    const channel = supabase
      .channel(`messages:${channelId}`)
      .on(
        "postgres_changes",
        {
          event: "INSERT",
          schema: "public",
          table: "messages",
          filter: `channel_id=eq.${channelId}`,
        },
        (payload) => {
          setMessages((prev) => [...prev, payload.new as Message]);
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [channelId]);

  return <MessageList messages={messages} />;
}
```

---

## Performance Tips

### Indexes

```sql
-- Always index foreign keys
create index idx_messages_channel_id on public.messages(channel_id);

-- Index columns used in WHERE clauses
create index idx_users_email on public.profiles(email);

-- Composite index for common query patterns
create index idx_team_members_team_role on public.team_members(team_id, role);

-- Partial index for active records
create index idx_subscriptions_active on public.subscriptions(team_id)
  where status = 'active';
```

### Query Optimization

```typescript
// BAD: fetching everything
const { data } = await supabase.from("teams").select("*");

// GOOD: select only needed columns
const { data } = await supabase.from("teams").select("id, name, slug, plan");

// GOOD: use pagination
const { data } = await supabase
  .from("teams")
  .select("id, name")
  .range(0, 9)
  .order("created_at", { ascending: false });

// GOOD: use count without fetching all rows
const { count } = await supabase
  .from("team_members")
  .select("*", { count: "exact", head: true })
  .eq("team_id", teamId);
```

### Connection Management

- Server components: create a new client per request (this is correct, Supabase SSR handles pooling)
- Client components: create one client instance at the module level or in a provider
- Never share a server client between requests
- Use `supabase.rpc()` for complex queries to push logic to the database

---

## Common Mistakes to Avoid

| Mistake | Why It Is Bad | Do This Instead |
|---------|---------------|-----------------|
| Storing user data only in `auth.users` | Cannot add custom fields, no RLS | Create a `profiles` table that references `auth.users` |
| Skipping RLS on any public table | Data breach risk | Enable RLS on every table, no exceptions |
| Using `service_role` key on the client | Full database access exposed | Only use `service_role` in server-side code |
| Not indexing foreign keys | Slow joins and RLS checks | Add indexes on all FK columns |
| Hardcoding Supabase URL in code | Cannot switch environments | Use environment variables |
| Large payloads in real-time | Performance degradation | Only subscribe to needed columns, use filters |
| Running migrations manually via SQL editor | No version history, no rollback | Use the migration workflow (`supabase migration new`) |
