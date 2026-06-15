import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/domain/date_math.dart';
import '/core/providers/repositories_provider.dart';
import '/core/services/programme_start_date.dart';
import '/data/models/day.dart';
import '/data/models/user_profile.dart';

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  return ref.watch(userRepositoryProvider).watchCurrentUser();
});

final programmeStartDateProvider = Provider<DateTime?>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  return resolveProgrammeStartDate(profile);
});

final todayDayProvider = StreamProvider<Day?>((ref) {
  final startDate = ref.watch(programmeStartDateProvider);
  final daysRepo = ref.watch(daysRepositoryProvider);

  if (startDate == null || isProgrammePreStart(startDate)) {
    return Stream.value(null);
  }

  final dayNumber = programmeDayNumber(startDate);
  if (dayNumber == null) {
    return Stream.value(null);
  }

  return daysRepo.watchDay(dayNumber);
});

final pastDaysProvider = StreamProvider<List<Day>>((ref) {
  final startDate = ref.watch(programmeStartDateProvider);
  final daysRepo = ref.watch(daysRepositoryProvider);

  if (startDate == null || isProgrammePreStart(startDate)) {
    return Stream.value([]);
  }

  return daysRepo.watchPastDays(startDate);
});

final programmeStatusProvider = Provider<ProgrammeStatus>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  final startDate = ref.watch(programmeStartDateProvider);
  return programmeStatusFromProfile(profile, startDate: startDate);
});

ProgrammeStatus programmeStatusFromProfile(
  UserProfile? profile, {
  DateTime? startDate,
}) {
  if (profile == null || !profile.hasGender) {
    return ProgrammeStatus.needsGender;
  }

  final start = startDate ?? resolveProgrammeStartDate(profile);
  if (start == null) {
    return ProgrammeStatus.needsStartDate;
  }

  if (isProgrammePreStart(start)) {
    return ProgrammeStatus.preStart;
  }
  if (isProgrammeComplete(start)) {
    return ProgrammeStatus.complete;
  }
  if (programmeDayNumber(start) != null) {
    return ProgrammeStatus.active;
  }
  return ProgrammeStatus.unavailable;
}

enum ProgrammeStatus {
  needsGender,
  needsStartDate,
  preStart,
  active,
  complete,
  unavailable,
}
