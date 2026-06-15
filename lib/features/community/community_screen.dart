import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/pages/users/users_widget.dart';
import '/backend/backend.dart';
import '/core/providers/repositories_provider.dart';
import '/data/models/group.dart';
import '/shared/utils/user_error_message.dart';
import '/shared/widgets/content_skeleton.dart';
import '/shared/widgets/empty_state.dart';

final communityGroupProvider = StreamProvider((ref) {
  return ref.watch(groupsRepositoryProvider).watchCurrentUserGroup();
});

final communityMembersProvider =
    StreamProvider.autoDispose.family<List<UsersRecord>, List<String>>(
  (ref, memberIds) {
    return ref.watch(groupsRepositoryProvider).watchGroupMembers(memberIds);
  },
);

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  Future<void> _refresh(WidgetRef ref, List<String>? memberIds) async {
    ref.invalidate(communityGroupProvider);
    if (memberIds != null) {
      ref.invalidate(communityMembersProvider(memberIds));
    }
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(communityGroupProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: groupAsync.when(
          loading: () => ContentSkeleton.listTiles(count: 6),
          error: (e, _) => Center(
            child: EmptyState(
              title: 'Unable to load group',
              message: userFriendlyError(e),
              actionLabel: 'Try again',
              onAction: () => ref.invalidate(communityGroupProvider),
            ),
          ),
          data: (group) {
            if (group == null) {
              return const Center(
                child: EmptyState(
                  icon: Icons.groups_outlined,
                  title: 'No group assigned',
                  message:
                      'You are not currently in a Paedia group. Contact your programme leader if you believe this is an error.',
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => _refresh(ref, group.memberIds),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(group.name,
                              style: theme.textTheme.headlineSmall),
                          const SizedBox(height: 8),
                          Text(
                            '${group.memberIds.length} members',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          _GroupKeyDatesCard(group: group),
                          const SizedBox(height: 16),
                          Text('Members', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _MembersList(memberIds: group.memberIds),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GroupKeyDatesCard extends ConsumerStatefulWidget {
  const _GroupKeyDatesCard({required this.group});

  final PaediaGroup group;

  @override
  ConsumerState<_GroupKeyDatesCard> createState() => _GroupKeyDatesCardState();
}

class _GroupKeyDatesCardState extends ConsumerState<_GroupKeyDatesCard> {
  static const _defaultLabels = [
    'Group meetup',
    'Exit statement night',
  ];

  late List<GroupKeyDate> _dates;
  bool _saving = false;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _dates = _mergeWithDefaults(widget.group.keyDates);
  }

  @override
  void didUpdateWidget(covariant _GroupKeyDatesCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.group.keyDates != widget.group.keyDates && !_saving) {
      _dates = _mergeWithDefaults(widget.group.keyDates);
    }
  }

  List<GroupKeyDate> _mergeWithDefaults(List<GroupKeyDate> existing) {
    final byLabel = {
      for (final date in existing) date.label.toLowerCase(): date,
    };
    return _defaultLabels
        .map(
          (label) => byLabel[label.toLowerCase()] ?? GroupKeyDate(label: label),
        )
        .toList(growable: true);
  }

  Future<void> _saveDates() async {
    setState(() => _saving = true);
    try {
      await ref.read(groupsRepositoryProvider).updateKeyDates(
            groupRef: widget.group.reference,
            keyDates: _dates,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group dates saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFriendlyError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate(int index) async {
    final current = _dates[index];
    final picked = await showDatePicker(
      context: context,
      initialDate: current.date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _dates[index] = GroupKeyDate(label: current.label, date: picked);
    });
    await _saveDates();
  }

  Future<void> _confirmDeleteGroup() async {
    final controller = TextEditingController();
    var canDelete = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Delete this group?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This permanently removes the group for everyone. '
                    'Type delete to confirm.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Type delete',
                      border: OutlineInputBorder(),
                    ),
                    autocorrect: false,
                    enableSuggestions: false,
                    onChanged: (value) {
                      setDialogState(() {
                        canDelete = value.trim().toLowerCase() == 'delete';
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                  ),
                  onPressed:
                      canDelete ? () => Navigator.of(context).pop(true) : null,
                  child: const Text('Delete group'),
                ),
              ],
            );
          },
        );
      },
    );
    controller.dispose();
    if (confirmed != true || !mounted) return;

    try {
      await ref
          .read(groupsRepositoryProvider)
          .deleteGroup(widget.group.reference);
      ref.invalidate(communityGroupProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFriendlyError(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Group details',
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              Text(
                'Key dates can be edited by anyone in the group.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < _dates.length; i++) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_dates[i].label),
                  subtitle: Text(
                    _dates[i].date != null
                        ? dateFormat.format(_dates[i].date!)
                        : 'Tap to set date',
                  ),
                  trailing: _dates[i].date != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: 'Clear date',
                          onPressed: _saving
                              ? null
                              : () async {
                                  setState(() {
                                    _dates[i] = GroupKeyDate(
                                      label: _dates[i].label,
                                    );
                                  });
                                  await _saveDates();
                                },
                        )
                      : const Icon(Icons.calendar_today_outlined),
                  onTap: _saving ? null : () => _pickDate(i),
                ),
              ],
              if (_saving)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(),
                ),
              const Divider(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                    Icon(Icons.delete_outline, color: theme.colorScheme.error),
                title: Text(
                  'Delete group',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                subtitle: const Text('Requires typing delete to confirm'),
                onTap: _confirmDeleteGroup,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MembersList extends ConsumerWidget {
  const _MembersList({required this.memberIds});

  final List<String> memberIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(communityMembersProvider(memberIds));

    return membersAsync.when(
      loading: () => ContentSkeleton.listTiles(count: 5),
      error: (e, _) => EmptyState(
        title: 'Unable to load members',
        message: userFriendlyError(e),
        actionLabel: 'Try again',
        onAction: () => ref.invalidate(communityMembersProvider(memberIds)),
      ),
      data: (members) {
        if (members.isEmpty) {
          return const EmptyState(
            title: 'No members found',
            message: 'This group has no visible members yet.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: members.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final member = members[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              minVerticalPadding: 12,
              leading: CircleAvatar(
                backgroundImage: member.photoUrl.isNotEmpty
                    ? NetworkImage(member.photoUrl)
                    : null,
                child: member.photoUrl.isEmpty
                    ? Text(
                        member.displayName.isNotEmpty
                            ? member.displayName[0].toUpperCase()
                            : '?',
                      )
                    : null,
              ),
              title: Text(
                member.displayName.isNotEmpty
                    ? member.displayName
                    : member.email,
              ),
              onTap: () {
                context.pushNamed(
                  UsersWidget.routeName,
                  queryParameters: {
                    'user': serializeParam(
                      member.reference,
                      ParamType.DocumentReference,
                    ),
                  }.withoutNulls,
                );
              },
            );
          },
        );
      },
    );
  }
}
