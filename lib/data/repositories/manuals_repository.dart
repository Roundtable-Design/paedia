import '/backend/backend.dart';
import '/data/models/manual_section.dart';

class ManualsRepository {
  Stream<List<ManualSection>> watchParticipantManual({String? gender}) {
    return queryParticipantManualRecord(
      queryBuilder: (q) {
        var query = q.orderBy('Position');
        if (gender != null && gender.isNotEmpty) {
          query = query.where('gender', isEqualTo: gender);
        }
        return query;
      },
    ).map(
      (records) =>
          records.map(ManualSection.fromParticipant).toList(growable: false),
    );
  }

  Stream<List<ManualSection>> watchAccessoryManual({String? gender}) {
    return queryAccessoryManualRecord(
      queryBuilder: (q) {
        var query = q.orderBy('order');
        if (gender != null && gender.isNotEmpty) {
          query = query.where('gender', isEqualTo: gender);
        }
        return query;
      },
    ).map(
      (records) =>
          records.map(ManualSection.fromAccessory).toList(growable: false),
    );
  }
}
