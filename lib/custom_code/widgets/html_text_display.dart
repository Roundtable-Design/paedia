// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter_html/flutter_html.dart';

class HtmlTextDisplay extends StatelessWidget {
  final String htmlContent;
  final double? width;
  final double? height;

  const HtmlTextDisplay({
    Key? key,
    required this.htmlContent,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cleanedHtml = htmlContent.replaceAll(
      RegExp(r'<p><br\s*/?></p>', caseSensitive: false),
      '',
    );
    return Html(
      data: cleanedHtml,
      style: {
        "p": Style(margin: Margins.only(bottom: 8)),
        "br": Style(display: Display.inline),
      },
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
