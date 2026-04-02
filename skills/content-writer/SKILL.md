---
name: content-writer
description: Generate marketing content, blog posts, social media posts, and email copy for SaaS products. Write compelling copy that drives signups and engagement. Use for: blog posts, email sequences, changelogs, social media. Triggers on "write a blog post", "marketing copy", "email sequence", "Product Hunt copy".
---

# content-writer

> Generate marketing content, blog posts, social media posts, and email copy for SaaS products. Write compelling copy that drives signups and engagement.

**Trigger phrases:** "write a blog post", "social media content", "email sequence", "Product Hunt copy", "changelog", "marketing copy", "content strategy", "release notes", "Twitter thread", "LinkedIn post", "welcome email"

---

## Blog Post Writing Framework

### Structure for SEO-Optimized Posts

```
Title (H1) - Include primary keyword, 50-60 chars
Introduction (2-3 paragraphs) - Hook, context, promise
  H2: Section 1 - Address the core topic
    H3: Subsection if needed
  H2: Section 2 - Go deeper or cover next angle
  H2: Section 3 - Practical advice / how-to
  H2: Key Takeaways or Summary
CTA - Link to product, newsletter, or related content
```

### Blog Post Types for SaaS

| Type | Purpose | Example Title |
|------|---------|---------------|
| How-to guide | Drive organic traffic | "How to Reduce SaaS Churn by 30%" |
| Comparison | Capture buying intent | "Intercom vs Zendesk: Which Is Right for You?" |
| Listicle | Easy sharing, broad reach | "7 Metrics Every SaaS Founder Should Track" |
| Case study | Social proof, conversion | "How Acme Grew MRR 5x Using ProductName" |
| Industry analysis | Thought leadership | "The State of SaaS Pricing in 2026" |
| Tutorial | Product awareness | "Building a Dashboard with ProductName API" |

### Writing Rules

- Lead with value, not your product
- Use short paragraphs (2-4 sentences max)
- Include data points and specific numbers
- Add internal links to your product pages naturally
- End every post with a relevant CTA
- Target 1,200-2,000 words for SEO posts
- Use subheadings every 200-300 words
- Add a table of contents for posts over 1,500 words

### Blog Post Template

```markdown
# [Number] Ways to [Achieve Desired Outcome] [Qualifier]

[Hook - a surprising stat, question, or bold statement]

[Context - why this matters to the reader]

[Promise - what they'll learn by reading]

## 1. [First Point]

[Explanation with specific details]

[Example or data point]

> "Quote from expert or customer if available"

## 2. [Second Point]

...

## Key Takeaways

- [Takeaway 1]
- [Takeaway 2]
- [Takeaway 3]

---

**Ready to [desired outcome]?** [ProductName] helps you [specific benefit].
[Try it free](https://yourdomain.com/signup) - no credit card required.
```

---

## Social Media Content

### Twitter/X Thread Formula

**Thread structure:**
```
Tweet 1 (Hook): Bold claim or surprising stat - makes people stop scrolling
Tweet 2-6 (Body): One insight per tweet, numbered
Tweet 7 (Wrap): Summary + CTA

Each tweet: 240 chars max for readability (leave room for engagement)
```

**Thread templates:**

Template 1 - Lessons learned:
```
I've been building [product] for [time].

Here are [N] lessons I wish I knew on day 1:

(thread)
```

Template 2 - Behind the scenes:
```
We just hit [milestone].

Here's exactly how we did it:
```

Template 3 - Contrarian take:
```
Hot take: [common belief] is wrong.

Here's why:
```

### LinkedIn Post Formula

```
[Hook line - grab attention in the feed preview]

[Blank line]

[3-5 short paragraphs telling a story or sharing insight]

[Each paragraph is 1-2 sentences]

[Key insight or lesson]

[Question to drive comments]

#SaaS #Startup #RelevantHashtag (max 3-5 hashtags)
```

**LinkedIn rules:**
- First line is everything - it determines if people click "see more"
- Use line breaks generously (single-sentence paragraphs)
- Tell a story with a lesson
- End with a question to drive comments
- Post between 8-10am on Tuesday-Thursday
- 1,000-1,300 characters performs best

### Instagram Captions (for product accounts)

- Lead with the hook (first line visible in feed)
- Use emojis sparingly as bullet points
- Include a CTA: "Link in bio", "Save this for later", "Tag someone who needs this"
- 5-10 relevant hashtags at the end
- Keep it conversational
- Best for: product tips, behind-the-scenes, team culture, customer wins

---

## Email Marketing Templates

### Welcome Sequence (5 emails over 7 days)

| Day | Email | Purpose |
|-----|-------|---------|
| 0 | Welcome + quick win | Get them to experience value immediately |
| 1 | Key feature tutorial | Show the most valuable feature |
| 3 | Social proof | Share a customer success story |
| 5 | Overcome objection | Address the #1 reason people don't buy |
| 7 | Soft sell | Upgrade CTA with urgency |

### Welcome Email Template

```
Subject: Welcome to [Product] - here's your first step

Hi [Name],

Thanks for signing up for [Product].

The fastest way to get value is to [one specific action].
It takes about 2 minutes:

[Button: Do the thing]

If you get stuck, just reply to this email.
I read every message.

[Founder name]
Founder, [Product]

P.S. Here's a 2-minute video walkthrough if you prefer:
[Link]
```

### Feature Announcement Email

```
Subject: New: [Feature name] is here

Hi [Name],

You asked for [feature]. We built it.

[One sentence explaining what it does]

Here's how it works:
1. [Step 1]
2. [Step 2]
3. [Step 3]

[Screenshot or GIF]

[Button: Try it now]

This is available on [plan] and above.

Questions? Reply to this email.

[Name]
```

### Email Writing Rules

- Subject lines: 6-10 words, create curiosity or state benefit
- Preview text: complement the subject line, don't repeat it
- One CTA per email (one link, one button)
- Write like a human - first person, conversational
- Keep emails under 200 words for transactional, under 400 for newsletters
- Test send times: Tuesday-Thursday, 9-11am recipient's time zone

---

## Product Hunt Launch Copy

### Tagline (60 chars max)
Formula: `[What it does] for [who it's for]`
- "AI-powered analytics for indie SaaS founders"
- "The fastest way to build and ship landing pages"

### First Comment Template

```
Hey Product Hunt!

I'm [Name], founder of [Product].

I built [Product] because [personal story / pain point].

Here's what makes it different:

- [Differentiator 1]
- [Differentiator 2]
- [Differentiator 3]

We're offering [special deal] for the PH community today.

I'd love your feedback. What features would you want to see next?
```

### Product Hunt Description (500 chars)

```
[Product] helps [audience] [achieve outcome] by [how it works].

Key features:
- [Feature 1]: [benefit]
- [Feature 2]: [benefit]
- [Feature 3]: [benefit]

Built with [notable tech] for [speed/reliability/etc].
Free to start, no credit card required.
```

---

## Changelog / Release Notes

### Format

```markdown
## v2.4.0 - April 2026

### New
- **Dashboard redesign** - Cleaner layout with customizable widgets.
  See it in action: [screenshot]
- **CSV export** - Export any report to CSV with one click.

### Improved
- Search is now 3x faster on large datasets
- Onboarding flow simplified from 5 steps to 3

### Fixed
- Charts no longer flicker on Safari
- Password reset emails were delayed by up to 10 minutes
```

### Rules
- Lead with what users care about most
- Use plain language (not technical jargon)
- Group by: New, Improved, Fixed
- Include screenshots or GIFs for visual changes
- Link to docs for complex features
- Keep each item to 1-2 sentences
- Publish consistently (weekly or bi-weekly)

---

## Customer Testimonial Formatting

### What to Capture

| Element | Required? | Example |
|---------|-----------|---------|
| Quote | Yes | "ProductName cut our onboarding time in half" |
| Full name | Yes | Sarah Chen |
| Title | Yes | Head of Growth |
| Company | Yes | Acme Corp |
| Photo | Recommended | Headshot |
| Logo | Recommended | Company logo |
| Metric | Ideal | "40% reduction in churn" |

### Formats

**Short (for landing pages):**
```
"ProductName cut our onboarding time in half."
- Sarah Chen, Head of Growth at Acme Corp
```

**Long (for case studies):**
```
Challenge: Acme Corp was losing 15% of new users during onboarding.
Solution: They implemented ProductName's guided setup flow.
Result: Onboarding completion jumped from 60% to 85% in 30 days.

"We tried everything before ProductName. Nothing else came close."
- Sarah Chen, Head of Growth
```

### How to Ask for Testimonials

Send this email after a positive interaction:
```
Subject: Quick favor (30 seconds)

Hi [Name],

You mentioned [Product] has been working well for [specific use case].

Would you mind sharing a quick quote I can use on our site?

Something like: "[Product] helped us [result]."

Totally fine to keep it short. I can draft something based on
our conversation if you'd prefer to just approve it.

Thanks!
[Your name]
```

---

## Landing Page Copy Formulas

### PAS (Problem - Agitate - Solution)
```
Problem: "Tired of losing users during onboarding?"
Agitate: "Every drop-off is revenue walking out the door."
Solution: "ProductName guides users to their aha moment in minutes."
```

### BAB (Before - After - Bridge)
```
Before: "You're manually tracking metrics in spreadsheets."
After: "Imagine a live dashboard updating in real-time."
Bridge: "ProductName connects to your data and builds it for you."
```

### 4 U's (Urgent, Unique, Ultra-specific, Useful)
```
"Get your first paying customer this week
with the only no-code billing system built for solo founders."
```

---

## Tone of Voice Guidelines for SaaS

### Default SaaS Tone

| Do | Don't |
|----|-------|
| Be direct and clear | Use buzzwords or jargon |
| Write conversationally | Write like a press release |
| Use "you" and "your" | Use "one" or passive voice |
| Be specific with numbers | Make vague claims |
| Show confidence without arrogance | Overpromise |
| Use contractions (we're, you'll) | Sound robotic |

### Tone Variations by Context

| Context | Tone | Example |
|---------|------|---------|
| Landing page | Confident, benefit-focused | "Ship faster. Grow smarter." |
| Blog post | Helpful, educational | "Here's how to set up..." |
| Error message | Empathetic, solution-oriented | "Something went wrong. Try again or contact support." |
| Changelog | Excited but factual | "New: Dashboard redesign with customizable widgets" |
| Onboarding | Encouraging, simple | "Great job! You've set up your first project." |
| Pricing page | Transparent, no-pressure | "Start free. Upgrade when you're ready." |

---

## AI Writing Humanization Tips

### Patterns to Avoid

| AI Pattern | Human Alternative |
|------------|------------------|
| "In today's fast-paced world..." | Start with a specific detail or stat |
| "It's important to note that..." | Just state the thing directly |
| "This comprehensive guide will..." | "Here's how to..." |
| "Leverage", "utilize", "facilitate" | "Use", "use", "help" |
| "At the end of the day" | Cut it entirely |
| "In conclusion" | Just conclude naturally |
| Three-part lists of adjectives | Pick the strongest one |
| Starting every paragraph the same way | Vary sentence structure |
| Perfect grammar throughout | Use fragments. Like this. |
| Overly balanced "on the other hand" | Take a stance |

### Tips for Human-Sounding Copy
- Read it out loud - if it sounds weird spoken, rewrite it
- Add specific details (names, numbers, dates)
- Include one imperfect sentence per section
- Use short sentences mixed with longer ones
- Reference real events, tools, or people
- Have a point of view - don't hedge everything
- Cut any sentence that adds words but not meaning

---

## Content Calendar Suggestions

### Monthly Content Mix for Early-Stage SaaS

| Week | Content | Channels |
|------|---------|----------|
| 1 | Blog post (SEO-optimized how-to) | Blog, Twitter, LinkedIn |
| 2 | Feature highlight or tutorial | Blog, Twitter, email newsletter |
| 3 | Customer story or case study | Blog, LinkedIn, email |
| 4 | Industry insight or opinion piece | Blog, Twitter thread, LinkedIn |

### Weekly Social Cadence

| Day | Twitter/X | LinkedIn |
|-----|-----------|----------|
| Monday | Product tip or trick | Industry insight |
| Tuesday | Behind-the-scenes / building in public | - |
| Wednesday | Thread (educational) | Customer win or case study |
| Thursday | Engagement (question or poll) | Product update |
| Friday | Casual / personality | - |

### Content Repurposing Chain

```
Blog post (1,500 words)
  -> Twitter thread (7 tweets)
  -> LinkedIn post (summary + insight)
  -> Email newsletter segment
  -> 3 social media graphics (key stats)
  -> Short video script (60 seconds)
```

One blog post should fuel a full week of content across channels.
