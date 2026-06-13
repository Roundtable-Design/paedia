import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '/app_state.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/core/domain/date_math.dart';
import '/core/providers/repositories_provider.dart';
import '/core/services/programme_start_date.dart';
import '/data/models/user_profile.dart';
import '/features/reflections/reflections_providers.dart';
import '/popups/delete_account/delete_account_widget.dart';
import '/popups/select_gender/select_gender_widget.dart';
import '/shared/widgets/empty_state.dart';
import '/shared/widgets/loading_indicator.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

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
            message: e.toString(),
          ),
          data: (profile) {
            if (profile == null) {
              return const EmptyState(
                title: 'Not signed in',
                message: 'Sign in to view your profile.',
              );
            }
            return _ProfileBody(profile: profile);
          },
        ),
      ),
    );
  }
}

class _ProfileBody extends ConsumerStatefulWidget {
  const _ProfileBody({required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends ConsumerState<_ProfileBody> {
  late TextEditingController _whyController;
  late TextEditingController _closingController;
  final _dateFormat = DateFormat.yMMMd();

  @override
  void initState() {
    super.initState();
    _whyController = TextEditingController(text: widget.profile.whyStatement);
    _closingController =
        TextEditingController(text: widget.profile.closingStatement);
  }

  @override
  void didUpdateWidget(covariant _ProfileBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.whyStatement != widget.profile.whyStatement) {
      _whyController.text = widget.profile.whyStatement;
    }
    if (oldWidget.profile.closingStatement != widget.profile.closingStatement) {
      _closingController.text = widget.profile.closingStatement;
    }
  }

  @override
  void dispose() {
    _whyController.dispose();
    _closingController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.profile.startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked == null || !mounted) return;

    FFAppState().startDate = picked;
    await ref.read(userRepositoryProvider).updateStartDate(picked);
    const ProgrammeStartDateService().syncCacheFromFirestore();
  }

  Future<void> _saveStatement({
    required String field,
    required String value,
  }) async {
    if (field == 'why') {
      await currentUserReference?.update(
        createUsersRecordData(whyStatement: value),
      );
    } else {
      await currentUserReference?.update(
        createUsersRecordData(closingStatement: value),
      );
    }
  }

  Future<void> _showGenderSheet() async {
    await showModalBottomSheet<void>(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => Padding(
        padding: MediaQuery.viewInsetsOf(context),
        child: const SelectGenderWidget(),
      ),
    );
  }

  Future<void> _signOut() async {
    FFAppState().startDate = null;
    await authManager.signOut();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = widget.profile;
    final endDate = programmeEndDate(profile.startDate);
    final daysRemaining = profile.startDate == null
        ? null
        : programmeDayNumber(profile.startDate);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage:
              profile.photoUrl.isNotEmpty ? NetworkImage(profile.photoUrl) : null,
          child: profile.photoUrl.isEmpty
              ? Text(
                  profile.displayName.isNotEmpty
                      ? profile.displayName[0].toUpperCase()
                      : '?',
                  style: theme.textTheme.headlineMedium,
                )
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          profile.displayName.isNotEmpty ? profile.displayName : profile.email,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        if (profile.email.isNotEmpty)
          Text(
            profile.email,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        const SizedBox(height: 24),
        Text('Programme', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Start date'),
          subtitle: Text(
            profile.startDate != null
                ? _dateFormat.format(profile.startDate!)
                : 'Not set — tap to choose',
          ),
          trailing: const Icon(Icons.calendar_today_outlined),
          onTap: _pickStartDate,
        ),
        if (endDate != null)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('End date'),
            subtitle: Text(_dateFormat.format(endDate)),
          ),
        if (daysRemaining != null)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Progress'),
            subtitle: Text('Day $daysRemaining of 90'),
          ),
        const Divider(height: 32),
        Text('About you', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Gender'),
          subtitle: Text(
            profile.gender.isNotEmpty ? profile.gender : 'Tap to set',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: _showGenderSheet,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _whyController,
          decoration: const InputDecoration(
            labelText: 'Why statement',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onSubmitted: (v) => _saveStatement(field: 'why', value: v),
          onTapOutside: (_) =>
              _saveStatement(field: 'why', value: _whyController.text),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _closingController,
          decoration: const InputDecoration(
            labelText: 'Closing statement',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onSubmitted: (v) => _saveStatement(field: 'closing', value: v),
          onTapOutside: (_) => _saveStatement(
            field: 'closing',
            value: _closingController.text,
          ),
        ),
        const Divider(height: 32),
        Text('Account', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.logout),
          title: const Text('Sign out'),
          onTap: _signOut,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
          title: Text(
            'Delete account',
            style: TextStyle(color: theme.colorScheme.error),
          ),
          onTap: () async {
            await showDialog<void>(
              context: context,
              builder: (context) => const Dialog(
                child: DeleteAccountWidget(),
              ),
            );
          },
        ),
      ],
    );
  }
}
