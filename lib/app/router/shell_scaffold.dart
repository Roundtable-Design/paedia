import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/core/analytics/app_analytics.dart';
import '/shared/widgets/offline_banner.dart';
import '/shared/widgets/paedia_bottom_nav.dart';

/// Bottom-nav shell for the four main tabs.
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const OfflineBanner(),
          PaediaBottomNav(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) {
              if (index != navigationShell.currentIndex) {
                AppAnalytics.logTabSelected(
                  tab: PaediaBottomNav.labels[index],
                );
              }
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
          ),
        ],
      ),
    );
  }
}
