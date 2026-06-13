# Monitoring & analytics

Recommended stack for Paedia (Flutter web + iOS + Android):

| Layer | Tool | Free tier | Role |
|-------|------|-----------|------|
| **Errors & performance** | [Sentry](https://sentry.io) | 5k errors/mo, 5M spans, 5GB logs, 50 replays | Unified crashes, stack traces, release tracking — **including web** |
| **Product analytics** | Firebase Analytics | Free (Google) | Funnels, retention, screen views, custom events |
| **Mobile crashes (backup)** | Firebase Crashlytics | Free | Already wired on iOS/Android |
| **Performance traces** | Firebase Performance | Free | Network / custom traces (already in `pubspec.yaml`) |

## Why not Datadog or New Relic?

Both are excellent for **backend / infra / large teams**, but overkill for a Flutter client app at this stage:

- **Datadog** — free tier is limited (infra-focused); mobile RUM is paid. Better when you run servers, Kubernetes, and need full-stack correlation.
- **New Relic** — generous 100GB/mo free for full platform, but Flutter/mobile setup is heavier and pricing scales with data ingest. Strong choice later if you add a Node/API layer.

**Sentry + Firebase** gives you production-grade client monitoring at **$0** until you outgrow quotas.

## Sentry setup (done via MCP)

- **Org:** roundtable-studio ([de.sentry.io](https://roundtable-studio.sentry.io))
- **Project:** `paedia` (Flutter)
- **DSN:** stored in GitHub Actions secret `SENTRY_DSN` (not in git)

Local run:

```bash
# DSN is in GitHub → Settings → Secrets → SENTRY_DSN, or Sentry → paedia → Client Keys
flutter run -d chrome \
  --dart-define=SENTRY_DSN=<paste-from-sentry-or-gh-secret>
```

Dashboard: https://roundtable-studio.sentry.io/projects/paedia/

For CI/release builds, `SENTRY_DSN` is already in GitHub Actions secrets.

Optional: upload debug symbols for readable stack traces:

```bash
dart run sentry_dart_plugin --help
```

### Verify

Trigger a test error in debug (with DSN set):

```dart
import '/core/monitoring/app_monitoring.dart';
await recordError(Exception('Sentry test'), StackTrace.current);
```

Check the Sentry Issues dashboard within ~30 seconds.

## Firebase Analytics

Enabled automatically after `firebase_analytics` is added. Events logged in code:

| Event | When |
|-------|------|
| `screen_view` | Navigation (via `FirebaseAnalyticsObserver`) |
| `login` / `sign_up` | Auth success |
| `onboarding_complete` | Onboarding finish |
| `pdf_export` | Day PDF shared |
| `tab_selected` | Bottom nav tab change |

View in Firebase Console → Analytics → DebugView (enable debug mode on device).

## Best practices

### Error monitoring

- **Dual report**: Sentry (all platforms) + Crashlytics (mobile backup).
- **No PII in Sentry**: only Firebase Auth uid is attached — never email or statements.
- **Sample rates**: production traces at 15% to stay inside Sentry free tier.
- **Release tags**: Sentry release is `paedia@{version}+{build}` from `pub_info`.

### Product analytics

- Log **outcomes**, not every tap (avoid noise).
- Use consistent event names (`snake_case`).
- Define 3–5 key funnels: sign-up → onboarding → day 1 reflection → day 30 retention.

### Alerts

- Sentry: email alert on **new issue** or **regression** after deploy.
- Firebase: enable Analytics data export to BigQuery only when you need SQL (paid GCP).

### Security & privacy

- GDPR: document analytics in privacy policy; offer opt-out if required in your jurisdictions.
- Do not send reflection text, group names, or emails to third-party tools.
- Keep App Check enforced before tightening Firestore rules ([APP_CHECK_SETUP.md](APP_CHECK_SETUP.md)).

### When to upgrade

| Signal | Action |
|--------|--------|
| >5k errors/mo | Fix root causes first; then Sentry Team ($26/mo) |
| Need team dashboards | Sentry Team or Firebase + Looker Studio |
| Backend services added | Consider Datadog/New Relic for API latency + logs |
| Product experiments | PostHog (1M events/mo free) or Firebase A/B Testing |

## Environment variables

Add to local `.env` reference (DSN passed via `--dart-define`, not `.env` file):

```
# Sentry — pass at build/run time only
# flutter run --dart-define=SENTRY_DSN=https://...
```

See [.env.example](../.env.example).
