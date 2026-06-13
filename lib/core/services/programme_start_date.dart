import '/app_state.dart';
import '/auth/firebase_auth/auth_util.dart';

/// Resolves the user's programme start date.
///
/// Firestore [UsersRecord.startDate] is authoritative; [FFAppState.startDate]
/// is a local cache synced from Firestore when available.
class ProgrammeStartDateService {
  const ProgrammeStartDateService();

  /// Authoritative start date: Firestore first, then local cache.
  DateTime? get startDate =>
      currentUserDocument?.startDate ?? FFAppState().startDate;

  /// Sync Firestore start date into [FFAppState] when the server value differs.
  void syncCacheFromFirestore() {
    final fromFirestore = currentUserDocument?.startDate;
    if (fromFirestore == null) return;
    if (FFAppState().startDate != fromFirestore) {
      FFAppState().startDate = fromFirestore;
    }
  }
}
