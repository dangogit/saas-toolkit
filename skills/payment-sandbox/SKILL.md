---
name: payment-sandbox
description: Testing payments safely across platforms. Covers Polar.sh sandbox mode for web, RevenueCat sandbox for mobile, Apple sandbox accounts, and Google test tracks. Use when setting up payment testing, debugging payment flows, or switching between test and live modes.
---

# Payment Sandbox Testing

## Web Payments: Polar.sh Sandbox

### Setup
1. Go to dashboard.polar.sh
2. Toggle "Sandbox Mode" in settings
3. Use the sandbox API key in your `.env.local`

```bash
# .env.local for development
POLAR_ACCESS_TOKEN=polar_sandbox_xxx    # Sandbox key
POLAR_WEBHOOK_SECRET=whsec_sandbox_xxx  # Sandbox webhook secret
```

### Testing Checkout
- Sandbox mode uses Stripe test mode underneath
- Use test card: `4242 4242 4242 4242` (any future expiry, any CVC)
- Transactions appear in Polar dashboard under Sandbox
- Webhooks fire to your webhook endpoint (use `polar webhook listen` for local dev)

### Going Live
```bash
# .env.production
POLAR_ACCESS_TOKEN=polar_live_xxx       # Live key
POLAR_WEBHOOK_SECRET=whsec_live_xxx     # Live webhook secret
```

**Checklist before going live:**
- [ ] Webhook endpoint deployed and accessible
- [ ] All subscription tiers created in live mode
- [ ] Tested full flow: checkout -> webhook -> access granted
- [ ] Cancellation and refund flows tested

---

## Mobile Payments: RevenueCat Sandbox

### Setup
1. Create account at app.revenuecat.com
2. Create a project and add your app
3. Configure products in App Store Connect / Google Play Console
4. Link products in RevenueCat dashboard

```typescript
// App initialization
import Purchases from 'react-native-purchases';

Purchases.configure({
  apiKey: 'appl_your_revenuecat_key', // Same key for sandbox and production
});
```

### Apple Sandbox Testing
1. Go to App Store Connect -> Users and Access -> Sandbox Testers
2. Create a sandbox Apple ID (use a real email you own)
3. On your test device: Settings -> App Store -> sign out of real account
4. Sign in with sandbox account when prompted during purchase
5. Sandbox subscriptions auto-renew at accelerated rates:

| Real Duration | Sandbox Duration |
|--------------|-----------------|
| 1 week | 3 minutes |
| 1 month | 5 minutes |
| 1 year | 1 hour |

### Google Play Sandbox Testing
1. Go to Google Play Console -> Setup -> License testing
2. Add your test Gmail accounts
3. Upload an APK/AAB to internal testing track
4. Testers can "purchase" without being charged

### RevenueCat Dashboard
- Sandbox purchases appear with a "Sandbox" badge
- Test subscription lifecycle: purchase -> renewal -> cancellation -> expiry
- Verify entitlements are granted/revoked correctly

### Going Live Checklist
- [ ] Products created in App Store Connect AND Google Play Console
- [ ] Products linked in RevenueCat dashboard
- [ ] Tested full purchase flow with sandbox accounts
- [ ] Tested restore purchases flow
- [ ] Subscription status correctly reflected in app UI
- [ ] Webhooks configured (if using RevenueCat -> your backend)
- [ ] Paywall UI shows correct prices from store
