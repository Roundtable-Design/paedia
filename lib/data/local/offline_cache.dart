import '/data/models/day.dart';
import '/data/repositories/days_repository.dart';

/// Phase 4 offline layer — Drift-backed cache will implement this interface.
abstract class OfflineDaysCache {
  Future<Day?> getDay(int dayNumber);
  Future<void> putDay(Day day);
  Future<void> clear();
}

/// Read-through decorator: Firestore today, local cache in Phase 4.
class CachedDaysRepository {
  CachedDaysRepository({
    required DaysRepository remote,
    OfflineDaysCache? cache,
  })  : _remote = remote,
        _cache = cache;

  final DaysRepository _remote;
  final OfflineDaysCache? _cache;

  Stream<Day?> watchToday(DateTime? startDate) {
    return _remote.watchToday(startDate);
  }
}
