import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '/data/models/day.dart';

/// Builds a printable PDF for a programme day (Phase 4).
class DayPdfBuilder {
  const DayPdfBuilder();

  Future<pw.Document> build(Day day) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Paedia — Day ${day.dayNumber}'),
          ),
          pw.Text(day.title, style: pw.TextStyle(fontSize: 18)),
          if (day.subtitle.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text(day.subtitle),
          ],
          if (day.preamble.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text('Preamble', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(_stripHtml(day.preamble)),
          ],
          if (day.scripture.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text('Scripture', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(_stripHtml(day.scripture)),
          ],
          if (day.reflection.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text(
              day.reflectionTitle.isNotEmpty ? day.reflectionTitle : 'Reflection',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(_stripHtml(day.reflection)),
          ],
        ],
      ),
    );
    return doc;
  }

  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
