---
name: brand-kit
description: Generate logos, favicons, OG images, and brand identity for a SaaS product. Build a consistent visual system from colors to social media assets. Use for: brand identity, color palette, typography. Triggers on "create brand kit", "brand identity", "generate logo", "favicon", "OG image".
---

# brand-kit

> Generate logos, favicons, OG images, and brand identity for a SaaS product. Build a consistent visual system from colors to social media assets.

**Trigger phrases:** "create brand kit", "brand identity", "generate logo", "favicon", "OG image", "color palette", "brand colors", "typography", "social media images", "brand assets"

---

## Brand Identity Basics

Every SaaS brand needs three things defined before any visual work begins:

| Element | Question to Answer | Example |
|---------|-------------------|---------|
| Name | What's the product called? | "Metrik" |
| Positioning | What does it do in one sentence? | "Analytics for indie SaaS founders" |
| Personality | If it were a person, how would it talk? | Professional but approachable, data-driven |

### Brand Voice Attributes (Pick 3)

Choose 3 attributes that define your brand's personality:

| Attribute | Opposite | Implication |
|-----------|----------|-------------|
| Playful | Serious | Casual copy, illustrations, rounded shapes |
| Technical | Accessible | Code snippets, monospace fonts, dark themes |
| Premium | Budget | Minimal design, serif fonts, muted colors |
| Bold | Subtle | Bright colors, large type, strong contrast |
| Warm | Cold | Soft colors, friendly illustrations, organic shapes |
| Minimal | Detailed | Lots of whitespace, simple icons, clean lines |

---

## Color Palette Selection

### Required Colors

| Role | Usage | Count |
|------|-------|-------|
| Primary | Buttons, links, key actions | 1 color + 4 shades |
| Secondary | Supporting elements, badges | 1 color + 2 shades |
| Accent | Highlights, notifications | 1 color |
| Neutral | Text, backgrounds, borders | Gray scale (50-950) |
| Success | Positive states | Green |
| Warning | Caution states | Amber/Yellow |
| Error | Error states, destructive actions | Red |

### Color Selection Guidelines

- Primary should be distinct and recognizable (avoid generic blue unless intentional)
- Ensure WCAG AA contrast ratio (4.5:1 for text, 3:1 for large text)
- Test colors in both light and dark mode
- Avoid pure black (#000) for text - use a very dark shade of your neutral

### Tailwind Theme Configuration

```ts
// tailwind.config.ts
import type { Config } from "tailwindcss";

const config: Config = {
  theme: {
    extend: {
      colors: {
        primary: {
          50: "#f0f7ff",
          100: "#e0effe",
          200: "#bae0fd",
          300: "#7ccbfb",
          400: "#36b2f7",
          500: "#0c98e8",   // Main primary
          600: "#0079c6",
          700: "#0060a1",
          800: "#045285",
          900: "#09446e",
          950: "#062b49",
        },
        // Add secondary, accent, etc.
      },
    },
  },
};

export default config;
```

### shadcn/ui CSS Variables Approach

```css
/* globals.css */
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222 47% 11%;
    --primary: 205 90% 48%;
    --primary-foreground: 0 0% 100%;
    --secondary: 210 40% 96%;
    --secondary-foreground: 222 47% 11%;
    --accent: 270 60% 55%;
    --accent-foreground: 0 0% 100%;
    --muted: 210 40% 96%;
    --muted-foreground: 215 16% 47%;
    --destructive: 0 84% 60%;
    --destructive-foreground: 0 0% 100%;
    --border: 214 32% 91%;
    --ring: 205 90% 48%;
  }

  .dark {
    --background: 222 47% 11%;
    --foreground: 210 40% 98%;
    --primary: 205 90% 52%;
    --primary-foreground: 0 0% 100%;
    --secondary: 217 33% 17%;
    --secondary-foreground: 210 40% 98%;
    --muted: 217 33% 17%;
    --muted-foreground: 215 20% 65%;
    --border: 217 33% 17%;
    --ring: 205 90% 52%;
  }
}
```

---

## Typography Pairing Guidelines

### Rules
- Use maximum 2 fonts: one for headings, one for body
- Pair a distinctive heading font with a readable body font
- Avoid fonts that are too similar - create clear contrast
- Use `next/font` for performance (no layout shift)

### Recommended Pairings for SaaS

| Heading Font | Body Font | Vibe |
|-------------|-----------|------|
| Inter | Inter | Clean, modern, safe |
| Cal Sans | Inter | Bold SaaS feel |
| Outfit | DM Sans | Friendly, rounded |
| Space Grotesk | IBM Plex Sans | Technical, developer-focused |
| Sora | Source Sans 3 | Geometric, modern |
| Fraunces | Work Sans | Premium, editorial |

### Implementation with next/font

```tsx
// app/layout.tsx
import { Inter, Space_Grotesk } from "next/font/google";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-body",
});

const spaceGrotesk = Space_Grotesk({
  subsets: ["latin"],
  variable: "--font-heading",
});

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${inter.variable} ${spaceGrotesk.variable}`}>
      <body className="font-body">{children}</body>
    </html>
  );
}
```

```css
/* tailwind.config.ts */
theme: {
  extend: {
    fontFamily: {
      body: ["var(--font-body)", "system-ui", "sans-serif"],
      heading: ["var(--font-heading)", "system-ui", "sans-serif"],
    },
  },
}
```

---

## Logo Creation with SVG

### Principles
- Simple enough to recognize at 16x16px (favicon size)
- Works in both color and single-color (monochrome)
- Works on light and dark backgrounds
- No gradients that break at small sizes
- Avoid thin strokes that disappear at small sizes

### Formats Needed

| Format | Size | Use |
|--------|------|-----|
| SVG (full logo) | Scalable | Website header, docs |
| SVG (icon only) | Scalable | Favicon source, app icon |
| PNG (full logo) | 400x100px | Email signatures, external use |
| PNG (icon only) | 512x512px | App stores, social profiles |

### Logo Types for SaaS

| Type | When to Use | Example |
|------|------------|---------|
| Wordmark | When the name is short and unique | "Stripe", "Vercel" |
| Icon + Wordmark | Most SaaS products | Icon left, name right |
| Lettermark | Long product names | First letter or initials |
| Abstract icon | When building brand recognition | Geometric shape |

### SVG Logo Template

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 40" fill="none">
  <!-- Icon -->
  <rect x="0" y="4" width="32" height="32" rx="8"
    fill="currentColor" class="text-primary" />
  <!-- Wordmark -->
  <text x="44" y="28" font-family="Inter, sans-serif"
    font-weight="700" font-size="24" fill="currentColor">
    ProductName
  </text>
</svg>
```

---

## Favicon Generation Checklist

### Required Files

| File | Size | Format | Purpose |
|------|------|--------|---------|
| `favicon.ico` | 32x32 | ICO | Legacy browsers |
| `favicon.svg` | Scalable | SVG | Modern browsers (supports dark mode) |
| `apple-touch-icon.png` | 180x180 | PNG | iOS home screen |
| `icon-192.png` | 192x192 | PNG | Android / PWA |
| `icon-512.png` | 512x512 | PNG | PWA splash screen |
| `site.webmanifest` | - | JSON | PWA manifest |

### Next.js Favicon Setup

Place files in `app/` directory:

```
app/
  favicon.ico          # 32x32
  icon.svg             # SVG favicon (or icon.png)
  apple-icon.png       # 180x180 apple touch icon
  manifest.ts          # Web manifest
```

### Web Manifest

```tsx
// app/manifest.ts
import type { MetadataRoute } from "next";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "ProductName",
    short_name: "Product",
    description: "Your product description",
    start_url: "/",
    display: "standalone",
    background_color: "#ffffff",
    theme_color: "#0c98e8",
    icons: [
      { src: "/icon-192.png", sizes: "192x192", type: "image/png" },
      { src: "/icon-512.png", sizes: "512x512", type: "image/png" },
    ],
  };
}
```

### SVG Favicon with Dark Mode Support

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <style>
    rect { fill: #0c98e8; }
    @media (prefers-color-scheme: dark) {
      rect { fill: #36b2f7; }
    }
  </style>
  <rect width="32" height="32" rx="6" />
  <text x="16" y="22" text-anchor="middle"
    font-family="sans-serif" font-weight="bold"
    font-size="18" fill="white">P</text>
</svg>
```

---

## OG Image Design

### Specs by Platform

| Platform | Size | Safe Zone |
|----------|------|-----------|
| OpenGraph (Facebook, LinkedIn) | 1200x630px | Text within center 800x400 |
| Twitter (summary_large_image) | 1200x628px | Same as OG |
| Twitter (summary) | 240x240px | Square crop |

### OG Image Design Rules

- Background: use brand primary color or a subtle gradient
- Text: large, bold, high contrast against background
- Logo: top-left or bottom-left corner
- Font size: title 48-64px, subtitle 24-32px
- Keep text to 2-3 lines max
- Don't put critical content near edges (platforms crop differently)
- Test on actual platforms (use metatags.io or opengraph.xyz)

### Dynamic OG Image with Next.js

```tsx
// app/api/og/route.tsx
import { ImageResponse } from "next/og";

export const runtime = "edge";

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const title = searchParams.get("title") ?? "ProductName";

  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          flexDirection: "column",
          justifyContent: "center",
          alignItems: "flex-start",
          padding: "80px",
          backgroundColor: "#0c98e8",
          color: "white",
          fontFamily: "Inter, sans-serif",
        }}
      >
        <div style={{ fontSize: 56, fontWeight: 700, lineHeight: 1.2 }}>
          {title}
        </div>
        <div style={{ fontSize: 24, marginTop: 20, opacity: 0.8 }}>
          yourdomain.com
        </div>
      </div>
    ),
    { width: 1200, height: 630 }
  );
}
```

---

## Brand Consistency Across the App

### Design Token Mapping

Map brand values to Tailwind/shadcn tokens consistently:

| Token | Light Mode | Dark Mode | Usage |
|-------|-----------|-----------|-------|
| `--primary` | Brand blue | Lighter brand blue | Buttons, links |
| `--background` | White | Dark gray | Page backgrounds |
| `--foreground` | Near-black | Near-white | Body text |
| `--muted` | Light gray | Dark gray | Secondary backgrounds |
| `--border` | Light gray | Dark gray | Borders, dividers |
| `--ring` | Brand blue | Brand blue | Focus rings |

### Consistency Checklist

- [ ] Same primary color in buttons, links, active states
- [ ] Same border radius everywhere (`rounded-lg` or `rounded-md`, pick one)
- [ ] Same shadow scale (`shadow-sm`, `shadow-md` - define when to use each)
- [ ] Same spacing scale (use Tailwind defaults, don't create custom values)
- [ ] Same transition duration (`duration-200` everywhere)
- [ ] Logo used consistently (same version, same spacing around it)

---

## Dark Mode Considerations

- Design for light mode first, then adapt for dark
- Don't just invert colors - reduce brightness and increase saturation slightly
- Avoid pure white text on pure black (#f5f5f5 on #1a1a1a is easier on the eyes)
- Shadows don't work well in dark mode - use borders or subtle background differences instead
- Test all states: hover, focus, active, disabled in both modes
- Images may need different treatment (add a subtle border or reduce brightness)

---

## Social Media Profile Image Specs

| Platform | Profile | Cover/Banner |
|----------|---------|-------------|
| Twitter/X | 400x400px | 1500x500px |
| LinkedIn | 400x400px | 1128x191px |
| GitHub | 500x500px | - |
| Product Hunt | 240x240px | - |
| Discord | 512x512px | 960x540px |
| YouTube | 800x800px | 2048x1152px |

### Tips
- Use the icon-only version of your logo for profile images
- Add padding around the icon (20% on each side)
- Use a solid background color (brand primary or white)
- Ensure it's recognizable at 32x32px (how it appears in feeds)

---

## Brand Asset Checklist

### Must-Have Assets

- [ ] Logo (SVG + PNG, light and dark versions)
- [ ] Icon-only logo (SVG + PNG)
- [ ] Favicon set (ico, svg, apple-touch-icon, manifest icons)
- [ ] OG image (1200x630, static or dynamic)
- [ ] Color palette documented (hex values, CSS variables)
- [ ] Typography defined (font names, weights, sizes)
- [ ] Tailwind theme configured with brand tokens

### Nice-to-Have Assets

- [ ] Social media profile images (all platforms)
- [ ] Social media cover images
- [ ] Email header image
- [ ] Loading animation / spinner in brand colors
- [ ] Error page illustrations
- [ ] Empty state illustrations
- [ ] Brand guidelines document (1-page summary)

### File Organization

```
public/
  logo.svg              # Full logo
  logo-dark.svg         # Dark mode logo
  icon.svg              # Icon only
  og-image.png          # Default OG image
  icon-192.png          # PWA icon
  icon-512.png          # PWA splash
  apple-icon.png        # Apple touch icon
app/
  favicon.ico           # Legacy favicon
  icon.svg              # Modern favicon
  manifest.ts           # Web manifest
```
