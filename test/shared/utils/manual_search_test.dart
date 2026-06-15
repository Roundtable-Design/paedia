import 'package:flutter_test/flutter_test.dart';
import 'package:paedia/data/models/manual_section.dart';
import 'package:paedia/shared/utils/manual_search.dart';

ManualSection section({
  required String title,
  String html = '',
  String description = '',
}) {
  return ManualSection(
    id: title,
    type: ManualType.participant,
    title: title,
    html: html,
    position: 0,
    description: description,
  );
}

void main() {
  group('stripHtmlForSearch', () {
    test('removes tags and collapses whitespace', () {
      expect(
        stripHtmlForSearch('<p>Hello <strong>world</strong></p>'),
        'Hello world',
      );
    });
  });

  group('searchManualSections', () {
    final sections = [
      section(
        title: 'Preparing for Day 91',
        html: '<p>After the ninety days, continue in prayer daily.</p>',
      ),
      section(
        title: 'What is the goal of Paedia?',
        html: '<p>The goal is holiness and friendship with Christ.</p>',
      ),
      section(
        title: 'In what manner should Paedia be done?',
        html: '<p>Paedia should be done with consistency and humility.</p>',
      ),
      section(
        title: 'The dates',
        html: '<p>April, May, June, July, August, September 2026.</p>',
      ),
    ];

    test('returns all sections when query is empty', () {
      expect(searchManualSections(sections, ''), hasLength(4));
    });

    test('matches words in section body not just title', () {
      final results = searchManualSections(sections, 'holiness');
      expect(results, isNotEmpty);
      expect(results.first.section.title, 'What is the goal of Paedia?');
    });

    test('ranks title matches highly', () {
      final results = searchManualSections(sections, 'Day 91');
      expect(results.first.section.title, 'Preparing for Day 91');
    });

    test('supports multi-word AND search', () {
      final results = searchManualSections(sections, 'continue prayer');
      expect(results, isNotEmpty);
      expect(results.first.section.title, 'Preparing for Day 91');
    });

    test('does not match unrelated sections via loose fuzzy logic', () {
      final results = searchManualSections(sections, 'lifestyles');
      expect(results, isEmpty);
    });

    test('fuzzy matches minor typos in words', () {
      final results = searchManualSections(sections, 'humilty');
      expect(results, isNotEmpty);
      expect(
        results.any((r) => r.section.title.contains('manner')),
        isTrue,
      );
    });

    test('includes snippet around match', () {
      final results = searchManualSections(sections, 'friendship');
      expect(results.first.snippet, isNotNull);
      expect(results.first.snippet!, contains('friendship'));
    });
  });
}
