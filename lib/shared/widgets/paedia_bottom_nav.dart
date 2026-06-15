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
    final borderColor = theme.dividerColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Semantics(
        container: true,
        label: 'Main navigation',
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor:
              theme.colorScheme.onSurface.withValues(alpha: 0.55),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 24,
          enableFeedback: false,
          items: List.generate(labels.length, (index) {
            final selected = index == currentIndex;
            return BottomNavigationBarItem(
              icon: Semantics(
                selected: selected,
                label: labels[index],
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 2),
                  child: Icon(_iconForIndex(index), size: 24),
                ),
              ),
              label: labels[index],
              tooltip: labels[index],
            );
          }),
        ),
      ),
    );
  }

  IconData _iconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.groups_outlined;
      case 1:
        return Icons.today_outlined;
      case 2:
        return Icons.menu_book_outlined;
      case 3:
        return Icons.person_outline;
      default:
        return Icons.circle_outlined;
    }
  }
}
