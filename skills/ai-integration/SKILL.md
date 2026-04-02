---
name: ai-integration
description: Integrate AI features into your Next.js SaaS app using the Vercel AI SDK. Use for: AI chat, streaming responses, text generation, structured output, multi-provider setup, AI analytics. Triggers on "add AI", "integrate AI", "AI chat", "streaming chat", "AI SDK", "generate text", "structured output".
---

# ai-integration

Integrate AI features into your Next.js SaaS app using the Vercel AI SDK. Use when adding AI chat, streaming responses, text generation, structured output, multi-provider setup, or AI analytics. Covers Anthropic, OpenAI, and Google providers with practical SaaS patterns.

---

## Quick Reference - AI SDK Packages

| Package | Purpose | When to Use |
|---------|---------|-------------|
| `ai` | Core SDK - streaming, generation, tools | Every AI feature |
| `@ai-sdk/anthropic` | Claude provider | Best for reasoning, long context |
| `@ai-sdk/openai` | OpenAI provider | GPT models, broad compatibility |
| `@ai-sdk/google` | Google provider | Gemini models, multimodal |
| `zod` | Schema validation | Structured output with `generateObject` |
| `@posthog/ai` | AI analytics | Tracking token usage and costs |

---

## Vercel AI SDK Setup

### Installation

```bash
# Core SDK (always needed)
pnpm add ai

# Add providers you need (pick one or more)
pnpm add @ai-sdk/anthropic
pnpm add @ai-sdk/openai
pnpm add @ai-sdk/google

# For structured output
pnpm add zod
```

### Environment Variables

```env
# Provider API keys (server-only - no NEXT_PUBLIC_ prefix)
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...
GOOGLE_GENERATIVE_AI_API_KEY=...
```

### Provider Configuration (`src/lib/ai.ts`)

```typescript
import { anthropic } from "@ai-sdk/anthropic";
import { openai } from "@ai-sdk/openai";
import { google } from "@ai-sdk/google";

// Each provider auto-reads its env var. No manual config needed.
// Use directly:
//   anthropic("claude-sonnet-4-20250514")
//   openai("gpt-4o")
//   google("gemini-2.0-flash")

// Helper to select provider by name
export function getModel(provider: string, modelId: string) {
  switch (provider) {
    case "anthropic":
      return anthropic(modelId);
    case "openai":
      return openai(modelId);
    case "google":
      return google(modelId);
    default:
      throw new Error(`Unknown provider: ${provider}`);
  }
}

// Default model for your app
export const defaultModel = anthropic("claude-sonnet-4-20250514");
```

---

## Streaming Chat (Most Common Pattern)

### Server-Side Route Handler

```typescript
// src/app/api/chat/route.ts
import { streamText } from "ai";
import { anthropic } from "@ai-sdk/anthropic";
import { createClient } from "@/lib/supabase/server";
import { NextResponse } from "next/server";

export async function POST(request: Request) {
  // Auth check
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const { messages } = await request.json();

  const result = streamText({
    model: anthropic("claude-sonnet-4-20250514"),
    system: "You are a helpful assistant for our SaaS product. Be concise and actionable.",
    messages,
    maxTokens: 1024,
  });

  return result.toDataStreamResponse();
}
```

### Client-Side Chat Component

```typescript
// src/components/chat.tsx
"use client";

import { useChat } from "ai/react";

export function Chat() {
  const { messages, input, handleInputChange, handleSubmit, isLoading, error } =
    useChat({
      api: "/api/chat",
    });

  return (
    <div className="flex flex-col h-[600px]">
      {/* Messages */}
      <div className="flex-1 overflow-y-auto space-y-4 p-4">
        {messages.map((message) => (
          <div
            key={message.id}
            className={`flex ${
              message.role === "user" ? "justify-end" : "justify-start"
            }`}
          >
            <div
              className={`rounded-lg px-4 py-2 max-w-[80%] ${
                message.role === "user"
                  ? "bg-blue-600 text-white"
                  : "bg-gray-100 text-gray-900"
              }`}
            >
              {message.content}
            </div>
          </div>
        ))}
      </div>

      {/* Error display */}
      {error && (
        <div className="px-4 py-2 text-red-500 text-sm">
          Something went wrong. Please try again.
        </div>
      )}

      {/* Input */}
      <form onSubmit={handleSubmit} className="border-t p-4 flex gap-2">
        <input
          value={input}
          onChange={handleInputChange}
          placeholder="Type a message..."
          className="flex-1 border rounded-lg px-4 py-2"
          disabled={isLoading}
        />
        <button
          type="submit"
          disabled={isLoading || !input.trim()}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg disabled:opacity-50"
        >
          {isLoading ? "..." : "Send"}
        </button>
      </form>
    </div>
  );
}
```

### useChat Options Reference

```typescript
const {
  messages,        // Message[] - conversation history
  input,           // string - current input value
  handleInputChange, // input onChange handler
  handleSubmit,    // form onSubmit handler
  isLoading,       // boolean - waiting for response
  error,           // Error | undefined
  reload,          // () => void - retry last message
  stop,            // () => void - cancel streaming
  setMessages,     // set conversation history
  append,          // programmatically add a message
} = useChat({
  api: "/api/chat",                    // endpoint (default: "/api/chat")
  initialMessages: [],                 // pre-fill conversation
  body: { userId: "123" },             // extra data sent with every request
  headers: { "X-Custom": "value" },    // extra headers
  onFinish: (message) => {},           // called when response completes
  onError: (error) => {},              // called on error
});
```

---

## Tool / Function Calling

### Defining Tools on the Server

```typescript
// src/app/api/chat/route.ts
import { streamText, tool } from "ai";
import { anthropic } from "@ai-sdk/anthropic";
import { z } from "zod";

export async function POST(request: Request) {
  const { messages } = await request.json();

  const result = streamText({
    model: anthropic("claude-sonnet-4-20250514"),
    system: "You are a helpful assistant. Use tools when appropriate.",
    messages,
    tools: {
      getWeather: tool({
        description: "Get the current weather for a location",
        parameters: z.object({
          city: z.string().describe("The city name"),
          unit: z.enum(["celsius", "fahrenheit"]).default("celsius"),
        }),
        execute: async ({ city, unit }) => {
          // Call your weather API here
          const temp = unit === "celsius" ? 22 : 72;
          return { city, temperature: temp, unit, condition: "sunny" };
        },
      }),
      searchDatabase: tool({
        description: "Search the product database",
        parameters: z.object({
          query: z.string().describe("Search query"),
          limit: z.number().default(5),
        }),
        execute: async ({ query, limit }) => {
          // Query your database
          return { results: [], total: 0 };
        },
      }),
    },
    maxSteps: 5, // Allow up to 5 tool call rounds
  });

  return result.toDataStreamResponse();
}
```

---

## Text Generation (Non-Streaming)

### generateText - Full Response at Once

```typescript
import { generateText } from "ai";
import { anthropic } from "@ai-sdk/anthropic";

export async function summarizeArticle(content: string): Promise<string> {
  const { text, usage } = await generateText({
    model: anthropic("claude-sonnet-4-20250514"),
    system: "Summarize the given article in 2-3 sentences. Be concise.",
    prompt: content,
    maxTokens: 256,
  });

  console.log(`Tokens used: ${usage.promptTokens} in, ${usage.completionTokens} out`);
  return text;
}
```

### generateObject - Structured Output with Zod

```typescript
import { generateObject } from "ai";
import { anthropic } from "@ai-sdk/anthropic";
import { z } from "zod";

const BlogPostSchema = z.object({
  title: z.string().describe("SEO-friendly blog title"),
  slug: z.string().describe("URL slug derived from title"),
  excerpt: z.string().describe("150-char meta description"),
  tags: z.array(z.string()).describe("3-5 relevant tags"),
  sections: z.array(
    z.object({
      heading: z.string(),
      content: z.string(),
    })
  ).describe("Blog post sections with headings"),
});

export async function generateBlogPost(topic: string) {
  const { object } = await generateObject({
    model: anthropic("claude-sonnet-4-20250514"),
    schema: BlogPostSchema,
    prompt: `Write a blog post about: ${topic}`,
  });

  // object is fully typed as z.infer<typeof BlogPostSchema>
  return object;
}
```

### generateObject - Enum Classification

```typescript
import { generateObject } from "ai";
import { anthropic } from "@ai-sdk/anthropic";
import { z } from "zod";

const SentimentSchema = z.object({
  sentiment: z.enum(["positive", "negative", "neutral"]),
  confidence: z.number().min(0).max(1),
  reason: z.string(),
});

export async function classifySentiment(text: string) {
  const { object } = await generateObject({
    model: anthropic("claude-sonnet-4-20250514"),
    schema: SentimentSchema,
    prompt: `Classify the sentiment of this text: "${text}"`,
  });

  return object;
}
```

---

## AI Route Handler Patterns

### Rate Limiting AI Endpoints

```typescript
// src/app/api/chat/route.ts
import { Ratelimit } from "@upstash/ratelimit";
import { Redis } from "@upstash/redis";
import { streamText } from "ai";
import { anthropic } from "@ai-sdk/anthropic";
import { createClient } from "@/lib/supabase/server";
import { NextResponse } from "next/server";

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(20, "1 h"), // 20 requests per hour
  prefix: "ai-chat",
});

export async function POST(request: Request) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  // Rate limit by user ID
  const { success, remaining, reset } = await ratelimit.limit(user.id);

  if (!success) {
    return NextResponse.json(
      { error: "Rate limit exceeded. Try again later." },
      {
        status: 429,
        headers: {
          "X-RateLimit-Remaining": remaining.toString(),
          "X-RateLimit-Reset": reset.toString(),
        },
      }
    );
  }

  const { messages } = await request.json();

  const result = streamText({
    model: anthropic("claude-sonnet-4-20250514"),
    messages,
    maxTokens: 1024,
  });

  return result.toDataStreamResponse();
}
```

### Token Usage Tracking

```typescript
// src/lib/ai-usage.ts
import { createClient } from "@supabase/supabase-js";

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

export async function trackUsage(
  userId: string,
  model: string,
  promptTokens: number,
  completionTokens: number
) {
  await supabase.from("ai_usage").insert({
    user_id: userId,
    model,
    prompt_tokens: promptTokens,
    completion_tokens: completionTokens,
    total_tokens: promptTokens + completionTokens,
    estimated_cost: estimateCost(model, promptTokens, completionTokens),
    created_at: new Date().toISOString(),
  });
}

function estimateCost(
  model: string,
  promptTokens: number,
  completionTokens: number
): number {
  // Cost per 1M tokens (update these as pricing changes)
  const pricing: Record<string, { input: number; output: number }> = {
    "claude-sonnet-4-20250514": { input: 3.0, output: 15.0 },
    "gpt-4o": { input: 2.5, output: 10.0 },
    "gemini-2.0-flash": { input: 0.10, output: 0.40 },
  };

  const rates = pricing[model] ?? { input: 1.0, output: 3.0 };
  return (
    (promptTokens / 1_000_000) * rates.input +
    (completionTokens / 1_000_000) * rates.output
  );
}
```

### Using Token Tracking in Route Handlers

```typescript
// src/app/api/chat/route.ts
import { streamText } from "ai";
import { anthropic } from "@ai-sdk/anthropic";
import { trackUsage } from "@/lib/ai-usage";

export async function POST(request: Request) {
  // ... auth check ...
  const { messages } = await request.json();

  const result = streamText({
    model: anthropic("claude-sonnet-4-20250514"),
    messages,
    maxTokens: 1024,
    onFinish: async ({ usage }) => {
      await trackUsage(
        user.id,
        "claude-sonnet-4-20250514",
        usage.promptTokens,
        usage.completionTokens
      );
    },
  });

  return result.toDataStreamResponse();
}
```

### Error Handling for AI Routes

```typescript
// src/app/api/chat/route.ts
import { streamText, APICallError } from "ai";
import { anthropic } from "@ai-sdk/anthropic";
import { NextResponse } from "next/server";

export async function POST(request: Request) {
  // ... auth check ...

  try {
    const { messages } = await request.json();

    const result = streamText({
      model: anthropic("claude-sonnet-4-20250514"),
      messages,
      maxTokens: 1024,
    });

    return result.toDataStreamResponse();
  } catch (error) {
    if (error instanceof APICallError) {
      // Provider returned an error (rate limit, invalid key, etc.)
      console.error("AI API error:", error.message, error.statusCode);

      if (error.statusCode === 429) {
        return NextResponse.json(
          { error: "AI service is busy. Please try again in a moment." },
          { status: 429 }
        );
      }

      return NextResponse.json(
        { error: "AI service unavailable. Please try again later." },
        { status: 503 }
      );
    }

    console.error("Unexpected error:", error);
    return NextResponse.json(
      { error: "Something went wrong." },
      { status: 500 }
    );
  }
}
```

---

## Multi-Provider Support

### Provider Switching Based on Feature or Plan

```typescript
// src/lib/ai.ts
import { anthropic } from "@ai-sdk/anthropic";
import { openai } from "@ai-sdk/openai";
import { google } from "@ai-sdk/google";
import type { LanguageModel } from "ai";

type UserPlan = "free" | "pro" | "enterprise";

// Different models for different plan tiers
export function getModelForPlan(plan: UserPlan): LanguageModel {
  switch (plan) {
    case "free":
      return google("gemini-2.0-flash"); // cheapest
    case "pro":
      return anthropic("claude-sonnet-4-20250514");
    case "enterprise":
      return anthropic("claude-sonnet-4-20250514"); // best reasoning
    default:
      return google("gemini-2.0-flash");
  }
}
```

### Fallback Pattern

```typescript
import { generateText, APICallError } from "ai";
import { anthropic } from "@ai-sdk/anthropic";
import { openai } from "@ai-sdk/openai";
import type { LanguageModel } from "ai";

const fallbackChain: LanguageModel[] = [
  anthropic("claude-sonnet-4-20250514"),
  openai("gpt-4o"),
  openai("gpt-4o-mini"),
];

export async function generateWithFallback(prompt: string): Promise<string> {
  for (const model of fallbackChain) {
    try {
      const { text } = await generateText({
        model,
        prompt,
        maxTokens: 1024,
      });
      return text;
    } catch (error) {
      if (error instanceof APICallError) {
        console.warn(`Provider failed, trying next: ${error.message}`);
        continue;
      }
      throw error; // re-throw non-API errors
    }
  }

  throw new Error("All AI providers failed");
}
```

---

## Common SaaS AI Features

### Chat Interface (Customer Support / Copilot)

```typescript
// src/app/api/chat/route.ts
import { streamText } from "ai";
import { anthropic } from "@ai-sdk/anthropic";
import { createClient } from "@/lib/supabase/server";

export async function POST(request: Request) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return new Response("Unauthorized", { status: 401 });
  }

  const { messages } = await request.json();

  // Load user context for personalized responses
  const { data: profile } = await supabase
    .from("profiles")
    .select("name, plan, company")
    .eq("id", user.id)
    .single();

  const result = streamText({
    model: anthropic("claude-sonnet-4-20250514"),
    system: `You are a helpful assistant for ${profile?.company ?? "our product"}.
The user's name is ${profile?.name ?? "there"} and they are on the ${profile?.plan ?? "free"} plan.
Be concise, helpful, and reference relevant features of their plan.`,
    messages,
    maxTokens: 1024,
  });

  return result.toDataStreamResponse();
}
```

### Content Generation

```typescript
import { generateObject } from "ai";
import { anthropic } from "@ai-sdk/anthropic";
import { z } from "zod";

const SocialPostSchema = z.object({
  twitter: z.string().max(280).describe("Tweet-length post"),
  linkedin: z.string().describe("Professional LinkedIn post"),
  emailSubject: z.string().describe("Email subject line"),
  emailBody: z.string().describe("Short promotional email body"),
});

export async function generateSocialContent(
  productName: string,
  announcement: string
) {
  const { object } = await generateObject({
    model: anthropic("claude-sonnet-4-20250514"),
    schema: SocialPostSchema,
    prompt: `Generate social media content for ${productName}. Announcement: ${announcement}`,
  });

  return object;
}
```

### Data Analysis and Summarization

```typescript
import { generateObject } from "ai";
import { anthropic } from "@ai-sdk/anthropic";
import { z } from "zod";

const AnalysisSchema = z.object({
  summary: z.string().describe("2-3 sentence summary of the data"),
  keyInsights: z.array(z.string()).describe("Top 3-5 insights"),
  trend: z.enum(["improving", "declining", "stable"]),
  recommendations: z.array(z.string()).describe("Actionable recommendations"),
});

export async function analyzeData(data: Record<string, unknown>[]) {
  const { object } = await generateObject({
    model: anthropic("claude-sonnet-4-20250514"),
    schema: AnalysisSchema,
    prompt: `Analyze this dataset and provide insights:\n${JSON.stringify(data, null, 2)}`,
    maxTokens: 1024,
  });

  return object;
}
```

### AI-Powered Search

```typescript
import { embed } from "ai";
import { openai } from "@ai-sdk/openai";
import { createClient } from "@supabase/supabase-js";

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

export async function semanticSearch(query: string, limit = 5) {
  // Generate embedding for the query
  const { embedding } = await embed({
    model: openai.embedding("text-embedding-3-small"),
    value: query,
  });

  // Search using pgvector similarity
  const { data: results } = await supabase.rpc("match_documents", {
    query_embedding: embedding,
    match_threshold: 0.7,
    match_count: limit,
  });

  return results;
}
```

Supabase SQL function for vector search:

```sql
-- Run this as a migration
create or replace function match_documents(
  query_embedding vector(1536),
  match_threshold float,
  match_count int
)
returns table (
  id uuid,
  content text,
  similarity float
)
language sql stable
as $$
  select
    id,
    content,
    1 - (embedding <=> query_embedding) as similarity
  from documents
  where 1 - (embedding <=> query_embedding) > match_threshold
  order by embedding <=> query_embedding
  limit match_count;
$$;
```

---

## PostHog AI Analytics

### Setup

```bash
pnpm add @posthog/ai posthog-node
```

### Wrapping AI SDK with PostHog Tracking

```typescript
// src/lib/ai-analytics.ts
import { PostHogAI } from "@posthog/ai";
import { PostHog } from "posthog-node";

const phClient = new PostHog(process.env.NEXT_PUBLIC_POSTHOG_KEY!, {
  host: process.env.NEXT_PUBLIC_POSTHOG_HOST ?? "https://us.i.posthog.com",
});

export const posthogAI = new PostHogAI({
  client: phClient,
});
```

### Tracking AI Calls

```typescript
import { generateText } from "ai";
import { anthropic } from "@ai-sdk/anthropic";
import { posthogAI } from "@/lib/ai-analytics";

export async function POST(request: Request) {
  // ... auth check ...
  const { messages } = await request.json();

  const result = await generateText({
    model: posthogAI.wrapModel(anthropic("claude-sonnet-4-20250514")),
    messages,
    maxTokens: 1024,
    experimental_telemetry: PostHogAI.telemetry({
      posthogDistinctId: user.id,
      posthogProperties: {
        plan: user.plan,
        feature: "chat",
      },
    }),
  });

  return new Response(result.text);
}
```

### What PostHog Tracks Automatically

| Metric | Description |
|--------|-------------|
| Token usage | Input/output tokens per call |
| Model used | Which model handled the request |
| Latency | Time to first token and total time |
| Cost estimate | Based on model pricing |
| Error rates | Failed API calls by model/provider |
| User-level usage | Per-user AI consumption |

---

## Best Practices

### Streaming for UX

Always stream long responses. Users perceive streaming as faster even when total time is the same.

```typescript
// Good - stream for chat and long content
const result = streamText({ model, messages });
return result.toDataStreamResponse();

// OK - non-streaming for short, structured output
const { object } = await generateObject({ model, schema, prompt });
return NextResponse.json(object);
```

**Rule of thumb:** if the response will be more than a sentence or two, stream it.

### Token Budgets and Cost Control

```typescript
// Set per-request limits
const result = streamText({
  model: anthropic("claude-sonnet-4-20250514"),
  messages,
  maxTokens: 1024, // Cap output tokens
});

// Set per-user monthly budgets
async function checkBudget(userId: string): Promise<boolean> {
  const { data } = await supabase
    .from("ai_usage")
    .select("estimated_cost")
    .eq("user_id", userId)
    .gte("created_at", startOfMonth());

  const totalCost = data?.reduce((sum, row) => sum + row.estimated_cost, 0) ?? 0;
  const budget = 5.0; // $5/month for free tier
  return totalCost < budget;
}
```

### Prompt Management

Keep prompts out of route handlers for maintainability.

```typescript
// src/lib/prompts.ts
export const PROMPTS = {
  chatAssistant: `You are a helpful assistant for our SaaS product.
Be concise and actionable. Do not make up features that do not exist.
If you are unsure, say so.`,

  contentWriter: `You are a professional content writer.
Write in a clear, engaging style. Avoid jargon unless the audience expects it.
Match the specified tone and format exactly.`,

  dataAnalyst: `You are a data analyst. Given raw data, provide:
1. A brief summary
2. Key insights (prioritize actionable ones)
3. Trend direction
4. Specific recommendations`,
} as const;
```

### Caching AI Responses

Cache deterministic or slow-changing AI outputs to save cost and latency.

```typescript
import { Redis } from "@upstash/redis";

const redis = Redis.fromEnv();

export async function cachedGenerate(
  cacheKey: string,
  generateFn: () => Promise<string>,
  ttlSeconds = 3600
): Promise<string> {
  // Check cache first
  const cached = await redis.get<string>(cacheKey);
  if (cached) return cached;

  // Generate and cache
  const result = await generateFn();
  await redis.set(cacheKey, result, { ex: ttlSeconds });
  return result;
}

// Usage
const summary = await cachedGenerate(
  `summary:${articleId}`,
  () => summarizeArticle(articleContent),
  86400 // cache for 24 hours
);
```

### Rate Limiting to Prevent Abuse

| Plan | Requests/hour | Max tokens/request | Monthly budget |
|------|---------------|-------------------|----------------|
| Free | 20 | 512 | $5 |
| Pro | 100 | 2048 | $50 |
| Enterprise | 500 | 4096 | Custom |

Enforce these limits at the route handler level (see Rate Limiting section above).

---

## Common Mistakes

| Mistake | Why It's Wrong | Fix |
|---------|---------------|-----|
| No auth on AI routes | Anyone can burn your API credits | Always check auth before calling AI |
| No rate limiting | One user can exhaust your budget | Use Upstash Ratelimit per user |
| Not streaming chat responses | UI feels slow and unresponsive | Use `streamText` + `useChat` for chat |
| Hardcoding prompts in route handlers | Hard to maintain, test, and iterate | Extract prompts to `src/lib/prompts.ts` |
| No token limits (`maxTokens`) | Unbounded cost per request | Always set `maxTokens` |
| Exposing API keys to client | Keys stolen from browser bundle | Keep keys server-side only (no `NEXT_PUBLIC_`) |
| No error handling for API failures | App crashes on provider outage | Catch `APICallError`, return user-friendly message |
| Using `generateText` for chat | Users stare at blank screen | Use `streamText` for anything conversational |
| No usage tracking | Cannot attribute costs or enforce limits | Track tokens per user in database |
| Ignoring provider rate limits | 429 errors crash your feature | Implement fallback chain across providers |
| Giant context windows by default | Costs scale linearly with input tokens | Trim conversation history, summarize old messages |
| No fallback provider | Single point of failure | Set up 2-3 providers with automatic fallback |

---

## AI Database Schema

Minimal schema for tracking AI usage in your SaaS:

```sql
-- AI usage tracking
create table ai_usage (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) not null,
  model text not null,
  prompt_tokens int not null default 0,
  completion_tokens int not null default 0,
  total_tokens int not null default 0,
  estimated_cost numeric(10, 6) not null default 0,
  feature text, -- 'chat', 'content-gen', 'search', etc.
  created_at timestamptz not null default now()
);

-- Index for querying user usage
create index idx_ai_usage_user_date on ai_usage (user_id, created_at desc);

-- Monthly usage view
create view ai_usage_monthly as
select
  user_id,
  date_trunc('month', created_at) as month,
  sum(total_tokens) as total_tokens,
  sum(estimated_cost) as total_cost,
  count(*) as request_count
from ai_usage
group by user_id, date_trunc('month', created_at);
```

---

## Integration Checklist

### Before Going Live
- [ ] AI routes protected with authentication
- [ ] Rate limiting configured per user/plan
- [ ] `maxTokens` set on every AI call
- [ ] API keys stored as server-only env vars (no `NEXT_PUBLIC_`)
- [ ] Error handling covers provider outages and rate limits
- [ ] Token usage tracked per user
- [ ] Monthly budget limits enforced
- [ ] Prompts extracted to a dedicated file
- [ ] Streaming used for all chat/conversational features
- [ ] Fallback provider configured for critical features
- [ ] PostHog AI analytics wired up for cost visibility
- [ ] AI usage table and indexes created in database
