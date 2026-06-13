# Local test accounts

Dev-only accounts on production Firebase (`paedia-fqv6h9`) for QA during the revamp. They read the same Firestore content as real users but are clearly labelled as dev accounts.

## Setup

```bash
cp .env.test.example .env.test.local
# Edit .env.test.local and set TEST_ACCOUNT_PASSWORD

node scripts/seed-test-accounts.mjs
```

Re-run the seed script anytime to refresh Firestore profiles (safe to repeat).

## Accounts

| Label | Email | Password | Profile |
|-------|-------|----------|---------|
| **Active** | `dev+paedia-active@round-table.co.uk` | see `.env.test.local` | Male, started ~30 days ago |
| **Onboarding** | `dev+paedia-onboard@round-table.co.uk` | same | No gender, no start date |
| **Complete** | `dev+paedia-complete@round-table.co.uk` | same | Female, started ~100 days ago |

Sign in via **Log In** tab with email + password (not Google/Apple).

## Safety

- Script only creates Auth users and `users/{uid}` documents.
- Does **not** deploy Firebase rules, indexes, or CMS content.
- Passwords live only in `.env.test.local` (gitignored).
- Do not use these accounts for production user data.

## Troubleshooting

| Error | Fix |
|-------|-----|
| `EMAIL_EXISTS` on first run | Normal on re-run; script signs in instead |
| `WEAK_PASSWORD` | Use 8+ chars with mixed case and symbols |
| Firestore permission denied | Ensure Email/Password auth is enabled in Firebase console |
