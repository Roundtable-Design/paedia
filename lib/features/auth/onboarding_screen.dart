import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/app_state.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/core/providers/repositories_provider.dart';
import '/data/models/user_profile.dart';
import '/features/reflections/reflections_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Post-auth setup: gender, start date, optional why statement.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static const routeName = 'Onboarding';
  static const routePath = '/onboarding';

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  String? _gender;
  DateTime? _startDate;
  final _whyController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _whyController.dispose();
    super.dispose();
  }

  bool _profileComplete(UserProfile? profile) {
    return profile != null && profile.hasGender && profile.hasStartDate;
  }

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      if (_gender != null) {
        await ref.read(userRepositoryProvider).updateGender(_gender!);
      }
      if (_startDate != null) {
        FFAppState().startDate = _startDate;
        await ref.read(userRepositoryProvider).updateStartDate(_startDate!);
      }
      if (_whyController.text.trim().isNotEmpty) {
        await currentUserReference?.update(
          createUsersRecordData(whyStatement: _whyController.text.trim()),
        );
      }
      if (mounted) context.go('/today');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    if (_profileComplete(profile) && _step == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/today');
      });
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to Paedia')),
      body: SafeArea(
        child: Stepper(
          currentStep: _step,
          onStepContinue: () async {
            if (_step == 0 && _gender == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select your gender')),
              );
              return;
            }
            if (_step == 1 && _startDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please choose a start date')),
              );
              return;
            }
            if (_step < 2) {
              setState(() => _step += 1);
              return;
            }
            await _finish();
          },
          onStepCancel: _step > 0 ? () => setState(() => _step -= 1) : null,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  FilledButton(
                    onPressed: _saving ? null : details.onStepContinue,
                    child: Text(_step == 2 ? 'Finish' : 'Continue'),
                  ),
                  if (details.onStepCancel != null) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Gender'),
              isActive: _step >= 0,
              state: _step > 0 ? StepState.complete : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Content is tailored to your gender.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'male', label: Text('Male')),
                      ButtonSegment(value: 'female', label: Text('Female')),
                    ],
                    selected: _gender != null ? {_gender!} : {},
                    onSelectionChanged: (s) =>
                        setState(() => _gender = s.first),
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Start date'),
              isActive: _step >= 1,
              state: _step > 1 ? StepState.complete : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'When does your 90-day programme begin?',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setState(() => _startDate = picked);
                    },
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(
                      _startDate == null
                          ? 'Choose date'
                          : MaterialLocalizations.of(context)
                              .formatMediumDate(_startDate!),
                    ),
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Why statement'),
              isActive: _step >= 2,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Optional — why are you doing Paedia?',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _whyController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Your why…',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Returns true when authenticated user still needs onboarding fields.
bool userNeedsOnboarding(UserProfile? profile) {
  if (profile == null) return true;
  return !profile.hasGender || !profile.hasStartDate;
}
