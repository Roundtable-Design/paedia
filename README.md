# Paedia

Native Flutter app for [Paedia.co](https://paedia.co) — a 90-day Christian discipleship programme. Hand-maintained fork of the FlutterFlow export; Firebase backend and Retool CMS unchanged.

**Repository:** `Paedia` · **Firebase project:** `paedia-fqv6h9` · **Bundle ID:** `com.paedia.app`

## Production safety

Read [docs/PRODUCTION_SAFETY.md](docs/PRODUCTION_SAFETY.md) before any `firebase deploy`. Bootstrap work is local-only; production was not modified.

## Prerequisites

- [Flutter stable](https://docs.flutter.dev/get-started/install) (SDK >=3.0)
- Firebase CLI (optional, for rules audit): `npx firebase-tools@latest login`
- FlutterFlow CLI (optional, re-export): `dart pub global activate flutterflow_cli`

Copy `.env.example` → `.env` and add your rotated FlutterFlow API token.

## Run locally

Requires Flutter stable (tested with 3.44.2 via Homebrew).

```bash
flutter pub get
flutter run -d chrome --web-port=7358 --web-hostname=localhost   # web
flutter run -d macos                     # desktop (needs Xcode)
flutter run -d ios                       # iOS simulator (needs Xcode + CocoaPods)
```

Web dev server: `http://localhost:7358` (stop with `q` in the Flutter terminal). If you see `ERR_CONNECTION_REFUSED`, the dev server is not running — start it with the command above.

### Web visual tests (Playwright)

With the Flutter web server running on port 7358:

```bash
cd e2e && npm install
PAEDIA_SKIP_WEB_SERVER=1 PAEDIA_WEB_URL=http://localhost:7358 npm test
```

Uses the same Firestore data as production (authenticated reads). Content is managed in Retool.

### Flutter 3.44 compatibility

The FlutterFlow export pinned older packages. These were bumped/patched for current Flutter:

- `font_awesome_flutter` 11.0.0 + `FaIconData` in `flutter_flow_widgets.dart`
- `page_transition` 2.2.2
- `flutter_flow_icon_button.dart` — use passed icon widget directly

### iOS & Android

See [docs/MOBILE_SETUP.md](docs/MOBILE_SETUP.md) for full setup.

- **Android:** SDK + emulator `Paedia_Pixel_7` ready; `flutter run -d emulator-5554`
- **iOS:** Install Xcode from App Store, then `./scripts/finish-ios-setup.sh`

## Project structure

```
lib/
  pages/          # FlutterFlow screens (login, reflections, manuals, profile, group)
  backend/schema/ # Firestore record types
  auth/           # Firebase Auth
firebase/       # Rules pulled from live prod (do not deploy blindly)
docs/           # Production safety notes
```

## Re-export from FlutterFlow (optional)

```bash
export FLUTTERFLOW_API_TOKEN=...  # from .env
flutterflow export-code \
  --project paedia-fqv6h9 \
  --project-environment Production \
  --include-assets \
  --include-export-manifest \
  --dest ./export
```

Respect `.flutterflowignore` for hand-edited files.

## Roadmap
- [Revamp strategy](docs/REVAMP_STRATEGY.md)

- Offline prefetch (Drift/SQLite)
- PDF export for days and manuals
- Gradual refactor off FlutterFlow-generated widgets
