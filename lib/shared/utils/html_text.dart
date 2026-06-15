/// Decodes common HTML entities and numeric character references.
String decodeHtmlEntities(String text) {
  var result = text
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&#160;', ' ')
      .replaceAll('&rsquo;', "'")
      .replaceAll('&lsquo;', "'")
      .replaceAll('&#8217;', "'")
      .replaceAll('&#8216;', "'")
      .replaceAll('&rdquo;', '"')
      .replaceAll('&ldquo;', '"')
      .replaceAll('&#8220;', '"')
      .replaceAll('&#8221;', '"')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&ndash;', '-')
      .replaceAll('&mdash;', '-')
      .replaceAll('&hellip;', '...')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>');

  result = result.replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (match) {
    final code = int.tryParse(match.group(1)!, radix: 16);
    if (code == null) return match.group(0)!;
    return String.fromCharCode(code);
  });

  result = result.replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
    final code = int.tryParse(match.group(1)!);
    if (code == null) return match.group(0)!;
    return String.fromCharCode(code);
  });

  return result;
}

/// Normalises punctuation to ASCII-safe characters for PDF output.
String normalizePdfText(String text) {
  return text
      .replaceAll('\u2019', "'")
      .replaceAll('\u2018', "'")
      .replaceAll('\u201C', '"')
      .replaceAll('\u201D', '"')
      .replaceAll('\u2014', '-')
      .replaceAll('\u2013', '-')
      .replaceAll('\u00A0', ' ')
      .replaceAll('\u2026', '...')
      .replaceAll('\u2011', '-')
      .replaceAll('\u2010', '-');
}

/// Strips HTML tags and normalises whitespace for PDF/search output.
String htmlToPlainText(String html) {
  final withoutTags =
      html.replaceAll(RegExp(r'<[^>]*>', caseSensitive: false), ' ');
  return normalizePdfText(
    decodeHtmlEntities(withoutTags).replaceAll(RegExp(r'\s+'), ' ').trim(),
  );
}

/// Plain text for PDF export with full entity and punctuation normalisation.
String pdfPlainText(String html) => htmlToPlainText(html);
