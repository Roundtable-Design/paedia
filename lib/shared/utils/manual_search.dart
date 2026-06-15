import '/data/models/manual_section.dart';

/// A manual section ranked by search relevance.
class ManualSearchResult {
  const ManualSearchResult({
    required this.section,
    required this.score,
    this.snippet,
    this.matchedTerms = const [],
  });

  final ManualSection section;
  final double score;
  final String? snippet;
  final List<String> matchedTerms;
}

/// Strips HTML tags and entities so body text is searchable.
String stripHtmlForSearch(String html) {
  return html
      .replaceAll(RegExp(r'<[^>]*>', caseSensitive: false), ' ')
      .replaceAll(
          RegExp(r'&nbsp;|&amp;|&lt;|&gt;|&quot;|&#39;|&rsquo;|&lsquo;'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Lowercase query terms (min length 2, or numeric).
List<String> tokenizeSearchQuery(String query) {
  return query
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((term) => term.length >= 2 || RegExp(r'^\d+$').hasMatch(term))
      .toList();
}

/// Plain-text corpus for a manual section (title + metadata + body).
String manualSectionSearchText(ManualSection section) {
  final parts = <String>[
    section.title,
    section.heading,
    section.description,
    stripHtmlForSearch(section.html),
  ].where((part) => part.trim().isNotEmpty);

  return parts.join(' ').toLowerCase();
}

/// Whether [term] appears in [text] as a substring or close typo in a word.
bool termMatches(String text, String term) {
  if (term.isEmpty) return true;
  if (text.contains(term)) return true;

  if (term.length < 4) return false;

  final maxDistance = term.length >= 7 ? 2 : 1;
  for (final word in text.split(RegExp(r'\s+'))) {
    if (word.isEmpty) continue;
    if ((word.length - term.length).abs() > maxDistance + 1) continue;
    if (_editDistance(word, term) <= maxDistance) return true;
  }
  return false;
}

int _editDistance(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  final rows = a.length + 1;
  final cols = b.length + 1;
  final matrix = List.generate(rows, (_) => List<int>.filled(cols, 0));

  for (var i = 0; i < rows; i++) {
    matrix[i][0] = i;
  }
  for (var j = 0; j < cols; j++) {
    matrix[0][j] = j;
  }

  for (var i = 1; i < rows; i++) {
    for (var j = 1; j < cols; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      matrix[i][j] = [
        matrix[i - 1][j] + 1,
        matrix[i][j - 1] + 1,
        matrix[i - 1][j - 1] + cost,
      ].reduce((a, b) => a < b ? a : b);
    }
  }
  return matrix[a.length][b.length];
}

double _termScore(String text, String term, {double boost = 0}) {
  if (term.isEmpty) return 0;

  if (text.contains(term)) {
    final onWordBoundary =
        RegExp(r'\b' + RegExp.escape(term) + r'\b').hasMatch(text);
    return (onWordBoundary ? 14.0 : 9.0) + boost;
  }

  if (term.length >= 4) {
    final maxDistance = term.length >= 7 ? 2 : 1;
    for (final word in text.split(RegExp(r'\s+'))) {
      if (word.isEmpty) continue;
      if ((word.length - term.length).abs() > maxDistance + 1) continue;
      final distance = _editDistance(word, term);
      if (distance <= maxDistance) {
        return (6.0 - distance) + boost * 0.5;
      }
    }
  }

  return 0;
}

/// Finds the best substring range in [text] to show for [terms].
({String snippet, List<String> terms})? extractSearchSnippet(
  String text,
  List<String> terms, {
  int radius = 72,
}) {
  if (terms.isEmpty) return null;

  for (final term in terms) {
    final index = text.indexOf(term);
    if (index >= 0) {
      return (
        snippet:
            _snippetAround(text, index, index + term.length, radius: radius),
        terms: [term],
      );
    }
  }

  for (final term in terms) {
    if (term.length < 4) continue;
    final maxDistance = term.length >= 7 ? 2 : 1;
    for (final word in text.split(RegExp(r'\s+'))) {
      if (word.isEmpty) continue;
      if ((word.length - term.length).abs() > maxDistance + 1) continue;
      if (_editDistance(word, term) <= maxDistance) {
        final index = text.indexOf(word);
        if (index >= 0) {
          return (
            snippet: _snippetAround(text, index, index + word.length,
                radius: radius),
            terms: [word],
          );
        }
      }
    }
  }

  return null;
}

String _snippetAround(String text, int start, int end, {required int radius}) {
  final snippetStart = (start - radius).clamp(0, text.length);
  final snippetEnd = (end + radius).clamp(0, text.length);
  var snippet = text.substring(snippetStart, snippetEnd).trim();
  if (snippetStart > 0) snippet = '…$snippet';
  if (snippetEnd < text.length) snippet = '$snippet…';
  return snippet;
}

/// Search across titles and full section body text.
List<ManualSearchResult> searchManualSections(
  List<ManualSection> sections,
  String query,
) {
  final trimmed = query.trim();
  if (trimmed.isEmpty) {
    return sections
        .map((s) => ManualSearchResult(section: s, score: 0))
        .toList();
  }

  final terms = tokenizeSearchQuery(trimmed);
  if (terms.isEmpty) {
    return sections
        .map((s) => ManualSearchResult(section: s, score: 0))
        .toList();
  }

  final results = <ManualSearchResult>[];

  for (final section in sections) {
    final body = manualSectionSearchText(section);
    final title = section.title.toLowerCase();

    if (!terms
        .every((term) => termMatches(body, term) || termMatches(title, term))) {
      continue;
    }

    var score = 0.0;
    final matchedTerms = <String>[];

    for (final term in terms) {
      final titleScore = _termScore(title, term, boost: 10);
      final bodyScore = _termScore(body, term);
      final best = titleScore > bodyScore ? titleScore : bodyScore;
      score += best;
      matchedTerms.add(term);
    }

    final snippetResult = extractSearchSnippet(body, terms);

    results.add(
      ManualSearchResult(
        section: section,
        score: score,
        snippet: snippetResult?.snippet,
        matchedTerms: snippetResult?.terms ?? matchedTerms,
      ),
    );
  }

  results.sort((a, b) => b.score.compareTo(a.score));
  return results;
}
