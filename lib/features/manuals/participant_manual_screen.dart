import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/providers/repositories_provider.dart';
import '/data/models/manual_section.dart';
import '/features/reflections/reflections_providers.dart';
import '/shared/utils/user_error_message.dart';
import '/shared/widgets/empty_state.dart';
import '/shared/widgets/expandable_panel_theme.dart';
import '/shared/widgets/html_content_view.dart';
import '/shared/widgets/loading_indicator.dart';

final participantManualProvider = StreamProvider<List<ManualSection>>((ref) {
  final gender = ref.watch(userProfileProvider).valueOrNull?.gender;
  return ref.watch(manualsRepositoryProvider).watchParticipantManual(
        gender: gender,
      );
});

class ParticipantManualScreen extends ConsumerWidget {
  const ParticipantManualScreen({super.key});

  static const routeName = 'ParticipantManual';
  static const routePath = '/participantManual';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(participantManualProvider);
    final gender = ref.watch(userProfileProvider).valueOrNull?.gender ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Participant Manual'),
      ),
      body: sectionsAsync.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (e, _) => EmptyState(
          title: 'Unable to load manual',
          message: userFriendlyError(e),
          actionLabel: 'Try again',
          onAction: () => ref.invalidate(participantManualProvider),
        ),
        data: (sections) {
          if (gender.isEmpty) {
            return const EmptyState(
              title: 'Gender not set',
              message: 'Set your gender in Profile to view manual content.',
            );
          }
          if (sections.isEmpty) {
            return const EmptyState(
              title: 'No content',
              message: 'Manual sections are not available yet.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Showing content for $gender.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              ...sections.map((s) => _ManualSectionTile(section: s)),
            ],
          );
        },
      ),
    );
  }
}

class _ManualSectionTile extends StatelessWidget {
  const _ManualSectionTile({required this.section});

  final ManualSection section;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpandableNotifier(
        child: ExpandablePanel(
          theme: paediaExpandableTheme(context),
          header: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              section.title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          collapsed: const SizedBox.shrink(),
          expanded: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: HtmlContentView(html: section.html),
          ),
        ),
      ),
    );
  }
}
