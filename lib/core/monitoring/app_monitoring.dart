import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Sentry DSN from `--dart-define=SENTRY_DSN=...` (never commit the DSN).
const String kSentryDsn = String.fromEnvironment('SENTRY_DSN');

bool get isSentryEnabled => kSentryDsn.isNotEmpty;

/// Bootstrap the app with optional Sentry error + performance monitoring.
Future<void> runAppWithMonitoring(Future<void> Function() appRunner) async {
  if (!isSentryEnabled) {
    _configureCrashlyticsOnly();
    await appRunner();
    return;
  }

  final packageInfo = await PackageInfo.fromPlatform();

  await SentryFlutter.init(
    (options) {
      options.dsn = kSentryDsn;
      options.environment = kDebugMode ? 'development' : 'production';
      options.release = 'paedia@${packageInfo.version}+${packageInfo.buildNumber}';
      options.dist = packageInfo.buildNumber;
      options.sendDefaultPii = false;
      options.enableAutoSessionTracking = true;
      // Stay within Sentry Developer free tier (5k errors / 5M spans).
      options.tracesSampleRate = kDebugMode ? 1.0 : 0.15;
      options.profilesSampleRate = kDebugMode ? 0.0 : 0.05;
    },
    appRunner: () async {
      _chainCrashlyticsWithSentry();
      await appRunner();
    },
  );
}

void _configureCrashlyticsOnly() {
  if (kIsWeb) return;

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

void _chainCrashlyticsWithSentry() {
  if (kIsWeb) return;

  final sentryFlutterHandler = FlutterError.onError;
  FlutterError.onError = (details) {
    sentryFlutterHandler?.call(details);
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  final sentryPlatformHandler = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stack) {
    sentryPlatformHandler?.call(error, stack);
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

Future<void> recordError(
  Object error,
  StackTrace? stack, {
  bool fatal = false,
  String? reason,
}) async {
  if (isSentryEnabled) {
    await Sentry.captureException(
      error,
      stackTrace: stack,
      hint: reason != null ? Hint.withMap({'reason': reason}) : null,
    );
  }

  if (!kIsWeb) {
    await FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      fatal: fatal,
      reason: reason,
    );
  }
}

/// Attach authenticated user context (uid only — no email or PII).
Future<void> setMonitoringUser({required String? userId}) async {
  if (isSentryEnabled) {
    await Sentry.configureScope((scope) {
      scope.setUser(userId != null ? SentryUser(id: userId) : null);
    });
  }

  if (!kIsWeb) {
    await FirebaseCrashlytics.instance.setUserIdentifier(userId ?? '');
  }
}

List<NavigatorObserver> monitoringNavigatorObservers() {
  if (!isSentryEnabled) return const [];
  return [SentryNavigatorObserver()];
}
