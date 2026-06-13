import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/pages/users/users_widget.dart';
import '/backend/backend.dart';
import '/core/providers/repositories_provider.dart';
import '/shared/utils/user_error_message.dart';
import '/shared/widgets/empty_state.dart';
import '/shared/widgets/loading_indicator.dart';

final communityGroupProvider = StreamProvider((ref) {
  return ref.watch(groupsRepositoryProvider).watchCurrentUserGroup();
});

final communityMembersProvider =
    StreamProvider.autoDispose.family<List<UsersRecord>, List<String>>(
  (ref, memberIds) {
    return ref
        .watch(groupsRepositoryProvider)
        .watchGroupMembers(memberIds);
  },
);

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(communityGroupProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: groupAsync.when(
          loading: () => const Center(child: LoadingIndicator()),
          error: (e, _) => EmptyState(
            title: 'Unable to load group',
            message: userFriendlyError(e),
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(communityGroupProvider),
          ),
          data: (group) {
            if (group == null) {
              return const EmptyState(
                icon: Icons.groups_outlined,
                title: 'No group assigned',
                message:
                    'You are not currently in a Paedia group. Contact your programme leader if you believe this is an error.',
              );
            }
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    '${group.memberIds.length} members',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
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

class _MembersList extends ConsumerWidget {
  const _MembersList({required this.memberIds});

  final List<String> memberIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(communityMembersProvider(memberIds));

    return membersAsync.when(
      loading: () => const Center(child: LoadingIndicator()),
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
          itemCount: members.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final member = members[index];
            return ListTile(
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
