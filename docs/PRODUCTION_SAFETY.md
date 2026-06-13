# Production safety

This repo connects to the **live** Firebase project `paedia-fqv6h9` (production Paedia app).

## Safe by default

- Local development (`flutter run`) reads Firestore using existing client SDK config — same as the shipped FlutterFlow app.
- Retool admin continues to write content; no backend changes are required for bootstrap.
- `firebase/firestore.rules` and `firebase/storage.rules` were **pulled from production** (read-only API) so the repo matches live — not the simplified export rules.

## Do not run without explicit review

| Command | Risk |
|---------|------|
| `firebase deploy` | Overwrites live rules, indexes, functions, hosting |
| `flutterflow deploy-firebase` | Same — can overwrite production Firebase config |
| `firebase firestore:delete` | Destructive data loss |
| Deploying rules that tighten `users` without testing | Can lock users out of profile edits |

## Recommended deploy process (future)

1. Test rule changes in the Firebase **Rules Playground** or a staging project.
2. Deploy rules only: `cd firebase && npx firebase-tools@latest deploy --only firestore:rules --dry-run` then review diff.
3. Never deploy from a fresh FlutterFlow export without diffing `firebase/` against this repo.

## Known live rules notes (2026-06-13)

- Rowy admin roles (`ADMIN`, `OWNER`) manage `_rowy_` collections.
- FlutterFlow service account rule exists for `firebase@flutterflow.io` — remove when fully off FlutterFlow.
- Expired temporary open rule (May 2025) is inactive but should be cleaned up in a planned rules PR.
- `users` collection allows any authenticated user to write any user doc — tighten to `request.auth.uid == documentId` when ready.
