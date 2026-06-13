import '/backend/backend.dart';

/// Immutable domain model for a programme day.
class Day {
  const Day({
    required this.dayNumber,
    required this.title,
    required this.subtitle,
    required this.preamble,
    this.scripture = '',
    this.callToPrayer = '',
    this.encouragementToRead = '',
    this.reflectionTitle = '',
    this.reflection = '',
    this.questionsTitle = '',
    this.questions = '',
    this.finalWord = '',
    this.references = const [],
    this.illustration = '',
  });

  final int dayNumber;
  final String title;

  /// Maps Firestore [DaysRecord.sybtitle] until schema typo is fixed.
  final String subtitle;
  final String preamble;
  final String scripture;
  final String callToPrayer;
  final String encouragementToRead;
  final String reflectionTitle;
  final String reflection;
  final String questionsTitle;
  final String questions;
  final String finalWord;
  final List<String> references;
  final String illustration;

  factory Day.fromRecord(DaysRecord record) {
    return Day(
      dayNumber: record.dayNumber,
      title: record.title,
      subtitle: record.sybtitle,
      preamble: record.preamble,
      scripture: record.scripture,
      callToPrayer: record.callToPrayer,
      encouragementToRead: record.encouragementToRead,
      reflectionTitle: record.reflectionTitle,
      reflection: record.reflection,
      questionsTitle: record.questionsTitle,
      questions: record.questions,
      finalWord: record.finalWord,
      references: record.references,
      illustration: record.illustration,
    );
  }
}
