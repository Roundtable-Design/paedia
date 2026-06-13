# Firestore rules review (CLI audit)

**Date:** 2026-06-13  
**Production project:** `paedia-fqv6h9`  
**Proposed file:** `firebase/firestore.rules.proposed`  
**Status:** Proposed rules **NOT deployed**

## Deployed rules (production)

Current `firebase/firestore.rules` compiles successfully:

```bash
cd firebase
npx firebase-tools@latest deploy --only firestore:rules --dry-run --project paedia-fqv6h9
# ✔ rules file firestore.rules compiled successfully
```

## Critical issues in **deployed** rules (fix via proposed)

| Issue | Risk | Proposed fix |
|-------|------|--------------|
| `users` allow write for **any** authenticated user | Users can edit other users' profiles | Scope writes to `request.auth.uid == userId` |
| FlutterFlow service account rule (`firebase@flutterflow.io`) | Backdoor full DB access | **Removed** |
| Expired temp rule (`request.time < 2025-05-08`) | Was emergency open access; now dead code | **Removed** |

## Proposed rules summary

- Read paths unchanged for `days`, `groups`, manuals (auth required).
- `users/{userId}` writes limited to document owner.
- Rowy admin paths preserved for Retool CMS.
- No deploy until App Check enforced — see [APP_CHECK_SETUP.md](APP_CHECK_SETUP.md).

## Staging deploy (next step)

1. Create Firestore in `paedia-staging` (Console — see [STAGING.md](STAGING.md)).
2. Dry-run proposed rules:

```bash
cd firebase
npx firebase-tools@latest deploy --only firestore:rules --dry-run --project paedia-staging
```

3. After App Check on staging, deploy for real and smoke-test with test accounts.

## Production deploy (last)

Only after staging validation + App Check enforcement on prod:

```bash
# Replace firestore.rules with reviewed proposed content, then:
npx firebase-tools@latest deploy --only firestore:rules --project paedia-fqv6h9
```

Coordinate with Retool operators before prod deploy.
