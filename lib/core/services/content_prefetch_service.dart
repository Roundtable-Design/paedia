import 'package:flutter/foundation.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/core/domain/date_math.dart';
import '/core/services/days_cache_holder.dart';
import '/data/repositories/days_repository.dart';

/// Prefetches programme days around today into the local SQLite cache.
class ContentPrefetchService {
  ContentPrefetchService({DaysRepository? daysRepository})
      : _daysRepository = daysRepository ?? DaysRepository();

  final DaysRepository _daysRepository;

  Future<void> prefetchForCurrentUser() async {
    if (kIsWeb || DaysCacheHolder.instance == null) return;

    final startDate = currentUserDocument?.startDate;
    final today = programmeDayNumber(startDate);
    if (today == null) return;

    final from = (today - 7).clamp(1, 90);
    final to = (today + 7).clamp(1, 90);

    for (var day = from; day <= to; day++) {
      try {
        await _daysRepository.getDayCachedFirst(day);
      } catch (e) {
        debugPrint('Prefetch day $day failed: $e');
      }
    }
  }
}
