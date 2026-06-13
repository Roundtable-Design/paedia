import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/backend.dart';
import '/core/domain/date_math.dart';
import '/data/local/offline_cache.dart';
import '/data/models/day.dart';

/// Repository for programme day content from Firestore with optional local cache.
class DaysRepository {
  DaysRepository({OfflineDaysCache? cache}) : _cache = cache;

  final OfflineDaysCache? _cache;

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
    ).asyncMap((records) async {
      final domain = toDomain(records.isEmpty ? null : records.first);
      if (domain != null) {
        await _cache?.putDay(domain);
      }
      return domain ?? await _cache?.getDay(dayNumber);
    });
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

  Future<Day?> getDayCachedFirst(int dayNumber) async {
    final cached = await _cache?.getDay(dayNumber);
    if (cached != null) return cached;
    final records = await getDaysOnce(
      queryBuilder: (q) => q.where('DayNumber', isEqualTo: dayNumber),
      singleRecord: true,
    );
    final domain = toDomain(records.isEmpty ? null : records.first);
    if (domain != null) await _cache?.putDay(domain);
    return domain;
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
}
