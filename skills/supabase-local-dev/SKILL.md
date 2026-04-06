---
name: supabase-local-dev
description: Supabase local development workflow - running locally, migrations, seeding, and syncing with remote projects. Use when setting up local Supabase, creating migrations, or managing database changes.
---

# Supabase Local Development

## Why Develop Locally

- **Speed.** No network latency. Instant feedback.
- **Safety.** Can't accidentally break production data.
- **Offline.** Works without internet.
- **Free.** No usage limits on local instance.

## Setup

### Prerequisites
- Docker Desktop installed and running
- Supabase CLI installed (`brew install supabase/tap/supabase` or via nCode installer)

### Initialize
```bash
# In your project root
supabase init

# Start local Supabase (first time takes a few minutes to pull images)
supabase start
```

This starts local versions of:
- PostgreSQL on port 54322
- Supabase Studio (dashboard) on port 54323
- Auth on port 54321
- Storage on port 54321
- Edge Functions on port 54321

### Local Connection Details
After `supabase start`, you'll see:

```
API URL: http://127.0.0.1:54321
DB URL: postgresql://postgres:postgres@127.0.0.1:54322/postgres
Studio URL: http://127.0.0.1:54323
anon key: eyJhbGciOiJI...
service_role key: eyJhbGciOiJI...
```

Put these in `.env.local`:
```bash
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=eyJhbGciOiJI...  # from supabase start output
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJI...  # from supabase start output
```

## Migrations

### Create a migration
```bash
# After making changes in local Studio or SQL
supabase db diff -f create_users_table
# Creates: supabase/migrations/20260406120000_create_users_table.sql
```

### Apply migrations
```bash
# Apply to local
supabase db reset  # Drops and recreates from migrations

# Apply to remote (staging or production)
supabase db push --linked
```

### Link to remote project
```bash
# Link to your Supabase project
supabase link --project-ref your-project-ref

# Pull remote schema to local
supabase db pull
```

## Seed Data

Create `supabase/seed.sql` for test data:

```sql
-- Test users
INSERT INTO auth.users (id, email, raw_user_meta_data)
VALUES
  ('d0e1f2a3-b4c5-6789-0abc-def123456789', 'test@example.com', '{"name": "Test User"}');

-- Test data
INSERT INTO public.projects (id, name, user_id)
VALUES
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'My Test Project', 'd0e1f2a3-b4c5-6789-0abc-def123456789');
```

Seed runs automatically on `supabase db reset`.

## Daily Workflow

```bash
# Start of day
supabase start              # Start local Supabase

# During development
supabase db diff -f my_change  # Capture schema changes as migration

# End of day
supabase stop               # Stop local Supabase (data persists)
```

## Common Issues

### Docker not running
```
Error: Cannot connect to the Docker daemon
```
Fix: Open Docker Desktop and wait for it to start.

### Port conflicts
```
Error: port 54321 is already in use
```
Fix: `supabase stop` then `supabase start`, or check what's using the port.

### Reset everything
```bash
supabase db reset  # Drops DB, re-runs all migrations + seed
```
