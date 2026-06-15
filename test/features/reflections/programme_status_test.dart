import 'package:flutter_test/flutter_test.dart';
import 'package:paedia/core/domain/date_math.dart';
import 'package:paedia/data/models/user_profile.dart';
import 'package:paedia/features/reflections/reflections_providers.dart';

UserProfile profile({
  String gender = '',
  DateTime? startDate,
}) {
  return UserProfile(
    uid: 'test',
    email: 'test@example.com',
    displayName: 'Test',
    gender: gender,
    startDate: startDate,
  );
}

void main() {
  test('needsGender when profile has no gender', () {
    expect(
      programmeStatusFromProfile(
        profile(startDate: DateTime(2026, 1, 1)),
      ),
      ProgrammeStatus.needsGender,
    );
  });

  test('needsStartDate when gender set but no start date', () {
    expect(
      programmeStatusFromProfile(profile(gender: 'Male')),
      ProgrammeStatus.needsStartDate,
    );
  });

  test('active when on programme day 30', () {
    final start = DateTime.now().subtract(const Duration(days: 29));
    final normalized = DateTime(start.year, start.month, start.day);
    expect(
      programmeStatusFromProfile(
        profile(gender: 'Male', startDate: normalized),
        startDate: normalized,
      ),
      ProgrammeStatus.active,
    );
    expect(programmeDayNumber(normalized), 30);
  });

  test('preStart when start date is in the future', () {
    final future = DateTime.now().add(const Duration(days: 5));
    final start = DateTime(future.year, future.month, future.day);
    expect(
      programmeStatusFromProfile(
        profile(gender: 'Male', startDate: start),
        startDate: start,
      ),
      ProgrammeStatus.preStart,
    );
    expect(isProgrammePreStart(start), isTrue);
    expect(programmeDayNumber(start), isNull);
  });

  test('complete when past day 90', () {
    final start = DateTime.now().subtract(const Duration(days: 100));
    final normalized = DateTime(start.year, start.month, start.day);
    expect(
      programmeStatusFromProfile(
        profile(gender: 'Female', startDate: normalized),
        startDate: normalized,
      ),
      ProgrammeStatus.complete,
    );
    expect(isProgrammeComplete(normalized), isTrue);
  });
}
