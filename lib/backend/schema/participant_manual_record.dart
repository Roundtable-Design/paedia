import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ParticipantManualRecord extends FirestoreRecord {
  ParticipantManualRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "Title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "Text" field.
  String? _text;
  String get text => _text ?? '';
  bool hasText() => _text != null;

  // "Position" field.
  int? _position;
  int get position => _position ?? 0;
  bool hasPosition() => _position != null;

  // "gender" field.
  String? _gender;
  String get gender => _gender ?? '';
  bool hasGender() => _gender != null;

  void _initializeFields() {
    _title = snapshotData['Title'] as String?;
    _text = snapshotData['Text'] as String?;
    _position = castToType<int>(snapshotData['Position']);
    _gender = snapshotData['gender'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('participant_manual');

  static Stream<ParticipantManualRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ParticipantManualRecord.fromSnapshot(s));

  static Future<ParticipantManualRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => ParticipantManualRecord.fromSnapshot(s));

  static ParticipantManualRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ParticipantManualRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ParticipantManualRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ParticipantManualRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ParticipantManualRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ParticipantManualRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createParticipantManualRecordData({
  String? title,
  String? text,
  int? position,
  String? gender,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'Title': title,
      'Text': text,
      'Position': position,
      'gender': gender,
    }.withoutNulls,
  );

  return firestoreData;
}

class ParticipantManualRecordDocumentEquality
    implements Equality<ParticipantManualRecord> {
  const ParticipantManualRecordDocumentEquality();

  @override
  bool equals(ParticipantManualRecord? e1, ParticipantManualRecord? e2) {
    return e1?.title == e2?.title &&
        e1?.text == e2?.text &&
        e1?.position == e2?.position &&
        e1?.gender == e2?.gender;
  }

  @override
  int hash(ParticipantManualRecord? e) =>
      const ListEquality().hash([e?.title, e?.text, e?.position, e?.gender]);

  @override
  bool isValidKey(Object? o) => o is ParticipantManualRecord;
}
