import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/domain/date_math.dart';
import '/core/providers/repositories_provider.dart';
import '/data/models/day.dart';
import '/data/models/user_profile.dart';

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  return ref.watch(userRepositoryProvider).watchCurrentUser();
});

final todayDayProvider = StreamProvider<Day?>((ref) {
  final daysRepo = ref.watch(daysRepositoryProvider);
  return ref.watch(userRepositoryProvider).watchCurrentUser().asyncExpand(
        (profile) => daysRepo.watchToday(profile?.startDate),
      );
});

final pastDaysProvider = StreamProvider<List<Day>>((ref) {
  final daysRepo = ref.watch(daysRepositoryProvider);
  return ref.watch(userRepositoryProvider).watchCurrentUser().asyncExpand(
        (profile) => daysRepo.watchPastDays(profile?.startDate),
      );
});

final programmeStatusProvider = Provider<ProgrammeStatus>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  return programmeStatusFromProfile(profile);
});

ProgrammeStatus programmeStatusFromProfile(UserProfile? profile) {
  if (profile == null || !profile.hasGender) {
    return ProgrammeStatus.needsGender;
  }
  if (!profile.hasStartDate) {
    return ProgrammeStatus.needsStartDate;
  }
  final start = profile.startDate!;
  if (programmeDayNumber(start) == null &&
      dayOffsetFromStart(start) != null &&
      dayOffsetFromStart(start)! < 0) {
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
