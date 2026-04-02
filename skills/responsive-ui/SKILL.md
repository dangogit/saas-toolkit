---
name: responsive-ui
description: Build responsive, accessible UI components with Tailwind CSS and shadcn/ui. Mobile-first layouts, dark mode, and common SaaS patterns. Use for: responsive design, dashboard layouts, loading states, onboarding wizards. Triggers on "responsive design", "mobile-first", "shadcn component", "dark mode", "sidebar layout".
---

# responsive-ui

> Build responsive, accessible UI components with Tailwind CSS and shadcn/ui. Mobile-first layouts, dark mode, and common SaaS patterns.

**Trigger phrases:** "responsive design", "mobile-first", "shadcn component", "dark mode", "accessible UI", "responsive layout", "sidebar layout", "dashboard grid", "loading states", "skeleton screen", "onboarding wizard", "settings page"

---

## Mobile-First Design Approach

Design for the smallest screen first, then add complexity for larger screens.

### Core Principle

```css
/* This is mobile-first: */
.element {
  width: 100%;          /* Mobile default */
}
@media (min-width: 768px) {
  .element {
    width: 50%;         /* Tablet and up */
  }
}

/* This is NOT mobile-first: */
.element {
  width: 50%;           /* Desktop default */
}
@media (max-width: 767px) {
  .element {
    width: 100%;        /* Override for mobile */
  }
}
```

### In Tailwind (already mobile-first)

```tsx
{/* Start with mobile styles, add responsive prefixes for larger screens */}
<div className="w-full md:w-1/2 lg:w-1/3">
  {/* Full width on mobile, half on tablet, third on desktop */}
</div>
```

### Mobile-First Checklist
- [ ] Design the mobile layout first
- [ ] Test on 375px width (iPhone SE) as minimum
- [ ] Touch targets are at least 44x44px
- [ ] Text is readable without zooming (min 16px body)
- [ ] No horizontal scrolling
- [ ] Forms are single-column on mobile
- [ ] Navigation collapses to hamburger menu

---

## Tailwind Responsive Breakpoints

| Prefix | Min Width | Typical Device |
|--------|-----------|---------------|
| (none) | 0px | Mobile (default) |
| `sm` | 640px | Large phone / small tablet |
| `md` | 768px | Tablet |
| `lg` | 1024px | Laptop |
| `xl` | 1280px | Desktop |
| `2xl` | 1536px | Large desktop |

### Common Responsive Patterns

```tsx
{/* Responsive text */}
<h1 className="text-2xl sm:text-3xl md:text-4xl lg:text-5xl">

{/* Stack to row */}
<div className="flex flex-col md:flex-row gap-4">

{/* Responsive grid */}
<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">

{/* Hide/show elements */}
<nav className="hidden md:flex">     {/* Hide on mobile */}
<button className="md:hidden">       {/* Show only on mobile */}

{/* Responsive padding */}
<section className="px-4 md:px-8 lg:px-16">

{/* Responsive container */}
<div className="container mx-auto px-4">  {/* Auto max-width per breakpoint */}
```

---

## shadcn/ui Component Patterns

### Forms

```tsx
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue,
} from "@/components/ui/select";

<form className="space-y-4 max-w-md">
  <div className="space-y-2">
    <Label htmlFor="name">Name</Label>
    <Input id="name" placeholder="Enter your name" />
  </div>
  <div className="space-y-2">
    <Label htmlFor="plan">Plan</Label>
    <Select>
      <SelectTrigger>
        <SelectValue placeholder="Select a plan" />
      </SelectTrigger>
      <SelectContent>
        <SelectItem value="free">Free</SelectItem>
        <SelectItem value="pro">Pro</SelectItem>
        <SelectItem value="enterprise">Enterprise</SelectItem>
      </SelectContent>
    </Select>
  </div>
  <Button type="submit" className="w-full">Save changes</Button>
</form>
```

### Dialogs (Responsive)

```tsx
import {
  Dialog, DialogContent, DialogDescription,
  DialogHeader, DialogTitle, DialogTrigger, DialogFooter,
} from "@/components/ui/dialog";
import {
  Drawer, DrawerContent, DrawerDescription,
  DrawerHeader, DrawerTitle, DrawerTrigger, DrawerFooter,
} from "@/components/ui/drawer";
import { useMediaQuery } from "@/hooks/use-media-query";

// Use Dialog on desktop, Drawer on mobile
function ResponsiveModal({ children }: { children: React.ReactNode }) {
  const isDesktop = useMediaQuery("(min-width: 768px)");

  if (isDesktop) {
    return (
      <Dialog>
        <DialogTrigger asChild>{children}</DialogTrigger>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Edit profile</DialogTitle>
            <DialogDescription>Make changes to your profile.</DialogDescription>
          </DialogHeader>
          {/* Form content */}
          <DialogFooter>
            <Button type="submit">Save</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    );
  }

  return (
    <Drawer>
      <DrawerTrigger asChild>{children}</DrawerTrigger>
      <DrawerContent>
        <DrawerHeader>
          <DrawerTitle>Edit profile</DrawerTitle>
          <DrawerDescription>Make changes to your profile.</DrawerDescription>
        </DrawerHeader>
        {/* Form content */}
        <DrawerFooter>
          <Button type="submit">Save</Button>
        </DrawerFooter>
      </DrawerContent>
    </Drawer>
  );
}
```

### Responsive Data Tables

```tsx
import {
  Table, TableBody, TableCell,
  TableHead, TableHeader, TableRow,
} from "@/components/ui/table";

{/* Wrap table in a scrollable container on mobile */}
<div className="rounded-md border overflow-x-auto">
  <Table>
    <TableHeader>
      <TableRow>
        <TableHead>Name</TableHead>
        <TableHead>Status</TableHead>
        <TableHead className="hidden md:table-cell">Email</TableHead>
        <TableHead className="hidden lg:table-cell">Created</TableHead>
        <TableHead className="text-right">Actions</TableHead>
      </TableRow>
    </TableHeader>
    <TableBody>
      {data.map((item) => (
        <TableRow key={item.id}>
          <TableCell className="font-medium">{item.name}</TableCell>
          <TableCell><Badge>{item.status}</Badge></TableCell>
          <TableCell className="hidden md:table-cell">{item.email}</TableCell>
          <TableCell className="hidden lg:table-cell">{item.createdAt}</TableCell>
          <TableCell className="text-right">
            <DropdownMenu>{/* actions */}</DropdownMenu>
          </TableCell>
        </TableRow>
      ))}
    </TableBody>
  </Table>
</div>

{/* Alternative: card layout on mobile, table on desktop */}
<div className="hidden md:block">{/* Table view */}</div>
<div className="md:hidden space-y-4">{/* Card view */}</div>
```

---

## Layout Patterns

### Sidebar + Main Content (App Shell)

```tsx
export default function AppLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-screen">
      {/* Sidebar - hidden on mobile, shown on desktop */}
      <aside className="hidden lg:flex lg:w-64 lg:flex-col border-r bg-muted/50">
        <div className="flex h-14 items-center border-b px-4">
          <Logo />
        </div>
        <nav className="flex-1 p-4 space-y-1">
          <SidebarLinks />
        </nav>
      </aside>

      {/* Main area */}
      <div className="flex flex-1 flex-col">
        {/* Top bar with mobile menu trigger */}
        <header className="flex h-14 items-center gap-4 border-b px-4 lg:px-6">
          <Sheet>
            <SheetTrigger asChild>
              <Button variant="ghost" size="icon" className="lg:hidden">
                <Menu className="h-5 w-5" />
              </Button>
            </SheetTrigger>
            <SheetContent side="left" className="w-64 p-0">
              <nav className="p-4 space-y-1">
                <SidebarLinks />
              </nav>
            </SheetContent>
          </Sheet>
          <div className="flex-1" />
          <UserMenu />
        </header>

        {/* Page content */}
        <main className="flex-1 p-4 lg:p-6">
          {children}
        </main>
      </div>
    </div>
  );
}
```

### Dashboard Grid

```tsx
<div className="space-y-6">
  {/* Stat cards */}
  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
    <StatCard title="MRR" value="$12,450" change="+12%" />
    <StatCard title="Active Users" value="1,234" change="+5%" />
    <StatCard title="Churn Rate" value="2.1%" change="-0.3%" />
    <StatCard title="NPS Score" value="72" change="+4" />
  </div>

  {/* Charts - full width stacked on mobile, side by side on desktop */}
  <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
    <Card>
      <CardHeader><CardTitle>Revenue</CardTitle></CardHeader>
      <CardContent><RevenueChart /></CardContent>
    </Card>
    <Card>
      <CardHeader><CardTitle>User Growth</CardTitle></CardHeader>
      <CardContent><GrowthChart /></CardContent>
    </Card>
  </div>

  {/* Recent activity - full width */}
  <Card>
    <CardHeader><CardTitle>Recent Activity</CardTitle></CardHeader>
    <CardContent><ActivityTable /></CardContent>
  </Card>
</div>
```

### Card Layouts

```tsx
{/* Auto-fit grid - cards grow/shrink to fill space */}
<div className="grid grid-cols-[repeat(auto-fill,minmax(280px,1fr))] gap-6">
  {items.map((item) => (
    <Card key={item.id}>
      <CardHeader>
        <CardTitle className="text-lg">{item.title}</CardTitle>
        <CardDescription>{item.description}</CardDescription>
      </CardHeader>
      <CardContent>{/* content */}</CardContent>
      <CardFooter>
        <Button variant="outline" size="sm">View</Button>
      </CardFooter>
    </Card>
  ))}
</div>
```

---

## Dark Mode Implementation with next-themes

### Setup

```bash
npx shadcn@latest init  # Already configures dark mode
npm install next-themes
```

### Theme Provider

```tsx
// components/theme-provider.tsx
"use client";

import { ThemeProvider as NextThemesProvider } from "next-themes";

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  return (
    <NextThemesProvider
      attribute="class"
      defaultTheme="system"
      enableSystem
      disableTransitionOnChange
    >
      {children}
    </NextThemesProvider>
  );
}

// app/layout.tsx
<html lang="en" suppressHydrationWarning>
  <body>
    <ThemeProvider>{children}</ThemeProvider>
  </body>
</html>
```

### Theme Toggle

```tsx
"use client";

import { Moon, Sun } from "lucide-react";
import { useTheme } from "next-themes";
import { Button } from "@/components/ui/button";

export function ThemeToggle() {
  const { setTheme, theme } = useTheme();

  return (
    <Button
      variant="ghost"
      size="icon"
      onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
    >
      <Sun className="h-4 w-4 rotate-0 scale-100 dark:-rotate-90 dark:scale-0" />
      <Moon className="absolute h-4 w-4 rotate-90 scale-0 dark:rotate-0 dark:scale-100" />
      <span className="sr-only">Toggle theme</span>
    </Button>
  );
}
```

### Dark Mode Design Rules
- Use `bg-background` and `text-foreground` instead of `bg-white` and `text-black`
- Use semantic color tokens from shadcn/ui (primary, muted, accent, etc.)
- Test all component states in both modes
- Images: consider adding `dark:brightness-90` or using different images
- Shadows: use `dark:shadow-none` or replace with borders in dark mode
- Never use `bg-gray-100` directly - use `bg-muted` instead

---

## Accessibility Basics

### ARIA and Semantic HTML

| Pattern | Implementation |
|---------|---------------|
| Buttons that look like links | Use `<button>` not `<a>` |
| Links that navigate | Use `<a>` not `<button>` |
| Icon-only buttons | Add `aria-label` or `sr-only` text |
| Loading states | Use `aria-busy="true"` |
| Error messages | Use `aria-describedby` linking input to error |
| Modal dialogs | shadcn Dialog handles this (focus trap, Escape key) |
| Skip navigation | Add "Skip to content" link as first focusable element |

### Keyboard Navigation

- All interactive elements must be focusable (Tab key)
- Focus order must match visual order
- Escape key closes modals/dropdowns
- Enter/Space activates buttons
- Arrow keys navigate within groups (tabs, radio buttons)
- Focus ring must be visible (shadcn/ui handles this with `ring` utilities)

### Focus Management

```tsx
{/* Visible focus ring - shadcn default */}
<Button className="focus-visible:ring-2 focus-visible:ring-ring">

{/* Skip navigation link */}
<a href="#main-content"
  className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4
    focus:z-50 focus:px-4 focus:py-2 focus:bg-background focus:border focus:rounded">
  Skip to content
</a>

{/* Main content target */}
<main id="main-content" tabIndex={-1}>
```

### Color Contrast

- Normal text: 4.5:1 contrast ratio minimum (WCAG AA)
- Large text (18px+ bold or 24px+): 3:1 minimum
- Interactive elements: 3:1 against adjacent colors
- Don't rely on color alone to convey information (add icons or text)
- Test with Chrome DevTools Accessibility panel

---

## Loading States and Skeleton Screens

### Skeleton Pattern

```tsx
import { Skeleton } from "@/components/ui/skeleton";

function CardSkeleton() {
  return (
    <Card>
      <CardHeader>
        <Skeleton className="h-5 w-3/4" />
        <Skeleton className="h-4 w-1/2" />
      </CardHeader>
      <CardContent className="space-y-3">
        <Skeleton className="h-4 w-full" />
        <Skeleton className="h-4 w-full" />
        <Skeleton className="h-4 w-2/3" />
      </CardContent>
    </Card>
  );
}

// Usage with Suspense
<Suspense fallback={<CardSkeleton />}>
  <DataCard />
</Suspense>
```

### Loading Button State

```tsx
import { Loader2 } from "lucide-react";

<Button disabled={isLoading}>
  {isLoading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
  {isLoading ? "Saving..." : "Save changes"}
</Button>
```

### Full Page Loading

```tsx
function PageLoading() {
  return (
    <div className="flex min-h-[400px] items-center justify-center">
      <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
    </div>
  );
}
```

---

## Toast Notifications and Feedback

### Setup with sonner (shadcn recommended)

```tsx
// app/layout.tsx
import { Toaster } from "@/components/ui/sonner";

<body>
  {children}
  <Toaster />
</body>
```

### Usage Patterns

```tsx
import { toast } from "sonner";

// Success
toast.success("Changes saved successfully");

// Error
toast.error("Failed to save changes. Please try again.");

// With action
toast("File deleted", {
  action: {
    label: "Undo",
    onClick: () => restoreFile(),
  },
});

// Loading / Promise
toast.promise(saveData(), {
  loading: "Saving...",
  success: "Saved!",
  error: "Failed to save",
});
```

### When to Use What

| Feedback Type | Component | Use When |
|---------------|-----------|----------|
| Success confirmation | Toast | After save, delete, update |
| Error message | Toast (error) | API failures, validation errors |
| Inline validation | Form error text | Field-level errors |
| Destructive confirmation | AlertDialog | Before delete, before irreversible action |
| Status indicator | Badge | Showing current state (active, pending) |
| Progress | Progress bar | File uploads, multi-step processes |

---

## Common SaaS UI Patterns

### Settings Page

```tsx
<div className="space-y-6">
  <div>
    <h2 className="text-2xl font-bold">Settings</h2>
    <p className="text-muted-foreground">Manage your account preferences.</p>
  </div>
  <Separator />
  <div className="grid grid-cols-1 md:grid-cols-[250px_1fr] gap-8">
    {/* Settings nav */}
    <nav className="space-y-1">
      <SettingsNavLink href="/settings/general" label="General" />
      <SettingsNavLink href="/settings/billing" label="Billing" />
      <SettingsNavLink href="/settings/team" label="Team" />
      <SettingsNavLink href="/settings/notifications" label="Notifications" />
    </nav>
    {/* Settings content */}
    <div className="max-w-2xl">{children}</div>
  </div>
</div>
```

### Billing Page

```tsx
<div className="space-y-8 max-w-2xl">
  {/* Current plan */}
  <Card>
    <CardHeader>
      <CardTitle>Current Plan</CardTitle>
      <CardDescription>You are on the Pro plan.</CardDescription>
    </CardHeader>
    <CardContent>
      <div className="flex items-baseline gap-1">
        <span className="text-3xl font-bold">$29</span>
        <span className="text-muted-foreground">/month</span>
      </div>
    </CardContent>
    <CardFooter className="flex gap-2">
      <Button variant="outline">Change plan</Button>
      <Button variant="ghost" className="text-destructive">Cancel</Button>
    </CardFooter>
  </Card>

  {/* Payment method */}
  <Card>
    <CardHeader><CardTitle>Payment Method</CardTitle></CardHeader>
    <CardContent>
      <div className="flex items-center gap-3">
        <CreditCard className="h-5 w-5" />
        <span>**** **** **** 4242</span>
        <Badge variant="secondary">Default</Badge>
      </div>
    </CardContent>
    <CardFooter>
      <Button variant="outline">Update</Button>
    </CardFooter>
  </Card>

  {/* Invoice history */}
  <Card>
    <CardHeader><CardTitle>Invoice History</CardTitle></CardHeader>
    <CardContent>{/* Invoice table */}</CardContent>
  </Card>
</div>
```

### Onboarding Wizard

```tsx
const steps = ["Create account", "Set up workspace", "Invite team", "Done"];

<div className="max-w-lg mx-auto py-12">
  {/* Step indicator */}
  <div className="flex items-center justify-between mb-8">
    {steps.map((step, i) => (
      <div key={step} className="flex items-center">
        <div className={cn(
          "flex h-8 w-8 items-center justify-center rounded-full text-sm font-medium",
          i <= currentStep
            ? "bg-primary text-primary-foreground"
            : "bg-muted text-muted-foreground"
        )}>
          {i < currentStep ? <Check className="h-4 w-4" /> : i + 1}
        </div>
        {i < steps.length - 1 && (
          <div className={cn(
            "mx-2 h-0.5 w-12 sm:w-20",
            i < currentStep ? "bg-primary" : "bg-muted"
          )} />
        )}
      </div>
    ))}
  </div>

  {/* Step content */}
  <Card>
    <CardHeader>
      <CardTitle>{steps[currentStep]}</CardTitle>
    </CardHeader>
    <CardContent>{/* Step form */}</CardContent>
    <CardFooter className="flex justify-between">
      <Button variant="outline" onClick={prev} disabled={currentStep === 0}>
        Back
      </Button>
      <Button onClick={next}>
        {currentStep === steps.length - 1 ? "Finish" : "Continue"}
      </Button>
    </CardFooter>
  </Card>
</div>
```

---

## TanStack React Table - Responsive Data Tables

Sortable, filterable, paginated tables using `@tanstack/react-table` with shadcn/ui.

### Basic Table Setup

```tsx
import {
  useReactTable,
  getCoreRowModel,
  getSortedRowModel,
  getPaginationRowModel,
  getFilteredRowModel,
  flexRender,
  type ColumnDef,
  type SortingState,
} from "@tanstack/react-table";
import { createColumnHelper } from "@tanstack/react-table";
import {
  Table, TableBody, TableCell,
  TableHead, TableHeader, TableRow,
} from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { ArrowUpDown } from "lucide-react";

type User = {
  id: string;
  name: string;
  email: string;
  status: "active" | "inactive";
  createdAt: string;
};

const columnHelper = createColumnHelper<User>();

const columns = [
  columnHelper.accessor("name", {
    header: ({ column }) => (
      <Button
        variant="ghost"
        onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
      >
        Name
        <ArrowUpDown className="ml-2 h-4 w-4" />
      </Button>
    ),
    cell: (info) => <span className="font-medium">{info.getValue()}</span>,
  }),
  columnHelper.accessor("email", {
    header: "Email",
  }),
  columnHelper.accessor("status", {
    header: "Status",
    cell: (info) => (
      <Badge variant={info.getValue() === "active" ? "default" : "secondary"}>
        {info.getValue()}
      </Badge>
    ),
  }),
  columnHelper.accessor("createdAt", {
    header: "Created",
    cell: (info) => new Date(info.getValue()).toLocaleDateString(),
  }),
];
```

### Table Component with Sorting, Filtering, Pagination

```tsx
function UsersTable({ data }: { data: User[] }) {
  const [sorting, setSorting] = useState<SortingState>([]);
  const [globalFilter, setGlobalFilter] = useState("");

  const table = useReactTable({
    data,
    columns,
    state: { sorting, globalFilter },
    onSortingChange: setSorting,
    onGlobalFilterChange: setGlobalFilter,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
  });

  return (
    <div className="space-y-4">
      <Input
        placeholder="Search users..."
        value={globalFilter}
        onChange={(e) => setGlobalFilter(e.target.value)}
        className="max-w-sm"
      />

      <div className="rounded-md border">
        <Table>
          <TableHeader>
            {table.getHeaderGroups().map((headerGroup) => (
              <TableRow key={headerGroup.id}>
                {headerGroup.headers.map((header) => (
                  <TableHead key={header.id}>
                    {flexRender(header.column.columnDef.header, header.getContext())}
                  </TableHead>
                ))}
              </TableRow>
            ))}
          </TableHeader>
          <TableBody>
            {table.getRowModel().rows.map((row) => (
              <TableRow key={row.id}>
                {row.getVisibleCells().map((cell) => (
                  <TableCell key={cell.id}>
                    {flexRender(cell.column.columnDef.cell, cell.getContext())}
                  </TableCell>
                ))}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>

      {/* Pagination controls */}
      <div className="flex items-center justify-between">
        <p className="text-sm text-muted-foreground">
          Page {table.getState().pagination.pageIndex + 1} of {table.getPageCount()}
        </p>
        <div className="flex gap-2">
          <Button
            variant="outline" size="sm"
            onClick={() => table.previousPage()}
            disabled={!table.getCanPreviousPage()}
          >
            Previous
          </Button>
          <Button
            variant="outline" size="sm"
            onClick={() => table.nextPage()}
            disabled={!table.getCanNextPage()}
          >
            Next
          </Button>
        </div>
      </div>
    </div>
  );
}
```

### Responsive Pattern - Table on Desktop, Cards on Mobile

```tsx
function ResponsiveUsersView({ data }: { data: User[] }) {
  return (
    <>
      {/* Table view - desktop only */}
      <div className="hidden md:block">
        <UsersTable data={data} />
      </div>

      {/* Card view - mobile only */}
      <div className="md:hidden space-y-3">
        {data.map((user) => (
          <Card key={user.id}>
            <CardContent className="p-4">
              <div className="flex items-center justify-between">
                <div>
                  <p className="font-medium">{user.name}</p>
                  <p className="text-sm text-muted-foreground">{user.email}</p>
                </div>
                <Badge variant={user.status === "active" ? "default" : "secondary"}>
                  {user.status}
                </Badge>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    </>
  );
}
```

### Server-Side Pagination Pattern

```tsx
function ServerPaginatedTable() {
  const [pagination, setPagination] = useState({ pageIndex: 0, pageSize: 10 });

  const { data, isLoading } = useQuery({
    queryKey: ["users", pagination],
    queryFn: () =>
      fetch(`/api/users?page=${pagination.pageIndex}&size=${pagination.pageSize}`)
        .then((res) => res.json()),
  });

  const table = useReactTable({
    data: data?.rows ?? [],
    columns,
    rowCount: data?.totalCount ?? 0,
    state: { pagination },
    onPaginationChange: setPagination,
    getCoreRowModel: getCoreRowModel(),
    manualPagination: true, // tells TanStack this is server-side
  });

  // Render table as above, with loading skeleton when isLoading
}
```

---

## TanStack React Query - Data Fetching and Caching

### QueryClientProvider Setup

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
            staleTime: 60 * 1000, // 1 minute
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

// app/layout.tsx
import { Providers } from "@/components/providers";

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
```

### useQuery for Data Fetching

```tsx
import { useQuery } from "@tanstack/react-query";

function Dashboard() {
  const { data, isLoading, error } = useQuery({
    queryKey: ["dashboard-stats"],
    queryFn: async () => {
      const res = await fetch("/api/stats");
      if (!res.ok) throw new Error("Failed to fetch stats");
      return res.json();
    },
  });

  if (isLoading) return <DashboardSkeleton />;
  if (error) return <ErrorMessage message={error.message} />;

  return <StatsGrid data={data} />;
}
```

### useMutation for Form Submissions

```tsx
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";

function CreateUserForm() {
  const queryClient = useQueryClient();

  const mutation = useMutation({
    mutationFn: async (newUser: { name: string; email: string }) => {
      const res = await fetch("/api/users", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(newUser),
      });
      if (!res.ok) throw new Error("Failed to create user");
      return res.json();
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["users"] });
      toast.success("User created successfully");
    },
    onError: (error) => {
      toast.error(error.message);
    },
  });

  return (
    <form onSubmit={(e) => {
      e.preventDefault();
      const formData = new FormData(e.currentTarget);
      mutation.mutate({
        name: formData.get("name") as string,
        email: formData.get("email") as string,
      });
    }}>
      <Input name="name" placeholder="Name" required />
      <Input name="email" type="email" placeholder="Email" required />
      <Button type="submit" disabled={mutation.isPending}>
        {mutation.isPending ? "Creating..." : "Create User"}
      </Button>
    </form>
  );
}
```

### Optimistic Updates Pattern

```tsx
const toggleStatusMutation = useMutation({
  mutationFn: async ({ id, status }: { id: string; status: string }) => {
    const res = await fetch(`/api/users/${id}`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ status }),
    });
    return res.json();
  },
  onMutate: async ({ id, status }) => {
    await queryClient.cancelQueries({ queryKey: ["users"] });
    const previousUsers = queryClient.getQueryData(["users"]);
    queryClient.setQueryData(["users"], (old: User[]) =>
      old.map((user) => (user.id === id ? { ...user, status } : user))
    );
    return { previousUsers };
  },
  onError: (_err, _vars, context) => {
    queryClient.setQueryData(["users"], context?.previousUsers);
    toast.error("Failed to update status");
  },
  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: ["users"] });
  },
});
```

### Query Invalidation

```tsx
// Invalidate a single query
queryClient.invalidateQueries({ queryKey: ["users"] });

// Invalidate all queries starting with "users"
queryClient.invalidateQueries({ queryKey: ["users"], exact: false });

// Invalidate everything
queryClient.invalidateQueries();

// Refetch immediately instead of just marking stale
queryClient.refetchQueries({ queryKey: ["dashboard-stats"] });
```

---

## Forms with react-hook-form + zod

### Form Setup with zodResolver

```tsx
"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import {
  Form, FormControl, FormDescription,
  FormField, FormItem, FormLabel, FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue,
} from "@/components/ui/select";

const profileSchema = z.object({
  name: z.string().min(2, "Name must be at least 2 characters"),
  email: z.string().email("Invalid email address"),
  plan: z.enum(["free", "pro", "enterprise"], {
    required_error: "Please select a plan",
  }),
  website: z.string().url("Invalid URL").optional().or(z.literal("")),
});

type ProfileFormValues = z.infer<typeof profileSchema>;
```

### Controlled Inputs with shadcn/ui Form Components

```tsx
function ProfileForm() {
  const form = useForm<ProfileFormValues>({
    resolver: zodResolver(profileSchema),
    defaultValues: {
      name: "",
      email: "",
      plan: "free",
      website: "",
    },
  });

  function onSubmit(values: ProfileFormValues) {
    // values are fully typed and validated
    console.log(values);
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6 max-w-md">
        <FormField
          control={form.control}
          name="name"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Name</FormLabel>
              <FormControl>
                <Input placeholder="John Doe" {...field} />
              </FormControl>
              <FormDescription>Your public display name.</FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Email</FormLabel>
              <FormControl>
                <Input type="email" placeholder="john@example.com" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="plan"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Plan</FormLabel>
              <Select onValueChange={field.onChange} defaultValue={field.value}>
                <FormControl>
                  <SelectTrigger>
                    <SelectValue placeholder="Select a plan" />
                  </SelectTrigger>
                </FormControl>
                <SelectContent>
                  <SelectItem value="free">Free</SelectItem>
                  <SelectItem value="pro">Pro</SelectItem>
                  <SelectItem value="enterprise">Enterprise</SelectItem>
                </SelectContent>
              </Select>
              <FormMessage />
            </FormItem>
          )}
        />

        <Button type="submit" disabled={form.formState.isSubmitting}>
          {form.formState.isSubmitting ? "Saving..." : "Save Profile"}
        </Button>
      </form>
    </Form>
  );
}
```

### Multi-Step Form Pattern

```tsx
const stepSchemas = [
  z.object({ name: z.string().min(2), email: z.string().email() }),
  z.object({ company: z.string().min(1), role: z.string().min(1) }),
  z.object({ plan: z.enum(["free", "pro", "enterprise"]) }),
];

function MultiStepForm() {
  const [step, setStep] = useState(0);
  const [formData, setFormData] = useState({});

  const form = useForm({
    resolver: zodResolver(stepSchemas[step]),
    defaultValues: formData,
  });

  function onNext(values: Record<string, string>) {
    const merged = { ...formData, ...values };
    setFormData(merged);
    if (step < stepSchemas.length - 1) {
      setStep(step + 1);
    } else {
      // Final submit with all data
      submitForm(merged);
    }
  }

  return (
    <div className="max-w-md mx-auto">
      <StepIndicator current={step} total={stepSchemas.length} />
      <Form {...form}>
        <form onSubmit={form.handleSubmit(onNext)} className="space-y-4">
          {step === 0 && <Step1Fields control={form.control} />}
          {step === 1 && <Step2Fields control={form.control} />}
          {step === 2 && <Step3Fields control={form.control} />}
          <div className="flex justify-between">
            <Button
              type="button" variant="outline"
              onClick={() => setStep(step - 1)}
              disabled={step === 0}
            >
              Back
            </Button>
            <Button type="submit">
              {step === stepSchemas.length - 1 ? "Submit" : "Next"}
            </Button>
          </div>
        </form>
      </Form>
    </div>
  );
}
```

---

## Command Palette (cmdk)

### Basic Command Palette with shadcn/ui

```tsx
"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import {
  CommandDialog, CommandEmpty, CommandGroup,
  CommandInput, CommandItem, CommandList, CommandSeparator,
} from "@/components/ui/command";
import {
  Settings, User, LayoutDashboard, CreditCard,
  LogOut, Search, Plus,
} from "lucide-react";

export function CommandPalette() {
  const [open, setOpen] = useState(false);
  const router = useRouter();

  // Keyboard shortcut: Cmd+K (Mac) or Ctrl+K (Windows)
  useEffect(() => {
    const down = (e: KeyboardEvent) => {
      if (e.key === "k" && (e.metaKey || e.ctrlKey)) {
        e.preventDefault();
        setOpen((prev) => !prev);
      }
    };
    document.addEventListener("keydown", down);
    return () => document.removeEventListener("keydown", down);
  }, []);

  function runCommand(command: () => void) {
    setOpen(false);
    command();
  }

  return (
    <CommandDialog open={open} onOpenChange={setOpen}>
      <CommandInput placeholder="Type a command or search..." />
      <CommandList>
        <CommandEmpty>No results found.</CommandEmpty>

        <CommandGroup heading="Navigation">
          <CommandItem onSelect={() => runCommand(() => router.push("/dashboard"))}>
            <LayoutDashboard className="mr-2 h-4 w-4" />
            Dashboard
          </CommandItem>
          <CommandItem onSelect={() => runCommand(() => router.push("/settings"))}>
            <Settings className="mr-2 h-4 w-4" />
            Settings
          </CommandItem>
          <CommandItem onSelect={() => runCommand(() => router.push("/settings/billing"))}>
            <CreditCard className="mr-2 h-4 w-4" />
            Billing
          </CommandItem>
        </CommandGroup>

        <CommandSeparator />

        <CommandGroup heading="Actions">
          <CommandItem onSelect={() => runCommand(() => router.push("/users/new"))}>
            <Plus className="mr-2 h-4 w-4" />
            Create New User
          </CommandItem>
          <CommandItem onSelect={() => runCommand(() => router.push("/profile"))}>
            <User className="mr-2 h-4 w-4" />
            Edit Profile
          </CommandItem>
        </CommandGroup>

        <CommandSeparator />

        <CommandGroup heading="Account">
          <CommandItem onSelect={() => runCommand(() => signOut())}>
            <LogOut className="mr-2 h-4 w-4" />
            Log Out
          </CommandItem>
        </CommandGroup>
      </CommandList>
    </CommandDialog>
  );
}
```

Add the command palette to your root layout and include a trigger button in the header:

```tsx
// In your header component
<Button
  variant="outline"
  className="relative w-full justify-start text-sm text-muted-foreground sm:w-64"
  onClick={() => setOpen(true)}
>
  <Search className="mr-2 h-4 w-4" />
  Search...
  <kbd className="pointer-events-none absolute right-2 hidden h-5 select-none items-center gap-1 rounded border bg-muted px-1.5 font-mono text-[10px] font-medium sm:flex">
    <span className="text-xs">&#8984;</span>K
  </kbd>
</Button>
```

---

## Charts with Recharts

### Dashboard Chart Patterns

```tsx
"use client";

import {
  LineChart, Line, BarChart, Bar, AreaChart, Area,
  XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend,
} from "recharts";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

const revenueData = [
  { month: "Jan", mrr: 4200, arr: 50400 },
  { month: "Feb", mrr: 4800, arr: 57600 },
  { month: "Mar", mrr: 5400, arr: 64800 },
  { month: "Apr", mrr: 6100, arr: 73200 },
  { month: "May", mrr: 7200, arr: 86400 },
  { month: "Jun", mrr: 8500, arr: 102000 },
];
```

### Responsive Chart Containers

Always wrap charts in `ResponsiveContainer` for automatic resizing:

```tsx
function RevenueChart() {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Monthly Recurring Revenue</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="h-[300px] sm:h-[350px]">
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={revenueData}>
              <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
              <XAxis
                dataKey="month"
                className="text-xs fill-muted-foreground"
                tickLine={false}
                axisLine={false}
              />
              <YAxis
                className="text-xs fill-muted-foreground"
                tickLine={false}
                axisLine={false}
                tickFormatter={(value) => `$${(value / 1000).toFixed(0)}k`}
              />
              <Tooltip
                formatter={(value: number) => [`$${value.toLocaleString()}`, "MRR"]}
                contentStyle={{
                  backgroundColor: "hsl(var(--popover))",
                  border: "1px solid hsl(var(--border))",
                  borderRadius: "8px",
                }}
              />
              <Area
                type="monotone"
                dataKey="mrr"
                stroke="hsl(var(--primary))"
                fill="hsl(var(--primary) / 0.1)"
                strokeWidth={2}
              />
            </AreaChart>
          </ResponsiveContainer>
        </div>
      </CardContent>
    </Card>
  );
}
```

### SaaS Metrics Dashboard Example (MRR, Users, Churn)

```tsx
function MetricsDashboard() {
  return (
    <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
      {/* MRR - Area chart */}
      <Card>
        <CardHeader><CardTitle>MRR Growth</CardTitle></CardHeader>
        <CardContent>
          <div className="h-[250px]">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={mrrData}>
                <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
                <XAxis dataKey="month" className="text-xs" tickLine={false} />
                <YAxis className="text-xs" tickFormatter={(v) => `$${v / 1000}k`} />
                <Tooltip />
                <Area type="monotone" dataKey="mrr" stroke="hsl(var(--primary))" fill="hsl(var(--primary) / 0.1)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </CardContent>
      </Card>

      {/* Active Users - Bar chart */}
      <Card>
        <CardHeader><CardTitle>Active Users</CardTitle></CardHeader>
        <CardContent>
          <div className="h-[250px]">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={usersData}>
                <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
                <XAxis dataKey="month" className="text-xs" tickLine={false} />
                <YAxis className="text-xs" />
                <Tooltip />
                <Bar dataKey="users" fill="hsl(var(--primary))" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </CardContent>
      </Card>

      {/* Churn Rate - Line chart */}
      <Card className="lg:col-span-2">
        <CardHeader><CardTitle>Churn Rate (%)</CardTitle></CardHeader>
        <CardContent>
          <div className="h-[250px]">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={churnData}>
                <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
                <XAxis dataKey="month" className="text-xs" tickLine={false} />
                <YAxis className="text-xs" tickFormatter={(v) => `${v}%`} />
                <Tooltip formatter={(v: number) => [`${v}%`, "Churn"]} />
                <Line type="monotone" dataKey="churn" stroke="hsl(var(--destructive))" strokeWidth={2} dot={{ r: 4 }} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
```

---

## Sonner Toasts

### Setup

```tsx
// app/layout.tsx
import { Toaster } from "@/components/ui/sonner";

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        {children}
        <Toaster richColors position="bottom-right" />
      </body>
    </html>
  );
}
```

### Usage Patterns

```tsx
import { toast } from "sonner";

// Basic types
toast.success("Profile updated successfully");
toast.error("Failed to save changes. Please try again.");
toast.info("Your trial expires in 3 days");
toast.warning("You are approaching your usage limit");

// Loading state with promise
toast.promise(saveSettings(data), {
  loading: "Saving settings...",
  success: "Settings saved!",
  error: "Failed to save settings",
});

// With description and action
toast("Subscription cancelled", {
  description: "Your plan will remain active until the end of the billing period.",
  action: {
    label: "Undo",
    onClick: () => reactivateSubscription(),
  },
});

// Custom duration
toast.success("Copied to clipboard", { duration: 2000 });

// Dismiss programmatically
const toastId = toast.loading("Uploading file...");
// ... after upload completes
toast.dismiss(toastId);
toast.success("File uploaded");
```
