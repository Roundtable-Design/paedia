import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/data/models/group.dart';

class GroupsRepository {
  Stream<PaediaGroup?> watchCurrentUserGroup() {
    final uid = currentUserUid;
    if (uid.isEmpty) {
      return Stream.value(null);
    }
    return queryGroupsRecord(
      queryBuilder: (q) => q.where('usersIDs', arrayContains: uid),
      singleRecord: true,
    ).map((records) {
      if (records.isEmpty) return null;
      return PaediaGroup.fromRecord(records.first);
    });
  }

  Stream<List<UsersRecord>> watchGroupMembers(List<String> memberIds) {
    if (memberIds.isEmpty) {
      return Stream.value([]);
    }
    return queryUsersRecord(
      queryBuilder: (q) => q.whereIn('uid', memberIds),
    );
  }

  Future<void> updateKeyDates({
    required DocumentReference groupRef,
    required List<GroupKeyDate> keyDates,
  }) async {
    await groupRef.update({
      'keyDates': keyDates.map((d) => d.toMap()).toList(),
    });
  }

  Future<void> deleteGroup(DocumentReference groupRef) async {
    await groupRef.delete();
  }
}
