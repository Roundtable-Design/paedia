# Phase 5 — Production hardening checklist

Planned before store release. **Do not deploy rules without App Check + coordinated client update.**

## Firebase App Check

See [APP_CHECK_SETUP.md](APP_CHECK_SETUP.md).

1. Enable App Check in Firebase console for iOS, Android, Web.
2. Register debug tokens for local dev simulators.
3. Enable enforcement before deploying proposed rules.

## Firestore rules PR (planned)

Proposed rules: [`firebase/firestore.rules.proposed`](../firebase/firestore.rules.proposed)

- Scope `users` writes to `request.auth.uid == userId`
- Remove FlutterFlow service account rule
- Remove expired May 2025 temporary rule

Deploy only after App Check + client update. See [STAGING.md](STAGING.md) for staging validation.

## Staging Firebase project

See [STAGING.md](STAGING.md).

## Store release

See [RELEASE.md](RELEASE.md).

## Crashlytics + Sentry

- **Crashlytics** — mobile uncaught errors (already wired).
- **Sentry** — errors + performance on web, iOS, and Android. Free Developer tier. See [MONITORING.md](MONITORING.md).

```bash
flutter run --dart-define=SENTRY_DSN=https://YOUR_KEY@oXXXX.ingest.sentry.io/XXXX
```

## Firebase Analytics

Product events (login, onboarding, tab changes, PDF export) via `firebase_analytics`. See [MONITORING.md](MONITORING.md).

## Release pipeline

- CI already runs analyze + test on push.
- Add tagged builds for APK/IPA/web artifact upload.
- Optional: Fastlane for TestFlight / Play internal track.

## Legacy cleanup

- Remove `lib/flutter_flow/` when all screens live under `lib/features/`.
- Retire FlutterFlow CLI from workflow.
