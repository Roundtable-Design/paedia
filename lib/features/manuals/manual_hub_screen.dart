import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '/features/reflections/reflections_providers.dart';
import '/features/manuals/accessory_manual_screen.dart';
import '/features/manuals/participant_manual_screen.dart';
import '/shared/utils/user_error_message.dart';
import '/shared/widgets/empty_state.dart';
import '/shared/widgets/loading_indicator.dart';

class ManualHubScreen extends ConsumerWidget {
  const ManualHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: LoadingIndicator()),
          error: (e, _) => EmptyState(
            title: 'Unable to load profile',
            message: userFriendlyError(e),
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(userProfileProvider),
          ),
          data: (profile) {
            final hasGender = profile?.gender.isNotEmpty == true;
            final genderLabel =
                hasGender ? profile!.gender : 'not set';

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Manuals', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  hasGender
                      ? 'Showing content for $genderLabel.'
                      : 'Set your gender in Profile to view manual content.',
                  style: theme.textTheme.bodyMedium,
                ),
                if (!hasGender) ...[
                  const SizedBox(height: 8),
                  FilledButton.tonal(
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
                  enabled: hasGender,
                  onTap: hasGender
                      ? () => context.pushNamed(
                            ParticipantManualScreen.routeName,
                          )
                      : null,
                ),
                const SizedBox(height: 12),
                _ManualCard(
                  title: 'Accessory Manual',
                  description:
                      'Supplementary material and additional resources.',
                  icon: Icons.library_books_outlined,
                  enabled: hasGender,
                  onTap: hasGender
                      ? () => context.pushNamed(
                            AccessoryManualScreen.routeName,
                          )
                      : null,
                ),
              ],
            );
          },
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
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opacity = enabled ? 1.0 : 0.5;

    return Opacity(
      opacity: opacity,
      child: Card(
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
                if (enabled) const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
