import '/backend/backend.dart';

enum ManualType { participant, accessory }

/// A single manual section from Firestore.
class ManualSection {
  const ManualSection({
    required this.id,
    required this.type,
    required this.title,
    required this.html,
    required this.position,
    this.gender = '',
    this.heading = '',
    this.description = '',
    this.order = 0,
  });

  final String id;
  final ManualType type;
  final String title;
  final String html;
  final int position;
  final String gender;
  final String heading;
  final String description;
  final int order;

  factory ManualSection.fromParticipant(ParticipantManualRecord record) {
    return ManualSection(
      id: record.reference.id,
      type: ManualType.participant,
      title: record.title,
      html: record.text,
      position: record.position,
      gender: record.gender,
    );
  }

  factory ManualSection.fromAccessory(AccessoryManualRecord record) {
    return ManualSection(
      id: record.reference.id,
      type: ManualType.accessory,
      title: record.heading,
      html: record.description,
      position: record.order,
      gender: record.gender,
      heading: record.heading,
      description: record.description,
      order: record.order,
    );
  }
}
