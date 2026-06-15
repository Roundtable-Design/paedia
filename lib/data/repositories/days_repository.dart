import '/backend/backend.dart';
import '/core/domain/date_math.dart';
import '/core/services/days_cache_holder.dart';
import '/data/models/day.dart';

/// Repository for programme day content from Firestore.
class DaysRepository {
  Stream<List<DaysRecord>> watchDays({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    return queryDaysRecord(
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );
  }

  Stream<Day?> watchDay(int dayNumber) {
    return watchDays(
      queryBuilder: (q) => q.where('DayNumber', isEqualTo: dayNumber),
      singleRecord: true,
    ).map((records) => toDomain(records.isEmpty ? null : records.first));
  }

  Stream<Day?> watchToday(DateTime? startDate) {
    final dayNumber = programmeDayNumber(startDate);
    if (dayNumber == null) {
      return Stream.value(null);
    }
    return watchDay(dayNumber);
  }

  Stream<List<Day>> watchPastDays(DateTime? startDate) {
    final currentDay = programmeDayNumber(startDate);
    if (currentDay == null || currentDay <= 1) {
      return Stream.value([]);
    }
    return watchDays(
      queryBuilder: (q) => q
          .where('DayNumber', isLessThan: currentDay)
          .orderBy('DayNumber', descending: true),
    ).map(toDomainList);
  }

  Future<List<DaysRecord>> getDaysOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    return queryDaysRecordOnce(
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );
  }

  Day? toDomain(DaysRecord? record) {
    if (record == null) return null;
    return Day.fromRecord(record);
  }

  List<Day> toDomainList(List<DaysRecord> records) {
    return records.map(Day.fromRecord).toList(growable: false);
  }

  /// Fetches a day from cache when available, otherwise Firestore, then caches.
  Future<Day?> getDayCachedFirst(int dayNumber) async {
    final cache = DaysCacheHolder.instance;
    if (cache != null) {
      final cached = await cache.getDay(dayNumber);
      if (cached != null) return cached;
    }

    final records = await getDaysOnce(
      queryBuilder: (q) => q.where('DayNumber', isEqualTo: dayNumber),
      singleRecord: true,
    );
    final day = toDomain(records.isEmpty ? null : records.first);
    if (day != null && cache != null) {
      await cache.putDay(day);
    }
    return day;
  }
}
