import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/core/domain/date_math.dart';
import '/data/models/user_profile.dart';

class UserRepository {
  Stream<UserProfile?> watchCurrentUser() {
    final uid = currentUserUid;
    if (uid.isEmpty) {
      return Stream.value(null);
    }
    return UsersRecord.getDocument(UsersRecord.collection.doc(uid))
        .map((record) => UserProfile.fromRecord(record));
  }

  Future<UserProfile?> getCurrentUserOnce() async {
    final uid = currentUserUid;
    if (uid.isEmpty) return null;
    final record = await UsersRecord.getDocumentOnce(
      UsersRecord.collection.doc(uid),
    );
    return UserProfile.fromRecord(record);
  }

  Future<void> updateStartDate(DateTime startDate) async {
    final normalized = normalizeProgrammeStartDate(startDate);
    await currentUserReference?.update(
      createUsersRecordData(startDate: normalized),
    );
  }

  Future<void> updateGender(String gender) async {
    await currentUserReference?.update(
      createUsersRecordData(gender: gender),
    );
  }

  Future<void> updateDisplayName(String displayName) async {
    final trimmed = displayName.trim();
    await FirebaseAuth.instance.currentUser?.updateDisplayName(trimmed);
    await currentUserReference?.update(
      createUsersRecordData(displayName: trimmed),
    );
  }

  Future<void> updatePhotoUrl(String photoUrl) async {
    await FirebaseAuth.instance.currentUser?.updatePhotoURL(photoUrl);
    await currentUserReference?.update(
      createUsersRecordData(photoUrl: photoUrl),
    );
  }

  /// Copies the photo URL from the linked social provider (Google/Apple).
  Future<bool> syncPhotoFromAuthProvider() async {
    final photoUrl = FirebaseAuth.instance.currentUser?.photoURL;
    if (photoUrl == null || photoUrl.isEmpty) return false;
    await updatePhotoUrl(photoUrl);
    return true;
  }

  Future<String?> uploadProfilePhoto(Uint8List bytes,
      {String? fileName}) async {
    final uid = currentUserUid;
    if (uid.isEmpty) return null;
    final ext = _extensionFromName(fileName) ?? 'jpg';
    final path =
        'users/$uid/profile_${DateTime.now().millisecondsSinceEpoch}.$ext';
    return uploadData(path, bytes);
  }

  List<String> linkedProviderIds() {
    return FirebaseAuth.instance.currentUser?.providerData
            .map((info) => info.providerId)
            .where((id) => id.isNotEmpty)
            .toList(growable: false) ??
        const [];
  }

  bool get hasPasswordProvider => linkedProviderIds().contains('password');

  bool get hasGoogleProvider => linkedProviderIds().contains('google.com');

  bool get hasAppleProvider => linkedProviderIds().contains('apple.com');

  Future<void> linkEmailPassword({
    required String email,
    required String password,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final credential = EmailAuthProvider.credential(
      email: email.trim(),
      password: password,
    );
    await user.linkWithCredential(credential);
    await updateUserDocument(email: email.trim());
  }

  String? _extensionFromName(String? name) {
    if (name == null || !name.contains('.')) return null;
    return name.split('.').last.toLowerCase();
  }
}

/// Split a stored display name into first / last for editing.
(String firstName, String lastName) splitDisplayName(String displayName) {
  final parts = displayName.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || (parts.length == 1 && parts.first.isEmpty)) {
    return ('', '');
  }
  if (parts.length == 1) return (parts.first, '');
  return (parts.first, parts.sublist(1).join(' '));
}

String joinDisplayName(String firstName, String lastName) {
  return '${firstName.trim()} ${lastName.trim()}'.trim();
}

String providerLabel(String providerId) {
  return switch (providerId) {
    'password' => 'Email & password',
    'google.com' => 'Google',
    'apple.com' => 'Apple',
    'phone' => 'Phone',
    _ => providerId,
  };
}
