import 'package:flutter_test/flutter_test.dart';
import 'package:paedia/core/domain/date_math.dart';

DateTime _calendarDaysBefore(DateTime date, int days) {
  var current = DateTime(date.year, date.month, date.day);
  for (var i = 0; i < days; i++) {
    current = current.subtract(const Duration(days: 1));
    current = DateTime(current.year, current.month, current.day);
  }
  return current;
}

void main() {
  group('toLocalDateOnly', () {
    test('strips time component', () {
      final result = toLocalDateOnly(DateTime(2026, 3, 15, 23, 45));
      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.year, 2026);
      expect(result.month, 3);
      expect(result.day, 15);
    });
  });

  group('dayOffsetFromStart', () {
    test('returns null when start date is null', () {
      expect(dayOffsetFromStart(null), isNull);
    });

    test('returns 0 on start day', () {
      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day);
      expect(dayOffsetFromStart(start), 0);
    });

    test('returns negative before start', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final start = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
      expect(dayOffsetFromStart(start), -1);
    });

    test('returns positive after start', () {
      final yesterday = _calendarDaysBefore(DateTime.now(), 1);
      expect(dayOffsetFromStart(yesterday), 1);
    });
  });

  group('programmeDayNumber', () {
    test('returns null when start date is null', () {
      expect(programmeDayNumber(null), isNull);
    });

    test('returns null before programme starts', () {
      final future = DateTime.now().add(const Duration(days: 5));
      final start = DateTime(future.year, future.month, future.day);
      expect(programmeDayNumber(start), isNull);
    });

    test('returns 1 on first day', () {
      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day);
      expect(programmeDayNumber(start), 1);
    });

    test('returns 90 on final day', () {
      final start = _calendarDaysBefore(DateTime.now(), 89);
      expect(programmeDayNumber(start), 90);
    });

    test('returns null after day 90', () {
      final start = _calendarDaysBefore(DateTime.now(), 90);
      expect(programmeDayNumber(start), isNull);
    });
  });

  group('programmeDayLabel', () {
    test('returns countdown before start', () {
      final future = DateTime.now().add(const Duration(days: 3));
      final start = DateTime(future.year, future.month, future.day);
      expect(programmeDayLabel(start), 'Your Paedia starts in 3 days');
    });

    test('returns singular countdown', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final start = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
      expect(programmeDayLabel(start), 'Your Paedia starts in 1 day');
    });

    test('returns day label during programme', () {
      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day);
      expect(programmeDayLabel(start), 'Day 1');
    });

    test('returns completion message after day 90', () {
      final start = _calendarDaysBefore(DateTime.now(), 91);
      expect(
        programmeDayLabel(start),
        'Programme complete — congratulations on finishing Paedia!',
      );
    });
  });

  group('programmeEndDate', () {
    test('adds 90 days to start', () {
      final start = DateTime(2026, 1, 1);
      final end = programmeEndDate(start)!;
      expect(end.year, 2026);
      expect(end.month, 4);
      expect(end.day, 1);
    });

    test('returns null when start is null', () {
      expect(programmeEndDate(null), isNull);
    });
  });

  group('isProgrammeComplete', () {
    test('false when not started', () {
      final future = DateTime.now().add(const Duration(days: 1));
      final start = DateTime(future.year, future.month, future.day);
      expect(isProgrammeComplete(start), isFalse);
    });

    test('false on day 90', () {
      final start = _calendarDaysBefore(DateTime.now(), 89);
      expect(isProgrammeComplete(start), isFalse);
    });

    test('true after day 90', () {
      final start = _calendarDaysBefore(DateTime.now(), 90);
      expect(isProgrammeComplete(start), isTrue);
    });
  });

  group('specialDayLabel', () {
    test('returns a string for the current weekday', () {
      final label = specialDayLabel();
      expect(label, isA<String>());
    });
  });
}
