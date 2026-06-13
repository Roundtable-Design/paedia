import 'package:flutter/material.dart';

/// Branded loading indicator for content areas.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.size = 40,
    this.semanticLabel = 'Loading',
  });

  final double size;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Semantics(
      label: semanticLabel,
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: color,
          ),
        ),
      ),
    );
  }
}
