import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/services/days_cache_holder.dart';
import '/data/repositories/days_repository.dart';
import '/data/repositories/groups_repository.dart';
import '/data/repositories/manuals_repository.dart';
import '/data/repositories/user_repository.dart';

final daysRepositoryProvider = Provider<DaysRepository>((ref) {
  return DaysRepository(cache: DaysCacheHolder.instance);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final groupsRepositoryProvider = Provider<GroupsRepository>((ref) {
  return GroupsRepository();
});

final manualsRepositoryProvider = Provider<ManualsRepository>((ref) {
  return ManualsRepository();
});
