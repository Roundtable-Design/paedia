import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class DaysRecord extends FirestoreRecord {
  DaysRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "Text" field.
  String? _text;
  String get text => _text ?? '';
  bool hasText() => _text != null;

  // "DayNumber" field.
  int? _dayNumber;
  int get dayNumber => _dayNumber ?? 0;
  bool hasDayNumber() => _dayNumber != null;

  // "Title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "Sybtitle" field.
  String? _sybtitle;
  String get sybtitle => _sybtitle ?? '';
  bool hasSybtitle() => _sybtitle != null;

  // "Preamble" field.
  String? _preamble;
  String get preamble => _preamble ?? '';
  bool hasPreamble() => _preamble != null;

  // "Scripture" field.
  String? _scripture;
  String get scripture => _scripture ?? '';
  bool hasScripture() => _scripture != null;

  // "CallToPrayer" field.
  String? _callToPrayer;
  String get callToPrayer => _callToPrayer ?? '';
  bool hasCallToPrayer() => _callToPrayer != null;

  // "EncouragementToRead" field.
  String? _encouragementToRead;
  String get encouragementToRead => _encouragementToRead ?? '';
  bool hasEncouragementToRead() => _encouragementToRead != null;

  // "ReflectionTitle" field.
  String? _reflectionTitle;
  String get reflectionTitle => _reflectionTitle ?? '';
  bool hasReflectionTitle() => _reflectionTitle != null;

  // "Reflection" field.
  String? _reflection;
  String get reflection => _reflection ?? '';
  bool hasReflection() => _reflection != null;

  // "QuestionsTitle" field.
  String? _questionsTitle;
  String get questionsTitle => _questionsTitle ?? '';
  bool hasQuestionsTitle() => _questionsTitle != null;

  // "Questions" field.
  String? _questions;
  String get questions => _questions ?? '';
  bool hasQuestions() => _questions != null;

  // "FinalWord" field.
  String? _finalWord;
  String get finalWord => _finalWord ?? '';
  bool hasFinalWord() => _finalWord != null;

  // "References" field.
  List<String>? _references;
  List<String> get references => _references ?? const [];
  bool hasReferences() => _references != null;

  // "Illustration" field.
  String? _illustration;
  String get illustration => _illustration ?? '';
  bool hasIllustration() => _illustration != null;

  void _initializeFields() {
    _text = snapshotData['Text'] as String?;
    _dayNumber = castToType<int>(snapshotData['DayNumber']);
    _title = snapshotData['Title'] as String?;
    _sybtitle = snapshotData['Sybtitle'] as String?;
    _preamble = snapshotData['Preamble'] as String?;
    _scripture = snapshotData['Scripture'] as String?;
    _callToPrayer = snapshotData['CallToPrayer'] as String?;
    _encouragementToRead = snapshotData['EncouragementToRead'] as String?;
    _reflectionTitle = snapshotData['ReflectionTitle'] as String?;
    _reflection = snapshotData['Reflection'] as String?;
    _questionsTitle = snapshotData['QuestionsTitle'] as String?;
    _questions = snapshotData['Questions'] as String?;
    _finalWord = snapshotData['FinalWord'] as String?;
    _references = getDataList(snapshotData['References']);
    _illustration = snapshotData['Illustration'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('days');

  static Stream<DaysRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => DaysRecord.fromSnapshot(s));

  static Future<DaysRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => DaysRecord.fromSnapshot(s));

  static DaysRecord fromSnapshot(DocumentSnapshot snapshot) => DaysRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static DaysRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      DaysRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'DaysRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is DaysRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createDaysRecordData({
  String? text,
  int? dayNumber,
  String? title,
  String? sybtitle,
  String? preamble,
  String? scripture,
  String? callToPrayer,
  String? encouragementToRead,
  String? reflectionTitle,
  String? reflection,
  String? questionsTitle,
  String? questions,
  String? finalWord,
  String? illustration,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'Text': text,
      'DayNumber': dayNumber,
      'Title': title,
      'Sybtitle': sybtitle,
      'Preamble': preamble,
      'Scripture': scripture,
      'CallToPrayer': callToPrayer,
      'EncouragementToRead': encouragementToRead,
      'ReflectionTitle': reflectionTitle,
      'Reflection': reflection,
      'QuestionsTitle': questionsTitle,
      'Questions': questions,
      'FinalWord': finalWord,
      'Illustration': illustration,
    }.withoutNulls,
  );

  return firestoreData;
}

class DaysRecordDocumentEquality implements Equality<DaysRecord> {
  const DaysRecordDocumentEquality();

  @override
  bool equals(DaysRecord? e1, DaysRecord? e2) {
    const listEquality = ListEquality();
    return e1?.text == e2?.text &&
        e1?.dayNumber == e2?.dayNumber &&
        e1?.title == e2?.title &&
        e1?.sybtitle == e2?.sybtitle &&
        e1?.preamble == e2?.preamble &&
        e1?.scripture == e2?.scripture &&
        e1?.callToPrayer == e2?.callToPrayer &&
        e1?.encouragementToRead == e2?.encouragementToRead &&
        e1?.reflectionTitle == e2?.reflectionTitle &&
        e1?.reflection == e2?.reflection &&
        e1?.questionsTitle == e2?.questionsTitle &&
        e1?.questions == e2?.questions &&
        e1?.finalWord == e2?.finalWord &&
        listEquality.equals(e1?.references, e2?.references) &&
        e1?.illustration == e2?.illustration;
  }

  @override
  int hash(DaysRecord? e) => const ListEquality().hash([
        e?.text,
        e?.dayNumber,
        e?.title,
        e?.sybtitle,
        e?.preamble,
        e?.scripture,
        e?.callToPrayer,
        e?.encouragementToRead,
        e?.reflectionTitle,
        e?.reflection,
        e?.questionsTitle,
        e?.questions,
        e?.finalWord,
        e?.references,
        e?.illustration
      ]);

  @override
  bool isValidKey(Object? o) => o is DaysRecord;
}
