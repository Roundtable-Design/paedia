import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fwfh_url_launcher/fwfh_url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

/// Themed HTML renderer for CMS content.
class HtmlContentView extends StatelessWidget {
  const HtmlContentView({
    super.key,
    required this.html,
    this.textStyle,
  });

  final String html;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = textStyle ??
        GoogleFonts.inter(
          fontSize: 16,
          height: 1.6,
          color: theme.colorScheme.onSurface,
        );

    final cleaned = html.replaceAll(
      RegExp(r'<p><br\s*/?></p>', caseSensitive: false),
      '',
    );

    return HtmlWidget(
      cleaned,
      textStyle: baseStyle,
      factoryBuilder: () => _PaediaWidgetFactory(),
      customStylesBuilder: (element) {
        switch (element.localName) {
          case 'h1':
          case 'h2':
          case 'h3':
            return {
              'font-family': 'Inter Tight',
              'font-weight': '600',
              'margin-bottom': '8px',
            };
          case 'blockquote':
            return {
              'border-left': '3px solid #3D9970',
              'padding-left': '12px',
              'font-style': 'italic',
            };
          case 'a':
            return {
              'color': '#3D9970',
              'text-decoration': 'underline',
            };
          default:
            return null;
        }
      },
    );
  }
}

class _PaediaWidgetFactory extends WidgetFactory with UrlLauncherFactory {}
