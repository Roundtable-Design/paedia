# Store release checklist

## Pre-flight

- [ ] `flutter test` and `flutter analyze` clean
- [ ] Test accounts pass on iOS, Android, Web (see [TEST_ACCOUNTS.md](TEST_ACCOUNTS.md))
- [ ] App Check enforced ([APP_CHECK_SETUP.md](APP_CHECK_SETUP.md))
- [ ] Firestore rules deployed from [firestore.rules.proposed](../firebase/firestore.rules.proposed)
- [ ] Crashlytics receiving test crash in release build

## iOS (TestFlight)

```bash
flutter build ipa --release
# Upload via Xcode Organizer or altool
```

- Bundle ID: `com.paedia.app`
- Accept Xcode license; `cd ios && pod install` after dependency changes

## Android (Play internal)

```bash
flutter build appbundle --release
```

- Upload to Play Console → Internal testing track

## Web

```bash
flutter build web --release
```

- Host on existing Paedia web property or Firebase Hosting (not configured in repo yet)

## Version bump

Update `version:` in `pubspec.yaml` before each store submission.

## Post-release

- Monitor Crashlytics for 48h
- Confirm Retool CMS still writes content (read-only client rules unchanged for content collections)
