import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/backend.dart';

class GroupKeyDate {
  const GroupKeyDate({required this.label, this.date});

  final String label;
  final DateTime? date;

  Map<String, dynamic> toMap() => {
        'label': label,
        if (date != null) 'date': Timestamp.fromDate(date!),
      };

  factory GroupKeyDate.fromDynamic(dynamic value) {
    if (value is! Map) {
      return const GroupKeyDate(label: '');
    }
    final map = Map<String, dynamic>.from(value);
    final rawDate = map['date'];
    DateTime? date;
    if (rawDate is Timestamp) {
      date = rawDate.toDate();
    } else if (rawDate is DateTime) {
      date = rawDate;
    }
    return GroupKeyDate(
      label: map['label']?.toString() ?? '',
      date: date,
    );
  }
}

class PaediaGroup {
  const PaediaGroup({
    required this.id,
    required this.name,
    required this.memberIds,
    required this.reference,
    this.keyDates = const [],
  });

  final String id;
  final String name;
  final List<String> memberIds;
  final DocumentReference reference;
  final List<GroupKeyDate> keyDates;

  factory PaediaGroup.fromRecord(GroupsRecord record) {
    final rawDates = record.snapshotData['keyDates'];
    final keyDates = rawDates is List
        ? rawDates
            .map(GroupKeyDate.fromDynamic)
            .where((d) => d.label.isNotEmpty)
            .toList(growable: false)
        : const <GroupKeyDate>[];

    return PaediaGroup(
      id: record.reference.id,
      name: record.groupName,
      memberIds: record.usersIDs,
      reference: record.reference,
      keyDates: keyDates,
    );
  }
}
