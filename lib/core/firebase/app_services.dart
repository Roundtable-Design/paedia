import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

/// reCAPTCHA v3 site key from Firebase App Check → Web app registration.
/// Pass via: `--dart-define=RECAPTCHA_SITE_KEY=...`
const String kRecaptchaSiteKey = String.fromEnvironment('RECAPTCHA_SITE_KEY');

/// Phase 5 — App Check bootstrap.
/// Error reporting: Sentry + Crashlytics via `app_monitoring.dart`.
Future<void> initFirebaseServices() async {
  try {
    if (kIsWeb) {
      if (kRecaptchaSiteKey.isEmpty) {
        debugPrint(
          'App Check (web): set RECAPTCHA_SITE_KEY via --dart-define after '
          'registering reCAPTCHA in Firebase Console.',
        );
        return;
      }
      await FirebaseAppCheck.instance.activate(
        webProvider: ReCaptchaV3Provider(kRecaptchaSiteKey),
      );
      return;
    }

    await FirebaseAppCheck.instance.activate(
      androidProvider: kDebugMode
          ? AndroidProvider.debug
          : AndroidProvider.playIntegrity,
      appleProvider:
          kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
    );
  } catch (e) {
    debugPrint('App Check not activated: $e');
  }
}
