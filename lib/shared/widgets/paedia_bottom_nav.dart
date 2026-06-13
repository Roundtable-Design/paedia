import 'package:flutter/material.dart';

/// Bottom navigation with accessible labels for the four main tabs.
class PaediaBottomNav extends StatelessWidget {
  const PaediaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const tabKeys = ['Group', 'Reflections', 'Manual', 'Profile'];

  static const labels = ['Community', 'Today', 'Manuals', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: 'Main navigation',
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: List.generate(labels.length, (index) {
          return BottomNavigationBarItem(
            icon: Semantics(
              excludeSemantics: true,
              child: Icon(_iconForIndex(index)),
            ),
            label: labels[index],
            tooltip: labels[index],
          );
        }),
      ),
    );
  }

  IconData _iconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.groups_rounded;
      case 1:
        return Icons.today_outlined;
      case 2:
        return Icons.class_;
      case 3:
        return Icons.manage_accounts_sharp;
      default:
        return Icons.circle;
    }
  }
}
