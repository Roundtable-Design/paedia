# Phase 5 — Production hardening checklist

Planned before store release. **Do not deploy rules without App Check + coordinated client update.**

## Firebase App Check

1. Enable App Check in Firebase console for iOS, Android, Web.
2. Add `firebase_app_check` to the app and activate in `initFirebase()`.
3. Register debug tokens for local dev simulators.

## Firestore rules PR (planned)

- Scope `users` writes to `request.auth.uid == documentId`.
- Remove FlutterFlow service account rule when fully off FlutterFlow.
- Remove expired May 2025 temporary rule.
- Test in Rules Playground + staging project before prod deploy.

See [PRODUCTION_SAFETY.md](PRODUCTION_SAFETY.md).

## Staging project

Create `paedia-staging` Firebase project for rules and CMS experiments before touching prod rules.

## Crashlytics

Add `firebase_crashlytics` and report uncaught Flutter errors.

## Release pipeline

- CI already runs analyze + test on push.
- Add tagged builds for APK/IPA/web artifact upload.
- Optional: Fastlane for TestFlight / Play internal track.

## Legacy cleanup

- Remove `lib/flutter_flow/` when all screens live under `lib/features/`.
- Retire FlutterFlow CLI from workflow.
