import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

/// Phase 5 — App Check bootstrap.
/// App Check requires console configuration before enabling in production.
/// Error reporting: Sentry (all platforms) + Crashlytics (mobile) via
/// [runAppWithMonitoring] in `app_monitoring.dart`.
Future<void> initFirebaseServices() async {
  if (!kIsWeb) {
    try {
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
}
