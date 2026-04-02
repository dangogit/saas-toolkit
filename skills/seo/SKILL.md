---
name: seo
description: SEO audit and optimization for SaaS websites covering technical SEO, on-page optimization, Core Web Vitals, structured data, and Next.js-specific implementation. Use for: meta tags, sitemaps, search rankings. Triggers on "SEO audit", "improve SEO", "why am I not ranking", "Core Web Vitals".
---

# seo

> SEO audit and optimization for SaaS websites. Technical SEO, on-page optimization, Core Web Vitals, structured data, and Next.js-specific implementation.

**Trigger phrases:** "SEO audit", "improve SEO", "meta tags", "sitemap", "search ranking", "on-page SEO", "technical SEO", "Core Web Vitals", "structured data", "Google Search Console", "why am I not ranking"

---

## Technical SEO Checklist

### Crawlability and Indexing

| Item | Check | Priority |
|------|-------|----------|
| robots.txt | Exists at `/robots.txt`, allows important pages | Critical |
| XML Sitemap | Exists at `/sitemap.xml`, submitted to GSC | Critical |
| Canonical tags | Every page has a canonical URL | Critical |
| No orphan pages | Every page is reachable via internal links | High |
| Proper status codes | 200 for live pages, 301 for redirects, 404 for missing | High |
| No redirect chains | Max 1 redirect hop | Medium |
| Mobile-friendly | Passes Google Mobile-Friendly Test | Critical |
| HTTPS | All pages served over HTTPS, no mixed content | Critical |
| Hreflang | Set if targeting multiple languages/regions | Medium |
| Pagination | Use `rel="next"` / `rel="prev"` if applicable | Low |

### robots.txt Template for SaaS

```
User-agent: *
Allow: /
Disallow: /api/
Disallow: /dashboard/
Disallow: /settings/
Disallow: /admin/
Disallow: /app/

Sitemap: https://yourdomain.com/sitemap.xml
```

---

## On-Page SEO

### Title Tags

| Rule | Detail |
|------|--------|
| Length | 50-60 characters |
| Format | Primary Keyword - Secondary Keyword | Brand |
| Uniqueness | Every page must have a unique title |
| Front-load keywords | Put the most important keyword first |

### Meta Descriptions

| Rule | Detail |
|------|--------|
| Length | 150-160 characters |
| Include CTA | "Learn more", "Get started", "Try free" |
| Include keyword | Naturally, not stuffed |
| Uniqueness | Every page needs a unique description |

### Heading Structure

```
H1 - One per page, includes primary keyword
  H2 - Major sections (3-6 per page)
    H3 - Subsections under each H2
      H4 - Rarely needed, use sparingly
```

### Content Optimization

- Target one primary keyword per page
- Use the keyword in: H1, first paragraph, one H2, meta title, URL slug
- Write for humans first, search engines second
- Minimum 300 words for landing pages, 1000+ for blog posts
- Use related keywords naturally (LSI keywords)
- Add internal links to other relevant pages (3-5 per page)
- Include external links to authoritative sources (1-2 per blog post)

### URL Structure

| Good | Bad |
|------|-----|
| `/blog/saas-pricing-strategies` | `/blog/post-123` |
| `/features/analytics` | `/features?id=analytics` |
| `/pricing` | `/pricing-page-v2-final` |

Rules:
- Lowercase only
- Use hyphens, not underscores
- Keep URLs short (3-5 words after domain)
- Include the primary keyword
- No dates in URLs unless time-sensitive content

---

## Next.js Specific SEO

### Static Metadata

```tsx
// app/page.tsx
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "SaaS Analytics - Track Your Key Metrics",
  description: "Real-time analytics dashboard for SaaS businesses. Track MRR, churn, and growth metrics in one place.",
  alternates: {
    canonical: "https://yourdomain.com",
  },
  openGraph: {
    title: "SaaS Analytics - Track Your Key Metrics",
    description: "Real-time analytics dashboard for SaaS businesses.",
    url: "https://yourdomain.com",
    siteName: "YourProduct",
    images: [{ url: "/og-image.png", width: 1200, height: 630 }],
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "SaaS Analytics - Track Your Key Metrics",
    description: "Real-time analytics dashboard for SaaS businesses.",
    images: ["/og-image.png"],
  },
};
```

### Dynamic Metadata (Blog Posts, Dynamic Pages)

```tsx
// app/blog/[slug]/page.tsx
import type { Metadata } from "next";

type Props = { params: Promise<{ slug: string }> };

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;
  const post = await getPost(slug);

  return {
    title: `${post.title} | YourProduct Blog`,
    description: post.excerpt,
    alternates: {
      canonical: `https://yourdomain.com/blog/${slug}`,
    },
    openGraph: {
      title: post.title,
      description: post.excerpt,
      type: "article",
      publishedTime: post.publishedAt,
      images: [{ url: post.ogImage, width: 1200, height: 630 }],
    },
  };
}
```

### Sitemap Generation

```tsx
// app/sitemap.ts
import type { MetadataRoute } from "next";

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const posts = await getAllPosts();

  const blogUrls = posts.map((post) => ({
    url: `https://yourdomain.com/blog/${post.slug}`,
    lastModified: new Date(post.updatedAt),
    changeFrequency: "weekly" as const,
    priority: 0.7,
  }));

  return [
    {
      url: "https://yourdomain.com",
      lastModified: new Date(),
      changeFrequency: "monthly",
      priority: 1,
    },
    {
      url: "https://yourdomain.com/pricing",
      lastModified: new Date(),
      changeFrequency: "monthly",
      priority: 0.9,
    },
    {
      url: "https://yourdomain.com/blog",
      lastModified: new Date(),
      changeFrequency: "weekly",
      priority: 0.8,
    },
    ...blogUrls,
  ];
}
```

### robots.ts

```tsx
// app/robots.ts
import type { MetadataRoute } from "next";

export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: "*",
      allow: "/",
      disallow: ["/api/", "/dashboard/", "/app/", "/settings/"],
    },
    sitemap: "https://yourdomain.com/sitemap.xml",
  };
}
```

---

## Core Web Vitals Targets

| Metric | Good | Needs Work | Poor |
|--------|------|------------|------|
| LCP (Largest Contentful Paint) | < 2.5s | 2.5 - 4.0s | > 4.0s |
| INP (Interaction to Next Paint) | < 200ms | 200 - 500ms | > 500ms |
| CLS (Cumulative Layout Shift) | < 0.1 | 0.1 - 0.25 | > 0.25 |

### How to Improve Each

**LCP:**
- Use `next/image` with `priority` on hero images
- Preload critical fonts with `next/font`
- Minimize render-blocking resources
- Use Server Components (no client JS overhead)

**INP:**
- Minimize client-side JavaScript
- Use `React.lazy` and `Suspense` for heavy components
- Debounce event handlers
- Avoid long tasks (break into smaller chunks)

**CLS:**
- Always set `width` and `height` on images
- Use `next/font` to prevent font layout shift
- Reserve space for dynamic content (skeletons)
- Avoid injecting content above existing content

---

## Image Optimization

| Rule | Implementation |
|------|---------------|
| Use next/image | Automatic WebP/AVIF, lazy loading, responsive |
| Set dimensions | Always provide width and height props |
| Priority loading | Add `priority` to above-the-fold images |
| Alt text | Descriptive, includes keyword when natural |
| File naming | `saas-dashboard-analytics.png` not `IMG_2847.png` |
| Responsive sizes | Use `sizes` prop for art direction |

```tsx
import Image from "next/image";

<Image
  src="/hero-dashboard.png"
  alt="SaaS analytics dashboard showing MRR and churn metrics"
  width={1200}
  height={800}
  priority
  sizes="(max-width: 768px) 100vw, (max-width: 1200px) 80vw, 1200px"
/>
```

---

## Internal Linking Strategy

### Rules
- Every page should be reachable within 3 clicks from the homepage
- Use descriptive anchor text (not "click here")
- Link from high-authority pages to important pages
- Blog posts should link to relevant feature pages and other posts
- Create topic clusters: pillar page + supporting blog posts

### Topic Cluster Example

```
Pillar: /features/analytics (main feature page)
  - /blog/saas-metrics-guide (links to pillar)
  - /blog/reduce-churn-rate (links to pillar)
  - /blog/mrr-calculation (links to pillar)
  - /blog/cohort-analysis (links to pillar)
```

---

## Structured Data / JSON-LD for SaaS

### Organization Schema

```tsx
// components/structured-data.tsx
export function OrganizationSchema() {
  const schema = {
    "@context": "https://schema.org",
    "@type": "Organization",
    name: "YourProduct",
    url: "https://yourdomain.com",
    logo: "https://yourdomain.com/logo.png",
    sameAs: [
      "https://twitter.com/yourproduct",
      "https://linkedin.com/company/yourproduct",
      "https://github.com/yourproduct",
    ],
  };

  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(schema) }}
    />
  );
}
```

### SoftwareApplication Schema

```tsx
export function SoftwareSchema() {
  const schema = {
    "@context": "https://schema.org",
    "@type": "SoftwareApplication",
    name: "YourProduct",
    operatingSystem: "Web",
    applicationCategory: "BusinessApplication",
    offers: {
      "@type": "Offer",
      price: "29",
      priceCurrency: "USD",
    },
    aggregateRating: {
      "@type": "AggregateRating",
      ratingValue: "4.8",
      ratingCount: "156",
    },
  };

  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(schema) }}
    />
  );
}
```

### FAQ Schema

```tsx
export function FAQSchema({ faqs }: { faqs: { q: string; a: string }[] }) {
  const schema = {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: faqs.map((faq) => ({
      "@type": "Question",
      name: faq.q,
      acceptedAnswer: {
        "@type": "Answer",
        text: faq.a,
      },
    })),
  };

  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(schema) }}
    />
  );
}
```

---

## Google Search Console Setup

1. Verify ownership (DNS TXT record is most reliable)
2. Submit sitemap at `https://yourdomain.com/sitemap.xml`
3. Check "Coverage" report for indexing issues
4. Monitor "Performance" for impressions, clicks, CTR
5. Review "Core Web Vitals" for page experience
6. Check "Mobile Usability" for mobile issues
7. Use "URL Inspection" to debug individual pages
8. Set up email alerts for critical issues

---

## Common SEO Mistakes for SaaS Sites

| Mistake | Impact | Fix |
|---------|--------|-----|
| App pages indexed | Wastes crawl budget, thin content | `noindex` on `/dashboard/*`, `/app/*` |
| Duplicate content | Ranking dilution | Set canonical URLs on every page |
| Missing meta descriptions | Lower CTR in search results | Write unique descriptions for all pages |
| No blog | Missing long-tail traffic | Start with 5-10 keyword-targeted posts |
| Ignoring page speed | Lower rankings, higher bounce | Optimize images, minimize JS |
| Not tracking keywords | No visibility into progress | Use GSC + a rank tracker |
| Thin landing pages | Won't rank for competitive terms | Add 500+ words of valuable content |
| Broken internal links | Crawl errors, poor UX | Audit with a crawler monthly |
| No structured data | Missing rich snippets in search | Add JSON-LD for org, product, FAQ |
| Client-side rendering only | Search engines may not index | Use SSR/SSG with Next.js |

---

## Monitoring and Measuring SEO Performance

### Key Metrics to Track

| Metric | Tool | Frequency |
|--------|------|-----------|
| Organic traffic | Google Analytics / PostHog | Weekly |
| Keyword rankings | GSC / Ahrefs / SEMrush | Weekly |
| Impressions and CTR | Google Search Console | Weekly |
| Core Web Vitals | GSC / PageSpeed Insights | Monthly |
| Indexed pages | GSC Coverage report | Monthly |
| Backlinks | Ahrefs / GSC Links report | Monthly |
| Page load time | Lighthouse CI | Per deploy |

### Monthly SEO Review Checklist

- [ ] Check GSC for new crawl errors
- [ ] Review top-performing pages and keywords
- [ ] Identify pages with high impressions but low CTR (improve titles)
- [ ] Check for new 404 errors
- [ ] Review Core Web Vitals scores
- [ ] Update content on underperforming pages
- [ ] Add internal links to new content
- [ ] Check competitor rankings for target keywords
- [ ] Submit any new pages to sitemap

---

## Quick SEO Audit Command

When auditing a SaaS site, check these in order:

1. **Can Google crawl it?** - Check robots.txt, test with URL Inspection
2. **Is it indexed?** - `site:yourdomain.com` in Google
3. **Does every page have unique title + description?** - Crawl with Screaming Frog or similar
4. **Are Core Web Vitals passing?** - PageSpeed Insights on key pages
5. **Is structured data valid?** - Google Rich Results Test
6. **Are canonical URLs set?** - Check `<link rel="canonical">` on each page
7. **Is the sitemap complete and submitted?** - GSC sitemap report
8. **Are images optimized?** - Check for missing alt text, large files
9. **Is internal linking healthy?** - No orphan pages, no broken links
10. **Is the app section blocked from indexing?** - Verify noindex/disallow
