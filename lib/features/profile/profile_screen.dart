import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '/app_state.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/core/domain/date_math.dart';
import '/core/features/experimental_features.dart';
import '/core/providers/repositories_provider.dart';
import '/core/services/programme_start_date.dart';
import '/data/models/user_profile.dart';
import '/data/repositories/user_repository.dart';
import '/features/reflections/reflections_providers.dart';
import '/popups/delete_account/delete_account_widget.dart';
import '/popups/select_gender/select_gender_widget.dart';
import '/shared/utils/user_error_message.dart';
import '/shared/widgets/content_skeleton.dart';
import '/shared/widgets/empty_state.dart';

enum _SaveStatus { idle, saving, saved, error }

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
          loading: () => ContentSkeleton.listTiles(count: 4),
          error: (e, _) => EmptyState(
            title: 'Unable to load profile',
            message: userFriendlyError(e),
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(userProfileProvider),
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
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  final _dateFormat = DateFormat.yMMMd();
  Timer? _whySaveDebounce;
  Timer? _closingSaveDebounce;
  Timer? _nameSaveDebounce;
  Timer? _whySavedClearTimer;
  Timer? _closingSavedClearTimer;
  Timer? _nameSavedClearTimer;
  bool _suppressWhyListener = false;
  bool _suppressClosingListener = false;
  bool _suppressNameListener = false;
  _SaveStatus _whyStatus = _SaveStatus.idle;
  _SaveStatus _closingStatus = _SaveStatus.idle;
  _SaveStatus _nameStatus = _SaveStatus.idle;
  bool _photoBusy = false;

  @override
  void initState() {
    super.initState();
    _whyController = TextEditingController(text: widget.profile.whyStatement);
    _closingController =
        TextEditingController(text: widget.profile.closingStatement);
    final (first, last) = splitDisplayName(widget.profile.displayName);
    _firstNameController = TextEditingController(text: first);
    _lastNameController = TextEditingController(text: last);
    _whyController.addListener(_onWhyChanged);
    _closingController.addListener(_onClosingChanged);
    _firstNameController.addListener(_onNameChanged);
    _lastNameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    if (_suppressNameListener) return;
    _scheduleSave(field: 'name');
  }

  void _onWhyChanged() {
    if (_suppressWhyListener) return;
    _scheduleSave(field: 'why');
  }

  void _onClosingChanged() {
    if (_suppressClosingListener) return;
    _scheduleSave(field: 'closing');
  }

  void _setControllerText(TextEditingController controller, String value) {
    if (controller.text == value) return;
    void suppress() {
      if (identical(controller, _whyController)) {
        _suppressWhyListener = true;
      } else if (identical(controller, _closingController)) {
        _suppressClosingListener = true;
      } else {
        _suppressNameListener = true;
      }
    }

    void clearSuppress() {
      if (identical(controller, _whyController)) {
        _suppressWhyListener = false;
      } else if (identical(controller, _closingController)) {
        _suppressClosingListener = false;
      } else {
        _suppressNameListener = false;
      }
    }

    suppress();
    controller.text = value;
    clearSuppress();
  }

  @override
  void didUpdateWidget(covariant _ProfileBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.whyStatement != widget.profile.whyStatement &&
        _whyController.text != widget.profile.whyStatement) {
      _setControllerText(_whyController, widget.profile.whyStatement);
    }
    if (oldWidget.profile.closingStatement != widget.profile.closingStatement &&
        _closingController.text != widget.profile.closingStatement) {
      _setControllerText(_closingController, widget.profile.closingStatement);
    }
    final (first, last) = splitDisplayName(widget.profile.displayName);
    if (_firstNameController.text != first) {
      _setControllerText(_firstNameController, first);
    }
    if (_lastNameController.text != last) {
      _setControllerText(_lastNameController, last);
    }
  }

  @override
  void dispose() {
    _whySaveDebounce?.cancel();
    _closingSaveDebounce?.cancel();
    _nameSaveDebounce?.cancel();
    _whySavedClearTimer?.cancel();
    _closingSavedClearTimer?.cancel();
    _nameSavedClearTimer?.cancel();
    _whyController.dispose();
    _closingController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _scheduleSave({required String field}) {
    final debounce = switch (field) {
      'why' => _whySaveDebounce,
      'closing' => _closingSaveDebounce,
      _ => _nameSaveDebounce,
    };
    debounce?.cancel();
    setState(() {
      switch (field) {
        case 'why':
          _whyStatus = _SaveStatus.idle;
          _whySavedClearTimer?.cancel();
        case 'closing':
          _closingStatus = _SaveStatus.idle;
          _closingSavedClearTimer?.cancel();
        case 'name':
          _nameStatus = _SaveStatus.idle;
          _nameSavedClearTimer?.cancel();
      }
    });
    final timer = Timer(const Duration(milliseconds: 800), () {
      _saveField(field: field);
    });
    switch (field) {
      case 'why':
        _whySaveDebounce = timer;
      case 'closing':
        _closingSaveDebounce = timer;
      case 'name':
        _nameSaveDebounce = timer;
    }
  }

  void _markSaved(String field) {
    setState(() {
      switch (field) {
        case 'why':
          _whyStatus = _SaveStatus.saved;
          _whySavedClearTimer?.cancel();
          _whySavedClearTimer = Timer(const Duration(seconds: 2), () {
            if (mounted && _whyStatus == _SaveStatus.saved) {
              setState(() => _whyStatus = _SaveStatus.idle);
            }
          });
        case 'closing':
          _closingStatus = _SaveStatus.saved;
          _closingSavedClearTimer?.cancel();
          _closingSavedClearTimer = Timer(const Duration(seconds: 2), () {
            if (mounted && _closingStatus == _SaveStatus.saved) {
              setState(() => _closingStatus = _SaveStatus.idle);
            }
          });
        case 'name':
          _nameStatus = _SaveStatus.saved;
          _nameSavedClearTimer?.cancel();
          _nameSavedClearTimer = Timer(const Duration(seconds: 2), () {
            if (mounted && _nameStatus == _SaveStatus.saved) {
              setState(() => _nameStatus = _SaveStatus.idle);
            }
          });
      }
    });
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.profile.startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked == null || !mounted) return;

    final normalized = normalizeProgrammeStartDate(picked);
    FFAppState().startDate = normalized;
    await ref.read(userRepositoryProvider).updateStartDate(normalized);
    const ProgrammeStartDateService().syncCacheFromFirestore();
    ref.invalidate(programmeStartDateProvider);
    ref.invalidate(todayDayProvider);
    ref.invalidate(pastDaysProvider);
  }

  Future<void> _saveField({required String field}) async {
    setState(() {
      switch (field) {
        case 'why':
          _whyStatus = _SaveStatus.saving;
        case 'closing':
          _closingStatus = _SaveStatus.saving;
        case 'name':
          _nameStatus = _SaveStatus.saving;
      }
    });

    try {
      switch (field) {
        case 'why':
          await currentUserReference?.update(
            createUsersRecordData(whyStatement: _whyController.text),
          );
        case 'closing':
          await currentUserReference?.update(
            createUsersRecordData(closingStatement: _closingController.text),
          );
        case 'name':
          await ref.read(userRepositoryProvider).updateDisplayName(
                joinDisplayName(
                  _firstNameController.text,
                  _lastNameController.text,
                ),
              );
      }
      if (mounted) _markSaved(field);
    } catch (_) {
      if (mounted) {
        setState(() {
          switch (field) {
            case 'why':
              _whyStatus = _SaveStatus.error;
            case 'closing':
              _closingStatus = _SaveStatus.error;
            case 'name':
              _nameStatus = _SaveStatus.error;
          }
        });
      }
    }
  }

  Widget _saveStatusLabel(_SaveStatus status) {
    if (status == _SaveStatus.idle) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final (text, color) = switch (status) {
      _SaveStatus.saving => (
          'Saving…',
          theme.colorScheme.onSurface.withValues(alpha: 0.6)
        ),
      _SaveStatus.saved => ('Saved', theme.colorScheme.primary),
      _SaveStatus.error => ('Could not save', theme.colorScheme.error),
      _ => ('', theme.colorScheme.onSurface),
    };
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child:
          Text(text, style: theme.textTheme.labelSmall?.copyWith(color: color)),
    );
  }

  Future<void> _showPhotoOptions() async {
    final repo = ref.read(userRepositoryProvider);
    final authPhoto = FirebaseAuth.instance.currentUser?.photoURL;
    final canUseSocialPhoto =
        (repo.hasGoogleProvider || repo.hasAppleProvider) &&
            authPhoto != null &&
            authPhoto.isNotEmpty;

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Upload photo'),
              onTap: () {
                Navigator.pop(context);
                _uploadProfilePhoto();
              },
            ),
            if (canUseSocialPhoto)
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: const Text('Use social account photo'),
                onTap: () {
                  Navigator.pop(context);
                  _useSocialPhoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadProfilePhoto() async {
    if (_photoBusy) return;
    setState(() => _photoBusy = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      final bytes = await picked.readAsBytes();
      final url = await ref.read(userRepositoryProvider).uploadProfilePhoto(
            bytes,
            fileName: picked.name,
          );
      if (url == null) throw Exception('Upload failed');
      await ref.read(userRepositoryProvider).updatePhotoUrl(url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFriendlyError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _photoBusy = false);
    }
  }

  Future<void> _useSocialPhoto() async {
    if (_photoBusy) return;
    setState(() => _photoBusy = true);
    try {
      final synced =
          await ref.read(userRepositoryProvider).syncPhotoFromAuthProvider();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              synced
                  ? 'Profile photo updated from your sign-in provider'
                  : 'No photo available from your sign-in provider',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFriendlyError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _photoBusy = false);
    }
  }

  Future<void> _showChangeEmailDialog() async {
    final controller = TextEditingController(text: widget.profile.email);
    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change email'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Email address',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (updated != true || !mounted) return;
    await authManager.updateEmail(
      email: controller.text.trim(),
      context: context,
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final controller = TextEditingController();
    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change password'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (updated != true || !mounted) return;
    await authManager.updatePassword(
      newPassword: controller.text,
      context: context,
    );
  }

  Future<void> _showLinkEmailDialog() async {
    final emailController = TextEditingController(text: widget.profile.email);
    final passwordController = TextEditingController();
    final linked = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add email sign-in'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Link an email and password so you can sign in without Google or Apple.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Link'),
          ),
        ],
      ),
    );
    if (linked != true || !mounted) return;
    try {
      await ref.read(userRepositoryProvider).linkEmailPassword(
            email: emailController.text,
            password: passwordController.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email sign-in linked')),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFriendlyError(e))),
        );
      }
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

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to access Paedia.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await _signOut();
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
    final userRepo = ref.read(userRepositoryProvider);
    final providers = userRepo.linkedProviderIds();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: profile.photoUrl.isNotEmpty
                    ? NetworkImage(profile.photoUrl)
                    : null,
                child: profile.photoUrl.isEmpty
                    ? Text(
                        profile.displayName.isNotEmpty
                            ? profile.displayName[0].toUpperCase()
                            : '?',
                        style: theme.textTheme.headlineMedium,
                      )
                    : null,
              ),
              if (_photoBusy)
                Positioned.fill(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.black26,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Material(
                  color: theme.colorScheme.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _photoBusy ? null : _showPhotoOptions,
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.camera_alt_outlined,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ),
          ],
        ),
        _saveStatusLabel(_nameStatus),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Email'),
          subtitle: Text(
            profile.email.isNotEmpty ? profile.email : 'Not set',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: _showChangeEmailDialog,
        ),
        const Divider(height: 32),
        Text('Sign-in & security', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (providers.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: providers
                  .map(
                    (id) => Chip(
                      label: Text(providerLabel(id)),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ),
        if (userRepo.hasPasswordProvider)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showChangePasswordDialog,
          ),
        if (!userRepo.hasPasswordProvider)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.mail_outline),
            title: const Text('Add email sign-in'),
            subtitle: const Text('Link email and password to your account'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showLinkEmailDialog,
          ),
        const Divider(height: 32),
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
        ),
        _saveStatusLabel(_whyStatus),
        const SizedBox(height: 12),
        TextField(
          controller: _closingController,
          decoration: const InputDecoration(
            labelText: 'Closing statement',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        _saveStatusLabel(_closingStatus),
        const Divider(height: 32),
        Text('Experimental', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Optional features that may change. Off by default.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        const _ExperimentalFeaturesSection(),
        const Divider(height: 32),
        Text('Account', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.logout),
          title: const Text('Sign out'),
          onTap: _confirmSignOut,
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
              builder: (context) => Dialog(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: const DeleteAccountWidget(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ExperimentalFeaturesSection extends ConsumerWidget {
  const _ExperimentalFeaturesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(experimentalFeaturesProvider);
    final notifier = ref.read(experimentalFeaturesProvider.notifier);

    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Enable experimental features'),
          subtitle:
              const Text('Required before turning on individual experiments.'),
          value: settings.enabled,
          onChanged: notifier.setEnabled,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Day illustrations'),
          subtitle: const Text(
              'Show an image at the top of each daily reflection. CMS uploads appear when available.'),
          value: settings.dayIllustrations,
          onChanged: settings.enabled ? notifier.setDayIllustrations : null,
        ),
      ],
    );
  }
}
