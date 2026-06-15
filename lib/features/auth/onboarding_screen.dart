import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/app_state.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/core/analytics/app_analytics.dart';
import '/core/domain/date_math.dart';
import '/core/providers/repositories_provider.dart';
import '/data/models/user_profile.dart';
import '/features/reflections/reflections_providers.dart';
import '/shared/widgets/loading_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Post-auth setup: gender, start date, optional why statement.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static const routeName = 'Onboarding';
  static const routePath = '/onboarding';

  static const _totalSteps = 3;

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
        final normalized = normalizeProgrammeStartDate(_startDate!);
        FFAppState().startDate = normalized;
        await ref.read(userRepositoryProvider).updateStartDate(normalized);
        ref.invalidate(programmeStartDateProvider);
        ref.invalidate(todayDayProvider);
        ref.invalidate(pastDaysProvider);
      }
      if (_whyController.text.trim().isNotEmpty) {
        await currentUserReference?.update(
          createUsersRecordData(whyStatement: _whyController.text.trim()),
        );
      }
      if (mounted) {
        await AppAnalytics.logOnboardingComplete();
        context.go('/today');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save your details. Please try again.'),
          ),
        );
      }
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
    final progress = (_step + 1) / OnboardingScreen._totalSteps;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Paedia'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Step ${_step + 1} of ${OnboardingScreen._totalSteps}',
                  style: theme.textTheme.labelMedium,
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: progress),
              ],
            ),
          ),
        ),
      ),
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
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton(
                    onPressed: _saving ? null : details.onStepContinue,
                    child: _saving && _step == 2
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: LoadingIndicator(size: 20),
                          )
                        : Text(_step == 2 ? 'Finish' : 'Continue'),
                  ),
                  if (details.onStepCancel != null)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                  if (_step == 2)
                    TextButton(
                      onPressed: _saving ? null : _finish,
                      child: const Text('Skip for now'),
                    ),
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
                    emptySelectionAllowed: true,
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

/// Destination after sign-in — matches router [postLoginRoute] logic.
String resolvePostLoginPath() {
  final doc = currentUserDocument;
  if (doc != null && (!doc.hasGender() || !doc.hasStartDate())) {
    return OnboardingScreen.routePath;
  }
  return '/today';
}
