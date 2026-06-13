import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AccessoryManualRecord extends FirestoreRecord {
  AccessoryManualRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "heading" field.
  String? _heading;
  String get heading => _heading ?? '';
  bool hasHeading() => _heading != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "order" field.
  int? _order;
  int get order => _order ?? 0;
  bool hasOrder() => _order != null;

  // "gender" field.
  String? _gender;
  String get gender => _gender ?? '';
  bool hasGender() => _gender != null;

  void _initializeFields() {
    _heading = snapshotData['heading'] as String?;
    _description = snapshotData['description'] as String?;
    _order = castToType<int>(snapshotData['order']);
    _gender = snapshotData['gender'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('accessoryManual');

  static Stream<AccessoryManualRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => AccessoryManualRecord.fromSnapshot(s));

  static Future<AccessoryManualRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => AccessoryManualRecord.fromSnapshot(s));

  static AccessoryManualRecord fromSnapshot(DocumentSnapshot snapshot) =>
      AccessoryManualRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static AccessoryManualRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      AccessoryManualRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'AccessoryManualRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is AccessoryManualRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createAccessoryManualRecordData({
  String? heading,
  String? description,
  int? order,
  String? gender,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'heading': heading,
      'description': description,
      'order': order,
      'gender': gender,
    }.withoutNulls,
  );

  return firestoreData;
}

class AccessoryManualRecordDocumentEquality
    implements Equality<AccessoryManualRecord> {
  const AccessoryManualRecordDocumentEquality();

  @override
  bool equals(AccessoryManualRecord? e1, AccessoryManualRecord? e2) {
    return e1?.heading == e2?.heading &&
        e1?.description == e2?.description &&
        e1?.order == e2?.order &&
        e1?.gender == e2?.gender;
  }

  @override
  int hash(AccessoryManualRecord? e) => const ListEquality()
      .hash([e?.heading, e?.description, e?.order, e?.gender]);

  @override
  bool isValidKey(Object? o) => o is AccessoryManualRecord;
}
