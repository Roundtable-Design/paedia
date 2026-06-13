import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Product analytics via Firebase Analytics (free, unlimited events with quotas).
class AppAnalytics {
  AppAnalytics._();

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: _analytics);

  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (kDebugMode) {
      debugPrint('[analytics] screen_view: $screenName');
    }
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  static Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  static Future<void> logSignUp({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  static Future<void> logOnboardingComplete() async {
    await _analytics.logEvent(name: 'onboarding_complete');
  }

  static Future<void> logPdfExport({required int dayNumber}) async {
    await _analytics.logEvent(
      name: 'pdf_export',
      parameters: {'day_number': dayNumber},
    );
  }

  static Future<void> logTabSelected({required String tab}) async {
    await _analytics.logEvent(
      name: 'tab_selected',
      parameters: {'tab': tab},
    );
  }
}
