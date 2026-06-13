import '/backend/backend.dart';

/// Immutable profile fields used by feature screens.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl = '',
    this.gender = '',
    this.startDate,
    this.whyStatement = '',
    this.closingStatement = '',
  });

  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String gender;
  final DateTime? startDate;
  final String whyStatement;
  final String closingStatement;

  bool get hasGender => gender.isNotEmpty;
  bool get hasStartDate => startDate != null;

  factory UserProfile.fromRecord(UsersRecord record) {
    return UserProfile(
      uid: record.uid,
      email: record.email,
      displayName: record.displayName,
      photoUrl: record.photoUrl,
      gender: record.gender,
      startDate: record.startDate,
      whyStatement: record.whyStatement,
      closingStatement: record.closingStatement,
    );
  }
}
