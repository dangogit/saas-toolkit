---
name: landing-page
description: Build high-converting SaaS landing pages with proven formulas, optimized CTAs, and mobile-first design using Next.js, Tailwind, and shadcn/ui. Use for: hero sections, CTA optimization, landing page copy. Triggers on "build a landing page", "hero section", "above the fold", "convert visitors".
---

# landing-page

> Build high-converting SaaS landing pages with proven formulas, optimized CTAs, and mobile-first design. Use Next.js + Tailwind + shadcn/ui.

**Trigger phrases:** "build a landing page", "create a landing page", "landing page design", "hero section", "above the fold", "CTA optimization", "landing page copy", "convert visitors"

---

## Above-the-Fold Formula

The first screen a visitor sees determines whether they stay or bounce. Every element must earn its place.

| Element | Purpose | Rule |
|---------|---------|------|
| Headline | Hook attention, state value | Max 10 words, benefit-driven |
| Subheadline | Clarify the headline | 1-2 sentences, explain how/what |
| CTA Button | Drive the primary action | One clear action, contrasting color |
| Hero Visual | Show the product in action | Screenshot, video, or illustration |
| Social Proof | Build instant trust | Logos, user count, or rating |

### Layout Pattern

```
[ Nav: Logo + Links + CTA Button ]
[ Headline (H1) ]
[ Subheadline (p) ]
[ CTA Button ] [ Secondary CTA (optional) ]
[ Hero Image / Product Screenshot ]
[ Social Proof Bar: logos or "Trusted by 5,000+ teams" ]
```

---

## Headline Formulas That Convert

### Formula 1: [Action] + [Outcome] + [Timeframe]
- "Launch your SaaS in days, not months"
- "Automate your invoicing in under 5 minutes"

### Formula 2: [Outcome] without [Pain Point]
- "Beautiful dashboards without writing CSS"
- "Customer insights without the survey fatigue"

### Formula 3: The [Better Alternative] for [Audience]
- "The Stripe Atlas for solo founders"
- "The Notion alternative built for developers"

### Formula 4: Stop [Pain], Start [Desired Outcome]
- "Stop chasing payments. Start getting paid on time."
- "Stop guessing. Start knowing what your users want."

### Formula 5: [Number] + [Benefit]
- "10x faster deployments for engineering teams"
- "3 clicks to your first customer survey"

### What Makes Headlines Fail

| Mistake | Example | Fix |
|---------|---------|-----|
| Too vague | "The future of work" | "Ship features 3x faster" |
| Too long | 20+ words | Cut to 10 words max |
| Feature-focused | "AI-powered analytics engine" | "Know exactly why users churn" |
| Jargon-heavy | "Leverage synergistic workflows" | "Get more done with less effort" |

---

## CTA Button Best Practices

### Text Rules
- Use first person: "Start my free trial" beats "Start your free trial"
- Lead with a verb: "Get", "Start", "Try", "Create", "Build"
- Add urgency or value: "Get started free" not just "Submit"
- Keep it short: 2-5 words max

### Design Rules
- Contrasting color from the page background
- Minimum 44px height for touch targets
- Padding: at least `px-6 py-3`
- Rounded corners (`rounded-lg` or `rounded-full`)
- Hover state with slight scale or color shift

### Placement Rules
- Primary CTA: above the fold, always visible
- Repeat CTA: after each major section
- Final CTA: last section before footer, with urgency
- Sticky CTA: consider a sticky header CTA on mobile

### shadcn/ui Implementation

```tsx
import { Button } from "@/components/ui/button";

{/* Primary CTA */}
<Button size="lg" className="text-lg px-8 py-6">
  Start my free trial
</Button>

{/* Secondary CTA */}
<Button variant="outline" size="lg">
  See how it works
</Button>
```

---

## Section Order for Landing Pages

Follow this proven sequence. Not every page needs all sections, but maintain the order.

| # | Section | Purpose | Required? |
|---|---------|---------|-----------|
| 1 | Hero | Hook + value prop + CTA | Yes |
| 2 | Social Proof Bar | Logos or trust signals | Yes |
| 3 | Problem | Agitate the pain | Yes |
| 4 | Solution | Position your product as the answer | Yes |
| 5 | Features | 3-4 key features with visuals | Yes |
| 6 | How It Works | 3-step process | Recommended |
| 7 | Testimonials | Customer quotes with names and photos | Yes |
| 8 | Pricing | Plans and comparison | Depends on stage |
| 9 | FAQ | Handle objections | Recommended |
| 10 | Final CTA | Last push with urgency | Yes |

---

## Social Proof Types and Placement

### Types (ordered by impact)

1. **Logo bar** - "Trusted by teams at Google, Stripe, Vercel"
2. **User count** - "Join 12,000+ developers"
3. **Testimonial quotes** - Real names, photos, company
4. **Star ratings** - "4.9/5 on G2 with 200+ reviews"
5. **Case study snippets** - "Acme reduced churn by 40%"
6. **Media mentions** - "Featured in TechCrunch, Product Hunt"
7. **Integration logos** - Shows ecosystem fit

### Placement Rules

- Logo bar: immediately after hero (above the fold if possible)
- Testimonials: after features section
- Stats/numbers: near the pricing section
- Case studies: between features and pricing

### Implementation

```tsx
{/* Logo bar */}
<section className="py-8 border-y bg-muted/50">
  <div className="container">
    <p className="text-center text-sm text-muted-foreground mb-6">
      Trusted by 5,000+ teams worldwide
    </p>
    <div className="flex flex-wrap items-center justify-center gap-8 opacity-60">
      {logos.map((logo) => (
        <Image key={logo.name} src={logo.src} alt={logo.name}
          width={120} height={40} className="h-8 w-auto" />
      ))}
    </div>
  </div>
</section>
```

---

## Mobile Optimization Rules

| Rule | Implementation |
|------|---------------|
| Stack elements vertically | `flex flex-col md:flex-row` |
| Full-width CTAs on mobile | `w-full md:w-auto` |
| Reduce heading sizes | `text-3xl md:text-5xl lg:text-6xl` |
| Simplify navigation | Hamburger menu below `md` |
| Thumb-friendly tap targets | Min 44x44px touch area |
| Reduce image sizes | Use `next/image` with responsive sizes |
| Hide non-essential elements | `hidden md:block` for decorative items |
| Test on real devices | Chrome DevTools is not enough |

### Responsive Hero Example

```tsx
<section className="py-16 md:py-24 lg:py-32">
  <div className="container px-4">
    <div className="max-w-3xl mx-auto text-center">
      <h1 className="text-3xl md:text-5xl lg:text-6xl font-bold tracking-tight">
        Ship your SaaS in days, not months
      </h1>
      <p className="mt-4 text-lg md:text-xl text-muted-foreground max-w-2xl mx-auto">
        Everything you need to build, launch, and grow your product.
      </p>
      <div className="mt-8 flex flex-col sm:flex-row gap-4 justify-center">
        <Button size="lg" className="w-full sm:w-auto text-lg px-8">
          Start building free
        </Button>
        <Button variant="outline" size="lg" className="w-full sm:w-auto">
          Watch demo
        </Button>
      </div>
    </div>
  </div>
</section>
```

---

## Form Design

### Rules
- Minimize fields: name + email is usually enough
- Single-column layout only
- Inline validation with clear error messages
- Auto-focus the first field
- Large input fields (`h-12` minimum)
- Clear label text above each field, not placeholder-only

### What to Avoid
- Asking for phone number unless critical
- CAPTCHA on sign-up forms (use honeypot instead)
- Multiple steps when one will do
- Dropdown menus for fewer than 5 options (use radio buttons)

---

## Page Speed Targets

| Metric | Target | How to Measure |
|--------|--------|----------------|
| LCP (Largest Contentful Paint) | < 2.5s | Lighthouse, PageSpeed Insights |
| FID (First Input Delay) | < 100ms | Chrome UX Report |
| CLS (Cumulative Layout Shift) | < 0.1 | Lighthouse |
| Time to Interactive | < 3.5s | Lighthouse |
| Total page weight | < 500KB | DevTools Network tab |
| Image optimization | WebP/AVIF, responsive sizes | next/image handles this |

### Quick Wins
- Use `next/image` for all images (automatic WebP, lazy loading)
- Defer third-party scripts (`next/script` with `strategy="lazyOnload"`)
- Use `next/font` for font loading (no layout shift)
- Minimize client-side JavaScript (prefer Server Components)
- Preload critical assets with `<link rel="preload">`

---

## Common Landing Page Mistakes and Fixes

| Mistake | Why It Hurts | Fix |
|---------|-------------|-----|
| No clear CTA above the fold | Visitors don't know what to do | Add a prominent button in the hero |
| Feature dumping | Overwhelms visitors | Pick 3-4 key features, link to docs for rest |
| No social proof | No trust signal | Add logos, testimonials, or user count |
| Generic stock photos | Feels unauthentic | Use product screenshots or custom illustrations |
| Slow page load | Visitors bounce before seeing content | Optimize images, reduce JS, use SSG |
| Multiple CTAs competing | Decision paralysis | One primary CTA per section |
| Missing mobile optimization | 60%+ traffic is mobile | Mobile-first design approach |
| No urgency | No reason to act now | Add time-limited offers or waitlist counts |
| Wall of text | Nobody reads it | Use bullet points, icons, and whitespace |
| Hiding pricing | Frustrates visitors | Be transparent, show pricing or "starts at $X" |

---

## Implementation with Next.js + Tailwind + shadcn/ui

### Page Structure

```
app/
  page.tsx              # Landing page (Server Component)
  layout.tsx            # Root layout with metadata
components/
  landing/
    hero.tsx            # Hero section
    social-proof.tsx    # Logo bar
    problem.tsx         # Problem section
    solution.tsx        # Solution section
    features.tsx        # Feature grid
    how-it-works.tsx    # Steps section
    testimonials.tsx    # Testimonial cards
    pricing.tsx         # Pricing cards
    faq.tsx             # Accordion FAQ
    final-cta.tsx       # Final CTA section
    navbar.tsx          # Navigation
    footer.tsx          # Footer
```

### Key shadcn/ui Components for Landing Pages

| Component | Use For |
|-----------|---------|
| `Button` | CTAs, navigation actions |
| `Card` | Feature cards, pricing cards, testimonials |
| `Accordion` | FAQ section |
| `Badge` | Labels, tags, plan indicators |
| `Avatar` | Testimonial photos |
| `Separator` | Visual section breaks |
| `Sheet` | Mobile navigation drawer |
| `Tabs` | Pricing toggle (monthly/yearly) |

### Metadata Setup

```tsx
// app/layout.tsx
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "ProductName - Ship Your SaaS Faster",
  description: "Everything you need to build, launch, and grow your SaaS product. Start free.",
  openGraph: {
    title: "ProductName - Ship Your SaaS Faster",
    description: "Everything you need to build, launch, and grow your SaaS product.",
    images: [{ url: "/og-image.png", width: 1200, height: 630 }],
  },
  twitter: {
    card: "summary_large_image",
    title: "ProductName - Ship Your SaaS Faster",
    description: "Everything you need to build, launch, and grow your SaaS product.",
    images: ["/og-image.png"],
  },
};
```

---

## Quick Reference Checklist

- [ ] Headline is benefit-driven and under 10 words
- [ ] CTA button is visible above the fold
- [ ] CTA text starts with a verb and uses first person
- [ ] Social proof is present (logos, count, or testimonials)
- [ ] Hero image shows the actual product
- [ ] Page follows the recommended section order
- [ ] Mobile layout stacks correctly
- [ ] All images use next/image
- [ ] Page loads in under 2.5 seconds
- [ ] No more than 2 form fields for sign-up
- [ ] FAQ addresses top 5 objections
- [ ] Final CTA section exists before footer
- [ ] Meta tags and OG image are configured
- [ ] Analytics tracking is in place
