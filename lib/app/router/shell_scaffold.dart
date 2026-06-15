import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '/core/analytics/app_analytics.dart';
import '/shared/layout/readable_content_width.dart';
import '/shared/widgets/offline_banner.dart';
import '/shared/widgets/paedia_bottom_nav.dart';

/// Bottom-nav shell for the four main tabs.
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onTabSelected(int index) {
    if (index != navigationShell.currentIndex) {
      HapticFeedback.selectionClick();
      AppAnalytics.logTabSelected(tab: PaediaBottomNav.labels[index]);
      SemanticsService.announce(
        '${PaediaBottomNav.labels[index]} tab selected',
        TextDirection.ltr,
      );
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReadableContentWidth(child: navigationShell),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const OfflineBanner(),
          PaediaBottomNav(
            currentIndex: navigationShell.currentIndex,
            onTap: _onTabSelected,
          ),
        ],
      ),
    );
  }
}
