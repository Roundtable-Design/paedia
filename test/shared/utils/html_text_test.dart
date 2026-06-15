import 'package:flutter_test/flutter_test.dart';
import 'package:paedia/shared/utils/html_text.dart';

void main() {
  test('decodeHtmlEntities converts common entities', () {
    expect(decodeHtmlEntities('God&rsquo;s'), "God's");
    expect(decodeHtmlEntities('blessing.&nbsp;'), 'blessing. ');
    expect(decodeHtmlEntities('&#8217;'), "'");
  });

  test('htmlToPlainText strips tags and decodes entities', () {
    expect(
      htmlToPlainText('<p>God&rsquo;s <strong>word</strong></p>'),
      "God's word",
    );
  });

  test('normalizePdfText converts unicode punctuation', () {
    expect(normalizePdfText('It\u2019s \u201Cgood\u201D'), 'It\'s "good"');
    expect(normalizePdfText('Paedia \u2014 Day 5'), 'Paedia - Day 5');
  });
}
