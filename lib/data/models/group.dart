import '/backend/backend.dart';

class PaediaGroup {
  const PaediaGroup({
    required this.id,
    required this.name,
    required this.memberIds,
  });

  final String id;
  final String name;
  final List<String> memberIds;

  factory PaediaGroup.fromRecord(GroupsRecord record) {
    return PaediaGroup(
      id: record.reference.id,
      name: record.groupName,
      memberIds: record.usersIDs,
    );
  }
}
