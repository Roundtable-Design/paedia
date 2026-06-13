import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
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
    await currentUserReference?.update(
      createUsersRecordData(startDate: startDate),
    );
  }

  Future<void> updateGender(String gender) async {
    await currentUserReference?.update(
      createUsersRecordData(gender: gender),
    );
  }
}
