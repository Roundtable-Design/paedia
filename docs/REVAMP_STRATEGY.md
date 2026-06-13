# Paedia Flutter App — Revamp Strategy

**Version:** 1.0 · **Date:** 2026-06-13  
**Scope:** Strategic plan for migrating off FlutterFlow, modernizing architecture/UI, and delivering offline + PDF goals.  
**Constraint:** Read-only Firebase exploration; no production schema or rules changes in this document.

---

## Executive snapshot

Paedia is a **67-file, ~856 KB** FlutterFlow export (v1.0.2) serving a 90-day discipleship programme. The app works but is **codegen-heavy** (login 2,192 lines, profile 1,697, reflections 1,515), **duplicates state** (`FFAppState.startDate` vs `users.startDate`), uses **Provider + FF patterns** throughout, and has **no CI, tests, or offline layer**. Content is HTML-rich and read-heavy; the current UI is dark-first with sage green (`#3D9970`) accents and accordion-based manuals/reflections.

**Recommended direction:** Incremental strangler migration — extract domain + UI kit first, rewrite screens one tab at a time, keep Retool CMS and Firestore collections unchanged until a deliberate schema cleanup phase.

**Estimated total effort (solo dev, part-time ~15 hrs/week):** 6–9 months across 6 phases. Quick wins achievable in Phase 0–1 (~4 weeks).

---

## Current codebase inventory

### Stack (today)

| Layer | Technology | Notes |
|-------|------------|-------|
| UI framework | Flutter 3.44+ | Patched for `font_awesome` 11, `page_transition` 2.2.2 |
| State | `provider` 6.1 + `FFAppState` | Only `startDate` persisted locally |
| Routing | `go_router` 12.1.3 + `FFRoute` wrapper | Tabs via `NavBarPage` state, not shell routes |
| Backend | Firebase Auth, Firestore, Storage | Project `paedia-fqv6h9` |
| CMS | Retool → Firestore | Content collections read-only from app |
| HTML | `flutter_html` 3.0-beta | Custom `HtmlTextDisplay` widget |
| Accordions | `expandable` 5.0.1 | Manuals + reflection sections |
| Theme | `FlutterFlowTheme` | M3-like tokens but `useMaterial3: false` in `main.dart` |

### Firestore collections

| Collection | Key fields | App usage |
|------------|------------|-----------|
| `users` | `display_name`, `startDate`, `gender`, `whyStatement`, `closingStatement`, … | Profile, auth bootstrap, gender gating |
| `groups` | `groupName`, `usersIDs[]` | Community tab — single group per user |
| `days` | `DayNumber`, `Title`, `Sybtitle`, `Preamble`, `Scripture`, HTML sections… | Reflections — today + archive list |
| `participant_manual` | `Title`, `Text`, `Position`, `gender` | Gender-filtered accordion manual |
| `accessoryManual` | `heading`, `description`, `order`, `gender` | Supplementary gender-filtered content |

### Screen map

```
/login, /forgotPassword          → Auth
/  → NavBarPage (4 tabs, not deep-linked by default)
  ├── Group      → group roster
  ├── Reflections → day header, today's content, past days list
  ├── Manual     → links to participant + accessory manuals
  └── Profile    → photo, gender, dates, statements, account
/participantManual, /accessoryManual → deep HTML reading
/users/:user                     → member detail
```

### Known technical debt (from code review)

1. **Dual start-date source:** `FFAppState().startDate` (SharedPreferences) and `currentUserDocument?.startDate` (Firestore) are both read/written; reflections gates on both inconsistently.
2. **Day math inconsistency:** `calculateDateNumber` / `returnDayInInteger` use UTC date-only; `returnDayinString` uses local `DateTime` — edge cases around midnight/timezones.
3. **No post-day-90 UX:** Queries still run; empty containers returned silently when day > 90.
4. **Tab navigation:** `NavBarPage` keeps tab state in widget state; switching tabs does not update URL; deep links to `/reflections` work but tab highlight can desync.
5. **Accessibility:** Bottom nav items have empty `label` and `tooltip`; long HTML lacks heading structure guarantees.
6. **Security rules debt:** `users` writable by any authed user; FlutterFlow service account rule; expired May 2025 temp rule still present (see `docs/PRODUCTION_SAFETY.md`).
7. **Schema naming:** Mixed PascalCase (`DayNumber`, `Sybtitle`) and camelCase (`groupName`, `startDate`); **`Sybtitle` typo** baked into code and CMS.
8. **No tests, no CI, no flavors** — single debug workflow documented in README.

---

## 1. Code architecture migration

### Goal

Leave FlutterFlow without a big-bang rewrite. Preserve working Firebase integration while replacing FF-generated pages with hand-owned feature modules.

### What to keep (initially)

| Keep | Why |
|------|-----|
| `lib/auth/` | Firebase Auth flows work; refactor incrementally |
| `lib/backend/firebase/firebase_config.dart` | Init wiring |
| Firestore query helpers in `backend.dart` | Stable API until repositories land |
| `lib/flutter_flow/custom_functions.dart` | Domain logic — **move first** to `lib/core/` |
| `assets/` | Brand images, fonts |
| `firebase/` rules (as reference) | Already synced from prod |

### What to delete (eventually)

| Delete | When |
|--------|------|
| `lib/pages/*_model.dart` | After each screen rewritten |
| Most of `lib/flutter_flow/` | After theme, nav, util replaced |
| `page_transition` + `FFRoute` | After go_router shell migration |
| `flutter_spinkit` loading duplication | After shared loading components |
| FF widget wrappers (`FFButtonWidget`, etc.) | After design system components exist |

### What to extract (priority order)

1. **Domain services** — day calculation, programme calendar, gender content filter
2. **Repositories** — Firestore + (later) Drift cache behind one interface
3. **Design system** — theme, typography, components
4. **Feature modules** — one folder per tab + auth

### Target folder structure

```
lib/
  main.dart
  app/
    app.dart                 # MaterialApp.router, providers
    router/
      app_router.dart        # go_router 14+ typed routes
      shell_scaffold.dart    # bottom nav shell
    env/
      env.dart               # flavor + dart-define config
  core/
    domain/
      programme.dart         # DayNumber, ProgrammePhase, FastingDay
      user_profile.dart
    utils/
      date_math.dart         # single source for day index
    extensions/
  data/
    repositories/
      auth_repository.dart
      user_repository.dart
      days_repository.dart
      manuals_repository.dart
      groups_repository.dart
    datasources/
      firestore/             # thin wrappers; migrate from backend.dart
      local/                 # Drift DAOs (Phase 4)
    models/                  # freezed + json_serializable
  features/
    auth/
    community/
    reflections/
    manuals/
    profile/
  shared/
    widgets/
      paedia_scaffold.dart
      html_content_view.dart
      day_header.dart
      manual_accordion.dart
      empty_state.dart
      loading_indicator.dart
    theme/
      paedia_theme.dart
      tokens.dart
  legacy/                    # temporary; shrink each sprint
    flutter_flow/            # until fully removed
```

### State management: **Riverpod** (recommended over Bloc)

| Criterion | Riverpod | Bloc |
|-----------|----------|------|
| Solo dev velocity | Excellent — less boilerplate | More ceremony per feature |
| Firestore streams | `StreamProvider`, `AsyncNotifier` fit naturally | Works but more layers |
| Migration from Provider | Gradual — can wrap existing `FFAppState` | Requires broader rewrite |
| Testing | `ProviderContainer` overrides | `bloc_test` — good but heavier |
| Community/examples | Strong in 2025–2026 Flutter ecosystem | Strong for large teams |

**Decision:** Adopt **Riverpod 2.x** with code-generated providers (`riverpod_annotation`) for repositories and feature notifiers. Do **not** introduce Bloc unless a second developer prefers it — mixing both is worse than either alone.

### Repository pattern

```dart
abstract class DaysRepository {
  Stream<Day?> watchToday(int dayNumber);
  Stream<List<Day>> watchPastDays({required int beforeDay});
  Future<Day?> getDay(int dayNumber); // cache-first after Phase 4
}
```

Implementations:

- `FirestoreDaysRepository` — wraps existing `queryDaysRecord`
- `CachedDaysRepository` — decorates with Drift (Phase 4)
- Inject via Riverpod: `daysRepositoryProvider`

### Models: **freezed** + immutable domain types

Replace direct `*Record` usage in UI gradually:

```dart
@freezed
class Day with _$Day {
  const factory Day({
    required int dayNumber,
    required String title,
    required String subtitle, // maps Sybtitle until schema fix
    required String preamble,
    @Default([]) List<DaySection> sections,
  }) = _Day;
}
```

Add mappers: `DaysRecord.toDomain()` in `data/models/mappers/`. Keep FF records in data layer only.

### Migration tactics (strangler fig)

1. **Stop re-exporting from FlutterFlow** — treat this repo as source of truth; use `.flutterflowignore` (already lists `docs/`, `firebase/`, `pubspec.yaml`).
2. **New code only in `lib/features/` and `lib/shared/`** — never edit generated pages except bugfixes until rewrite.
3. **Parallel route:** e.g. `/reflections` → new `ReflectionsScreen` while old widget lives in `legacy/`.
4. **Delete `*_model.dart`** when screen migrated — FF model pattern (`createModel`, `safeSetState`) goes away.
5. **Single start-date source:** Firestore `users.startDate` authoritative; local cache via repository, deprecate `FFAppState.startDate`.

---

## 2. UI / design system

### Design intent

Paedia is a **long-form reading app** with periodic structured interaction (reflection questions, group context). Visual language: calm, dark, focused — not a social feed. Typography and spacing matter more than component chrome.

### Approach: **Material 3 foundation + Paedia token extensions**

| Option | Verdict |
|--------|---------|
| Pure M3 defaults | Too generic; loses brand |
| shadcn-style custom (Flutter port) | Overkill; shadcn targets web/React; fighting M3 accessibility |
| **M3 ColorScheme + custom tokens + reading typography** | **Recommended** |

Enable `useMaterial3: true` and define:

```dart
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF3D9970),
    surface: Color(0xFF14181B),
    onSurface: Color(0xFFFFFFFF),
    // ...
  ),
  extensions: [PaediaTokens(...)],
  textTheme: PaediaTextTheme.reading, // tuned line heights
)
```

### Design tokens (`lib/shared/theme/tokens.dart`)

| Token category | Values / notes |
|----------------|----------------|
| **Spacing** | 4, 8, 16, 24, 32, 48 — replace scattered `FFAppConstants` |
| **Radius** | sm 8, md 12, lg 16 — reduce box-shadow cards slightly |
| **Reading measure** | max content width 680px on tablet/desktop |
| **Line height** | body 1.6, scripture 1.75, questions 1.5 |
| **Semantic colors** | `fastingDay`, `sabbathDay`, `programmeComplete`, `offline` |
| **Elevation** | minimal — flat dark surfaces, 1px borders at 8% white |

### Typography for long-form reading

| Role | Font | Size / weight | Usage |
|------|------|---------------|-------|
| Display | Inter Tight | 28–32 w600 | Day title, section headers |
| Body | Inter | 16 w400, lh 1.6 | Preamble, reflection |
| Scripture | Inter | 16 w400 italic or dedicated serif* | *Optional: Lora/Source Serif for distinction |
| Label | Inter | 12–14 w500 | Metadata, day counter |
| Questions | Inter | 15 w400 | Slightly smaller than body |

**Recommendation:** Keep Inter family (already via Google Fonts) for consistency; add **optional serif for Scripture blocks only** via `HtmlContentView` tag styles.

### Component library to extract

| Component | Replaces | Priority |
|-----------|----------|----------|
| `PaediaScaffold` | Repeated SafeArea + padding + bg | P0 |
| `PaediaBottomNav` | `NavBarPage` bottom bar — labels + semantics | P0 |
| `HtmlContentView` | `HtmlTextDisplay` — themed tags, link handling, print-friendly | P0 |
| `DayHeader` | Reflections top block — dates, day N/90, fasting/sabbath badge | P0 |
| `ManualAccordion` | `expandable` wrappers in manual pages | P1 |
| `PaediaCard` | Shadow containers in reflections | P1 |
| `EmptyState` | Silent `Container()` on missing data | P0 |
| `LoadingIndicator` | SpinKit duplication | P0 |
| `GenderBadge` | Profile/manual gender indicator | P1 |
| `ProgrammeProgressRing` | Visual 90-day progress | P2 |
| `OfflineBanner` | Connectivity + cache status | P2 |

### HtmlContentView requirements

- Migrate from `flutter_html` beta → **`flutter_widget_from_html`** (better maintenance, `core` + optional `fwfh_url_launcher`)
- Centralize tag styles: `p`, `h1–h4`, `blockquote`, `ul/ol`, `a`
- Strip empty `<p><br></p>` (already started)
- Support `data-gender` or content sections if CMS adds them later
- Accessibility: semantic headings, link tooltips, sufficient contrast on links (`primary` with underline)

### Dark mode

Keep **dark as default** (matches brand); support system/light via existing `FlutterFlowTheme` persistence — migrate to `ThemeMode` in `SharedPreferences` under new key.

---

## 3. Obvious UX wins (by screen)

### Global

| Win | Detail |
|-----|--------|
| **Offline indicator** | Banner when Firestore unreachable; show cached content badge |
| **Pull-to-refresh** | On reflections + manuals (when online) |
| **Consistent empty states** | Illustration + copy + action (e.g. "Set start date") |
| **Loading skeletons** | Replace bouncing spinner for content areas |
| **Bottom nav labels** | "Community", "Today", "Manuals", "Profile" — improves wayfinding |
| **Haptic on day change** | Subtle feedback when crossing midnight (optional) |
| **Accessibility audit** | Semantics, min 44pt targets, screen reader order for accordions |

### Community (Group)

| Issue today | Improvement |
|-------------|-------------|
| "No group assigned" plain text | Empty state with explanation + support contact |
| `FutureBuilder` for roster after stream | Single combined provider; show partial data |
| No tap affordance on members | Clear list tiles → `/users/:id` |
| No group metadata | Show member count, optional group start alignment |

### Reflections / Calendar (Days)

| Issue today | Improvement |
|-------------|-------------|
| Dual start-date confusion | One editable date in Profile; Reflections read-only with "Edit in Profile" link |
| Day calc bugs at timezone edges | Unified `date_math.dart`; show "Day N of 90" + linear progress |
| Pre-start countdown | Prominent countdown card (already partially in `calculateDateNumber`) |
| Post-day-90 | "Programme complete" celebration + archive mode (read all days) |
| Today vs archive | Sticky `DayHeader`; archive as collapsible "Previous days" with search |
| Gender not set | Blocking empty state with CTA to Profile (not inline duplicate dropdown) |
| Fasting/Sabbath | Badge from `specialDayOfTheWeek()` — currently computed but underused |
| Reading progress | Track scroll % per section (local); "Continue reading" on return |
| Share / PDF | Share button on day view → PDF or markdown export (Phase 4) |
| Past days list | Show title + date; filter/search by keyword |

### Manuals

| Issue today | Improvement |
|-------------|-------------|
| Gender filtering opaque | Subtitle: "Showing content for [gender]" with change link |
| Two manual types unclear | Card descriptions: Participant vs Accessory purpose |
| Deep accordion nesting | Table of contents jump list at top |
| Long HTML scroll | Floating "back to top"; remember expanded sections locally |
| Offline | Prefetch manual HTML on login / Wi-Fi |

### Profile

| Issue today | Improvement |
|-------------|-------------|
| 1,697-line monolith | Split: avatar, programme dates, statements, account |
| Start/end dates | Show calculated end date (`calculateEndDate`) + days remaining |
| Gender selection | Inline + confirm if content will change |
| Why/closing statements | Character guidance; preview formatting |
| Delete account | Already popup — add confirmation typing |
| Photo upload errors | Actionable error toasts |

### Login / Auth

| Issue today | Improvement |
|-------------|-------------|
| 2,192-line widget | Split social + email flows; defer gender/date to post-login onboarding |
| Onboarding wizard | Step 1: auth → 2: gender → 3: start date → 4: why statement (optional) |
| Reduce login friction | Apple/Google one-tap; email secondary |

### Users detail (`/users/:user`)

| Improvement |
|-------------|
| Show photo, name, optional contact; no private fields |
| Back navigation consistency |

---

## 4. Modern Flutter practices

### Navigation — go_router shell migration

**Target:** go_router **14.x** with `StatefulShellRoute.indexedStack`:

```dart
StatefulShellRoute.indexedStack(
  branches: [
    StatefulShellBranch(routes: [GoRoute(path: '/community', ...)]),
    StatefulShellBranch(routes: [GoRoute(path: '/today', ...)]),
    // ...
  ],
)
```

Benefits: URL ↔ tab sync, preserved scroll per tab, declarative auth redirects.

Remove: `NavBarPage`, `FFRoute`, `page_transition`, `GoRouter.optionURLReflectsImperativeAPIs`.

Auth redirect: `redirect: (context, state) => authGuard(...)` replacing `AppStateNotifier` splash hack (keep splash as overlay, not router loading gate).

### HTML rendering

| Package | Use |
|---------|-----|
| `flutter_widget_from_html` | Primary HTML renderer |
| `fwfh_url_launcher` | External links |
| `fwfh_cached_network_image` | Inline images in CMS HTML |

Deprecate `flutter_html` beta after parity testing on representative CMS samples.

### Offline — **Drift** (not raw sqflite)

`s sqflite` is already a transitive dep but unused for app logic.

```
Drift tables:
  days (dayNumber PK, json blob, updatedAt)
  manual_sections (id, type, gender, position, html, updatedAt)
  sync_metadata (key, lastSyncedAt, etag)
```

Strategy:

1. **Read-through cache:** UI reads repository → Drift first → Firestore refresh
2. **Prefetch job:** On login + nightly, fetch today ±7 days + full manual for user's gender
3. **Conflict:** CMS is source of truth; overwrite local on successful fetch
4. **Size budget:** ~5–15 MB for 90 days HTML — acceptable on mobile

### PDF export

| Package | Role |
|---------|------|
| `pdf` + `printing` | Generate and share/print PDF |

Pipeline:

1. `DayPdfBuilder` — title, metadata, plain-text strip from HTML sections
2. `ManualPdfBuilder` — accordion order preserved
3. Share via `Printing.sharePdf` or platform share sheet

Web: `printing` supports web preview — test early.

### Firebase hardening

| Item | Action |
|------|--------|
| `firebase_app_check` | Enable App Check on iOS/Android/Web before tightening rules |
| Performance | Keep `firebase_performance`; add traces for day load, manual open |
| Rules cleanup | Planned PR: uid-scoped `users`, remove FF service account, remove expired temp rule |
| Auth | Consider email verification for new signups |

### Flavors / environment config

```bash
flutter run --dart-define=ENV=dev
flutter run --dart-define=ENV=prod
```

| Env | Firebase | Notes |
|-----|----------|-------|
| `prod` | `paedia-fqv6h9` | Default; live CMS |
| `dev` | Future staging project | Recommended before rules experiments |

Use `flutterfire configure` per flavor; **do not** point dev builds at prod once write testing begins.

### CI (GitHub Actions)

```yaml
# .github/workflows/ci.yml
- flutter analyze
- dart format --set-exit-if-changed .
- flutter test
- build apk/ipa/web (matrix, on tag)
```

Add **`melos` optional** if monorepo grows; not needed now.

### Feature flags

Lightweight approach without new infra:

1. **Firestore `app_config/settings`** doc (Retool-editable): `{ "pdfExport": true, "offlineBeta": false }`
2. Riverpod `featureFlagsProvider` stream
3. Later: Firebase Remote Config if A/B needed

### Testing strategy

| Layer | Target |
|-------|--------|
| Unit | `date_math.dart`, mappers, PDF builders |
| Widget | `DayHeader`, `HtmlContentView`, `EmptyState` |
| Integration | Auth → reflections shows correct day (mock Firestore) |

Start with **date math tests** — highest bug risk, lowest effort.

### Dependency cleanup (Phase 5)

Remove unused: `video_player`, `image_picker` (if profile photo keeps it, retain), `flutter_animate`, `auto_size_text` where replaced, FF git `dropdown_button2` fork → official package or custom.

---

## 5. Phased roadmap

Effort assumes **solo developer, ~15 hrs/week**. Adjust ±30% for full-time.

### Phase 0 — Foundation (1–2 weeks, ~20 hrs)

**Goal:** Safe baseline for incremental work.

- [ ] Add CI (`analyze`, `format`, `test`)
- [ ] Extract `core/domain/date_math.dart` from `custom_functions.dart` + unit tests
- [ ] Consolidate start date → Firestore authoritative; sync to SharedPreferences cache only
- [ ] Add `analysis_options.yaml` stricter lints (`prefer_single_quotes`, `always_declare_return_types`)
- [ ] Document env/flavor plan in README

**Quick wins:** Date tests, start-date fix, CI green.

**Do NOT:** Rewrite screens, change Firestore schema, deploy rules.

---

### Phase 1 — Design system + shared components (2–3 weeks, ~35 hrs)

**Goal:** Reusable UI kit; one pilot screen.

- [ ] `PaediaTheme` + tokens; enable M3
- [ ] Build P0 components (scaffold, bottom nav, html view, empty, loading)
- [ ] Migrate `HtmlTextDisplay` → `HtmlContentView` with `flutter_widget_from_html`
- [ ] Pilot: rewrite **Manual hub** (`ManualWidget`) — smallest tab, validates accordion + navigation

**Quick wins:** Bottom nav labels, empty states, themed HTML.

**Do NOT:** Riverpod migration everywhere yet; wrap pilot in Provider if needed.

---

### Phase 2 — Architecture layer (3–4 weeks, ~45 hrs)

**Goal:** Repositories + Riverpod + typed routes shell.

- [ ] Add Riverpod; `daysRepository`, `userRepository`, `manualsRepository`, `groupsRepository`
- [ ] freezed models + mappers for `Day`, `UserProfile`, `ManualSection`, `Group`
- [ ] `StatefulShellRoute` bottom nav; deprecate `NavBarPage`
- [ ] Auth redirect cleanup

**Quick wins:** Tab URLs work, `/today` shareable.

**Do NOT:** Drift yet; repositories talk Firestore only.

---

### Phase 3 — Feature screen rewrites (6–8 weeks, ~90 hrs)

**Goal:** Replace FF pages one by one.

| Order | Screen | Rationale |
|-------|--------|-----------|
| 1 | Reflections | Core daily use; validates DayHeader + HTML |
| 2 | Profile | Unblocks onboarding UX |
| 3 | Community | Simpler data |
| 4 | Participant + Accessory manuals | Heavy HTML; reuse ManualAccordion |
| 5 | Login + onboarding | Largest file; do last when patterns proven |
| 6 | Users detail, popups | Small |

Delete corresponding `legacy/pages/*` as each ships.

**Do NOT:** Big-bang delete `flutter_flow/` until Phase 3 complete.

---

### Phase 4 — Offline + PDF (4–6 weeks, ~60 hrs)

**Goal:** Deliver stated product goals.

- [ ] Drift schema + sync service
- [ ] Prefetch on login / manual refresh
- [ ] Offline banner + settings toggle "Download all content"
- [ ] PDF export for day + manual
- [ ] Share sheet integration

**Do NOT:** Block online-only users — offline enhances, not required.

---

### Phase 5 — Production hardening (2–3 weeks, ~30 hrs)

**Goal:** Ship-quality security and ops.

- [ ] Firebase App Check
- [ ] Rules PR (uid-scoped users, remove FF account, remove expired rule)
- [ ] Staging Firebase project for future CMS experiments
- [ ] Crash reporting (Firebase Crashlytics)
- [ ] Store release pipeline (Fastlane optional)
- [ ] Remove `lib/flutter_flow/` entirely
- [ ] Retire FlutterFlow CLI from workflow

**Do NOT:** Deploy rules without App Check + client update coordinated.

---

### Phase 6 (optional) — Schema + CMS cleanup (2–4 weeks, ~25 hrs)

**Goal:** Long-term maintainability — **requires Retool + Rowy coordination**.

- [ ] Add `subtitle` field to `days`; backfill from `Sybtitle`; keep reading both during migration
- [ ] Normalize field casing (document mapping layer even if Firestore unchanged)
- [ ] Rename `accessoryManual` → `accessory_manual` (or vice versa) — **breaking**; dual-read period
- [ ] Tighten `users` rules to owner-only write

**Do NOT:** Rename fields without dual-write/dual-read window and CMS update.

---

### What NOT to do (anti-patterns)

| Avoid | Why |
|-------|-----|
| Re-export from FlutterFlow over this repo | Wipes hand edits despite `.flutterflowignore` risk |
| Big-bang rewrite in one branch | 6+ months of no releases |
| Bloc + Riverpod + Provider | Pick Riverpod, remove others gradually |
| Custom design system without M3 | Reinvents accessibility and platform adaptivity |
| Raw sqflite | Drift gives type safety + migrations |
| Staging schema changes on prod | Use staging Firebase project |
| Blocking UI on Firestore during splash | Cache-first after Phase 4 |
| Premature micro-frontend split | 67 files don't need modular monorepo yet |

---

## 6. Retool / Firebase strategy

### Keep (recommended)

| Asset | Reason |
|-------|--------|
| **Retool CMS** | Non-dev content editors; works today |
| **Firestore collections** | Production data; app depends on field names |
| **Rowy admin roles** | Existing `_rowy_` rules for admin |
| **Read-only content rules** | `days`, `manuals`, `groups` client read-only — good |
| **Firebase Auth providers** | Google, Apple, email already wired |

### Optional schema cleanup (Phase 6)

| Issue | Recommendation |
|-------|----------------|
| `Sybtitle` typo | Add correct `subtitle` field in Retool; app dual-read; deprecate typo in 2 releases |
| PascalCase vs camelCase in `days` | Keep Firestore as-is; normalize in freezed mappers (`@JsonKey(name: 'Sybtitle')`) |
| `accessoryManual` vs `participant_manual` naming | Document inconsistency; unify on new staging project first |
| `users` mixed snake/camel | Map in repository: `display_name` → `displayName` |
| `users` write rule too open | Change to `request.auth.uid == documentId` after App Check |
| FlutterFlow service account rule | Remove when no longer using FF deploy |
| Expired May 2025 temp rule | Safe removal in rules PR |
| `usersIDs` on groups | Rename to `userIds` in future — low priority |

### Retool workflow (unchanged)

Editors update HTML in Retool → Firestore → app streams/refreshes. For offline, add **webhook or scheduled function** (future) to bump `contentVersion` doc that triggers client prefetch — optional enhancement.

### Firebase project hygiene

1. Create **`paedia-staging`** project (clone rules, empty collections, seed test days)
2. Never run `firebase deploy` from this repo without `--dry-run` review (see `PRODUCTION_SAFETY.md`)
3. Add composite indexes only when Firestore console prompts — document in `firebase/firestore.indexes.json`

---

## Success metrics

| Metric | Target |
|--------|--------|
| FF-generated LOC in `lib/pages/` | 0 by Phase 5 end |
| Test coverage (domain + widgets) | >60% on `core/` and `shared/` |
| Cold start to today's reflection | <2s online, <500ms offline (cached) |
| Crash-free sessions | >99.5% after Crashlytics |
| Accessibility | WCAG 2.1 AA on reading screens |
| Store rating maintenance | No regression during migration |

---

## Appendix A — File migration checklist

When rewriting a screen:

- [ ] Create `features/<name>/<name>_screen.dart`
- [ ] Wire route in `app_router.dart`
- [ ] Move business logic to repository/notifier
- [ ] Replace `FlutterFlowTheme.of(context)` → `Theme.of(context)` + extensions
- [ ] Replace `safeSetState` → standard `setState` or Riverpod
- [ ] Delete `*_widget.dart`, `*_model.dart`
- [ ] Update `index.dart` exports
- [ ] Add widget test
- [ ] Verify web + iOS + Android

---

## Appendix B — Immediate quick wins (< 1 week)

1. Fix date math — single implementation + tests
2. Unify start date source (Firestore wins)
3. Bottom nav labels + semantics
4. Empty states instead of blank containers
5. Show "Day N of 90" + progress bar in reflections header
6. Post-day-90 completion message
7. Gender content subtitle on manual screens
8. Enable `useMaterial3: true` with existing colors

---

## Appendix C — Reference links

- [Flutter go_router shell routes](https://pub.dev/documentation/go_router/latest/topics/Stateful%20shell%20route-topic.html)
- [Riverpod](https://riverpod.dev)
- [Drift](https://drift.simonbinder.eu)
- [flutter_widget_from_html](https://pub.dev/packages/flutter_widget_from_html)
- [printing package](https://pub.dev/packages/printing)
- [Firebase App Check](https://firebase.google.com/docs/app-check)
- Internal: `docs/PRODUCTION_SAFETY.md`, `docs/MOBILE_SETUP.md`

---

*This document is a planning artifact. Implementation PRs should reference the phase and section they advance.*
