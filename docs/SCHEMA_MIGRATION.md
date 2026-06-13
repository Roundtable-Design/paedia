# Phase 6 — Schema & CMS cleanup (optional)

Requires Retool / Rowy coordination. **Dual-read / dual-write window mandatory.**

## Known inconsistencies

| Issue | Recommendation |
|-------|----------------|
| `Sybtitle` typo on `days` | Add `subtitle` in Retool; app reads both via `Day.fromRecord` |
| PascalCase vs camelCase in `days` | Normalize in repository mappers only |
| `accessoryManual` vs `participant_manual` | Document; unify on staging first |
| `users` open write rule | Tighten in Phase 5 rules PR |
| `usersIDs` on groups | Rename to `userIds` in future release |

## Migration pattern

1. Add new field in Retool CMS.
2. Backfill existing documents.
3. App dual-reads old + new fields for two releases.
4. Stop writing old field; remove read after adoption.

## Do not

- Rename Firestore collections in prod without staging validation.
- Deploy breaking rules without App Check enabled.
