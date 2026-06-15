import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '/data/models/day.dart';
import '/shared/utils/html_text.dart';

/// Builds a printable PDF for a programme day (Phase 4).
class DayPdfBuilder {
  const DayPdfBuilder();

  Future<pw.Document> build(Day day) async {
    final bodyFont = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interSemiBold();

    final bodyStyle = pw.TextStyle(
      font: bodyFont,
      fontSize: 11,
      lineSpacing: 4,
    );
    final titleStyle = pw.TextStyle(
      font: boldFont,
      fontSize: 18,
      lineSpacing: 4,
    );
    final sectionStyle = pw.TextStyle(
      font: boldFont,
      fontSize: 12,
      lineSpacing: 4,
    );
    final metaStyle = pw.TextStyle(
      font: bodyFont,
      fontSize: 10,
      color: PdfColors.grey700,
    );

    pw.Widget body(String html) =>
        pw.Text(pdfPlainText(html), style: bodyStyle);

    pw.Widget section(String title, String html) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 16),
            pw.Text(title, style: sectionStyle),
            pw.SizedBox(height: 6),
            body(html),
          ],
        );

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: bodyFont,
        bold: boldFont,
      ),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (context) => [
          pw.Text('Paedia - Day ${day.dayNumber}', style: metaStyle),
          pw.SizedBox(height: 4),
          pw.Text(day.title, style: titleStyle),
          if (day.subtitle.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            body(day.subtitle),
          ],
          if (day.preamble.isNotEmpty) section('Preamble', day.preamble),
          if (day.scripture.isNotEmpty) section('Scripture', day.scripture),
          if (day.callToPrayer.isNotEmpty)
            section('Call to prayer', day.callToPrayer),
          if (day.encouragementToRead.isNotEmpty)
            section('Encouragement to read', day.encouragementToRead),
          if (day.reflection.isNotEmpty)
            section(
              day.reflectionTitle.isNotEmpty
                  ? day.reflectionTitle
                  : 'Reflection',
              day.reflection,
            ),
          if (day.questions.isNotEmpty)
            section(
              day.questionsTitle.isNotEmpty ? day.questionsTitle : 'Questions',
              day.questions,
            ),
          if (day.finalWord.isNotEmpty) section('Final word', day.finalWord),
        ],
      ),
    );
    return doc;
  }
}
