# Staging Firebase project

Use a separate project for rules and CMS experiments — never test write rule changes on `paedia-fqv6h9`.

## Project created ✅

| Field | Value |
|-------|-------|
| Project ID | `paedia-staging` |
| Console | https://console.firebase.google.com/project/paedia-staging/overview |
| CLI alias | `staging` (in `firebase/.firebaserc`) |

## Manual steps still required (Console)

Firestore is not provisioned yet — the CLI hit a permissions/API delay on a brand-new project.

1. Open [Firestore setup](https://console.firebase.google.com/project/paedia-staging/firestore) → **Create database**
2. Choose **Production mode** (we deploy our own rules) → region **eur3** (match prod if possible)
3. Enable **Authentication** → Email/Password (for test accounts)
4. Optional: register iOS/Android/Web apps and download config files for staging builds
5. Seed minimal test data (`days`, `users`, `groups`, manuals) or run a trimmed export from prod

## Deploy rules to staging (after Firestore exists)

```bash
cd firebase
npx firebase-tools@latest deploy --only firestore:rules --project paedia-staging
# Or dry-run first:
npx firebase-tools@latest deploy --only firestore:rules --dry-run --project paedia-staging
```

To test proposed rules, temporarily point `firestore.rules` at the proposed content or copy:

```bash
cp firestore.rules.proposed firestore.rules   # review diff first!
```

## Local dev against staging

(Future: wire `firebase_options` per flavor; today prod is default.)

```bash
flutter run --dart-define=FIREBASE_PROJECT=paedia-staging
```

## Before prod rules deploy

1. Deploy `firestore.rules.proposed` to **staging** first.
2. Run app against staging with test accounts.
3. App Check enforced on staging.
4. Rules Playground + integration smoke on all platforms.
5. Promote same rules file to prod with App Check enforced on prod.

See [APP_CHECK_SETUP.md](APP_CHECK_SETUP.md).
