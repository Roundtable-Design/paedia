# App Check setup

Enable before deploying [firestore.rules.proposed](../firebase/firestore.rules.proposed).

## 1. Firebase Console

1. Open [Firebase Console → App Check](https://console.firebase.google.com/project/paedia-fqv6h9/appcheck) for `paedia-fqv6h9`.
2. Register each app (iOS, Android, Web).
3. For **debug builds**, copy the debug token from Xcode/Android logcat after first run.
4. Add debug tokens under **Manage debug tokens**.

## 2. Client (already wired)

`lib/core/firebase/app_services.dart` activates:

- **Debug:** `AndroidProvider.debug` / `AppleProvider.debug`
- **Release:** Play Integrity / App Attest

Run once locally and note the debug token printed in the console.

## 3. Enforce

1. Enable enforcement for **Cloud Firestore** in App Check (start with metrics-only, then enforce).
2. Deploy proposed rules only after clients with App Check are in TestFlight/internal track.
3. Dry-run: `cd firebase && npx firebase-tools@latest deploy --only firestore:rules --dry-run`

See [PRODUCTION_SAFETY.md](PRODUCTION_SAFETY.md).
