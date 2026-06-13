import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

/// Shared expand/collapse affordance for [ExpandablePanel] headers.
ExpandableThemeData paediaExpandableTheme(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;

  return ExpandableThemeData(
    tapHeaderToExpand: true,
    tapBodyToCollapse: true,
    hasIcon: true,
    iconColor: colorScheme.onSurface.withValues(alpha: 0.6),
    expandIcon: Icons.expand_more,
    collapseIcon: Icons.expand_less,
    headerAlignment: ExpandablePanelHeaderAlignment.center,
  );
}
