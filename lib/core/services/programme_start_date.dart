import '/app_state.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/core/domain/date_math.dart';
import '/data/models/user_profile.dart';

/// Resolves the user's programme start date.
///
/// Firestore [UsersRecord.startDate] is authoritative once present.
/// [FFAppState.startDate] covers onboarding/profile saves before the user
/// stream catches up.
class ProgrammeStartDateService {
  const ProgrammeStartDateService();

  /// Authoritative start date: Firestore first, then local cache.
  DateTime? get startDate =>
      resolveProgrammeStartDateFromRecord(currentUserDocument) ??
      resolveProgrammeStartDate(null);

  /// Sync Firestore start date into [FFAppState] when the server value differs.
  void syncCacheFromFirestore() {
    final fromFirestore = currentUserDocument?.startDate;
    if (fromFirestore == null) return;
    final normalized = normalizeProgrammeStartDate(fromFirestore);
    final local = FFAppState().startDate;
    if (local == null || normalizeProgrammeStartDate(local) != normalized) {
      FFAppState().startDate = normalized;
    }
  }
}

/// Resolves the programme start date for feature providers.
DateTime? resolveProgrammeStartDate(UserProfile? profile) {
  final fromProfile = profile?.startDate;
  if (fromProfile != null) {
    final normalized = normalizeProgrammeStartDate(fromProfile);
    final local = FFAppState().startDate;
    if (local == null || normalizeProgrammeStartDate(local) != normalized) {
      FFAppState().startDate = normalized;
    }
    return normalized;
  }

  final local = FFAppState().startDate;
  return local != null ? normalizeProgrammeStartDate(local) : null;
}

DateTime? resolveProgrammeStartDateFromRecord(UsersRecord? record) {
  if (record == null || !record.hasStartDate()) return null;
  return normalizeProgrammeStartDate(record.startDate!);
}
