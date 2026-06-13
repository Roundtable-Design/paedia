# App Check setup

Enable before deploying [firestore.rules.proposed](../firebase/firestore.rules.proposed).

## Provider choices (Paedia)

| Platform | Choose in Console | Why |
|----------|-------------------|-----|
| **Android** | **Play Integrity** ✅ | Only option; matches release code |
| **iOS** | **App Attest** | Matches `AppleProvider.appAttest` in release builds; stronger than DeviceCheck |
| **Web (Paedia Web)** | **reCAPTCHA** (v3, not Enterprise) | Free; sufficient for discipleship app traffic |
| **Web (rowyApp)** | Skip or separate later | Retool/Rowy admin — register only if Rowy needs App Check |

### iOS: App Attest vs DeviceCheck

Choose **App Attest**. Our client already uses it in release:

```dart
appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
```

DeviceCheck is the older fallback for iOS 11–13; Paedia targets modern iOS only.

### Web: reCAPTCHA vs reCAPTCHA Enterprise

Choose **reCAPTCHA** (standard). Enterprise adds cost and complexity you do not need yet.

After registering **Paedia Web** with reCAPTCHA, copy the **site key** from the console and run:

```bash
flutter run -d chrome \
  --dart-define=RECAPTCHA_SITE_KEY=YOUR_SITE_KEY
```

## 1. Firebase Console

1. Open [App Check](https://console.firebase.google.com/project/paedia-fqv6h9/appcheck) for `paedia-fqv6h9`.
2. Register **Paedia Android** → Play Integrity (done).
3. Register **Paedia iOS** → **App Attest**.
4. Register **Paedia Web** → **reCAPTCHA** → paste site key into `--dart-define` above.
5. For **debug builds**, copy debug tokens from Xcode/Android logcat after first run.
6. Add debug tokens under **Manage debug tokens**.

## 2. Client (wired)

`lib/core/firebase/app_services.dart` activates:

| Build | Android | iOS | Web |
|-------|---------|-----|-----|
| Debug | `debug` provider | `debug` provider | reCAPTCHA if site key set |
| Release | Play Integrity | App Attest | reCAPTCHA if site key set |

Run once locally and note any debug token printed in the console.

## 3. Enforce (do not rush)

1. Leave **metrics only** for ~1 week after clients ship with App Check.
2. Enable enforcement for **Cloud Firestore** on staging first, then production.
3. Deploy [firestore.rules.proposed](../firebase/firestore.rules.proposed) only after enforcement is green.
4. Dry-run: `cd firebase && npx firebase-tools@latest deploy --only firestore:rules --dry-run --project paedia-staging`

See [PRODUCTION_SAFETY.md](PRODUCTION_SAFETY.md) and [STAGING.md](STAGING.md).
