import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '/features/reflections/reflections_providers.dart';
import '/index.dart';
import '/shared/widgets/empty_state.dart';

class ManualHubScreen extends ConsumerWidget {
  const ManualHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final theme = Theme.of(context);
    final genderLabel = profile?.gender.isNotEmpty == true
        ? profile!.gender
        : 'not set';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Manuals', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Showing content for $genderLabel.',
              style: theme.textTheme.bodyMedium,
            ),
            if (profile?.gender.isEmpty ?? true) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/profile'),
                child: const Text('Set gender in Profile'),
              ),
            ],
            const SizedBox(height: 24),
            _ManualCard(
              title: 'Participant Manual',
              description:
                  'Core programme readings and guidance for your 90-day journey.',
              icon: Icons.menu_book_outlined,
              onTap: () =>
                  context.pushNamed(ParticipantManualWidget.routeName),
            ),
            const SizedBox(height: 12),
            _ManualCard(
              title: 'Accessory Manual',
              description:
                  'Supplementary material and additional resources.',
              icon: Icons.library_books_outlined,
              onTap: () => context.pushNamed(AccessoryManualWidget.routeName),
            ),
            if (profile?.gender.isEmpty ?? true)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: EmptyState(
                  title: 'Gender required',
                  message:
                      'Manual content is filtered by gender. Set yours in Profile first.',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ManualCard extends StatelessWidget {
  const _ManualCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 40, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(description, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
