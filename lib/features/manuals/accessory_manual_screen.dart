import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/providers/repositories_provider.dart';
import '/data/models/manual_section.dart';
import '/features/reflections/reflections_providers.dart';
import '/shared/utils/user_error_message.dart';
import '/shared/widgets/content_skeleton.dart';
import '/shared/widgets/empty_state.dart';
import '/shared/widgets/manual_sections_list.dart';

final accessoryManualProvider = StreamProvider<List<ManualSection>>((ref) {
  final gender = ref.watch(userProfileProvider).valueOrNull?.gender;
  return ref.watch(manualsRepositoryProvider).watchAccessoryManual(
        gender: gender,
      );
});

class AccessoryManualScreen extends ConsumerWidget {
  const AccessoryManualScreen({super.key});

  static const routeName = 'AccessoryManual';
  static const routePath = '/accessoryManual';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(accessoryManualProvider);
    final gender = ref.watch(userProfileProvider).valueOrNull?.gender ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessory Manual'),
      ),
      body: sectionsAsync.when(
        loading: () => ContentSkeleton.listTiles(count: 4),
        error: (e, _) => EmptyState(
          title: 'Unable to load manual',
          message: userFriendlyError(e),
          actionLabel: 'Try again',
          onAction: () => ref.invalidate(accessoryManualProvider),
        ),
        data: (sections) {
          if (gender.isEmpty) {
            return const EmptyState(
              title: 'Gender not set',
              message: 'Set your gender in Profile to view manual content.',
            );
          }
          return ManualSectionsList(
            sections: sections,
          );
        },
      ),
    );
  }
}
