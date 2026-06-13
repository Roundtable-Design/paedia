# Staging Firebase project

Use a separate project for rules and CMS experiments — never test write rule changes on `paedia-fqv6h9`.

## Create `paedia-staging`

```bash
# In Firebase Console: create project paedia-staging (or org naming convention)
firebase projects:create paedia-staging
cd firebase
firebase use --add   # alias: staging
```

## Seed minimal data

- Copy structure of `days`, `users`, `groups`, `participant_manual`, `accessoryManual` with test documents only.
- Point Retool staging workspace at staging Firestore (optional).

## Local dev against staging

```bash
flutter run --dart-define=FIREBASE_PROJECT=paedia-staging
```

(Future: wire `firebase_options` per flavor; today prod is default.)

## Before prod rules deploy

1. Deploy `firestore.rules.proposed` to **staging** first.
2. Run app against staging with test accounts.
3. Rules Playground + integration smoke on all platforms.
4. Promote same rules file to prod with App Check enforced.
