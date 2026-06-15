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

    return SelectionArea(
      child: HtmlWidget(
        cleaned,
        textStyle: baseStyle,
        factoryBuilder: () => _PaediaWidgetFactory(),
        customStylesBuilder: (element) {
          switch (element.localName) {
            case 'h1':
              return {
                'font-family': 'Inter Tight',
                'font-weight': '700',
                'font-size': '22px',
                'line-height': '1.35',
                'margin-top': '20px',
                'margin-bottom': '10px',
              };
            case 'h2':
              return {
                'font-family': 'Inter Tight',
                'font-weight': '700',
                'font-size': '19px',
                'line-height': '1.35',
                'margin-top': '18px',
                'margin-bottom': '8px',
              };
            case 'h3':
              return {
                'font-family': 'Inter Tight',
                'font-weight': '600',
                'font-size': '17px',
                'line-height': '1.4',
                'margin-top': '14px',
                'margin-bottom': '6px',
              };
            case 'strong':
            case 'b':
              return {
                'font-weight': '600',
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
      ),
    );
  }
}

class _PaediaWidgetFactory extends WidgetFactory with UrlLauncherFactory {}
