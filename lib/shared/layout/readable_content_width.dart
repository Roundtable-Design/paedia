import 'package:flutter/material.dart';

/// Maximum content width for comfortable reading (~65–75 characters).
const double kReadableContentMaxWidth = 680;

/// Constrains child width and centres it on wide viewports.
class ReadableContentWidth extends StatelessWidget {
  const ReadableContentWidth({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kReadableContentMaxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
