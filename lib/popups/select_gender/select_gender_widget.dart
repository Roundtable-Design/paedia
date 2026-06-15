import 'package:flutter/material.dart';

import '/core/providers/repositories_provider.dart';
import '/features/reflections/reflections_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectGenderWidget extends ConsumerStatefulWidget {
  const SelectGenderWidget({super.key});

  @override
  ConsumerState<SelectGenderWidget> createState() => _SelectGenderWidgetState();
}

class _SelectGenderWidgetState extends ConsumerState<SelectGenderWidget> {
  bool _saving = false;

  String? _normalizeGender(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    switch (raw.toLowerCase()) {
      case 'male':
      case 'm':
        return 'male';
      case 'female':
      case 'f':
        return 'female';
      default:
        return null;
    }
  }

  Future<void> _select(String gender) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(userRepositoryProvider).updateGender(gender);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save gender. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentGender = ref.watch(userProfileProvider).valueOrNull?.gender;
    final normalized = _normalizeGender(currentGender);
    final selected = normalized != null ? {normalized} : const <String>{};

    return Material(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Select your gender', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Content is tailored to your gender.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              emptySelectionAllowed: true,
              segments: const [
                ButtonSegment(value: 'male', label: Text('Male')),
                ButtonSegment(value: 'female', label: Text('Female')),
              ],
              selected: selected,
              onSelectionChanged: _saving ? null : (s) => _select(s.first),
            ),
            if (_saving) ...[
              const SizedBox(height: 16),
              const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
