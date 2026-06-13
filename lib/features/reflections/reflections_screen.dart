import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '/core/domain/date_math.dart';
import '/data/models/day.dart';
import '/features/reflections/reflections_providers.dart';
import '/shared/widgets/day_header.dart';
import '/shared/widgets/empty_state.dart';
import '/shared/widgets/html_content_view.dart';
import '/shared/widgets/loading_indicator.dart';

class ReflectionsScreen extends ConsumerWidget {
  const ReflectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final status = ref.watch(programmeStatusProvider);
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
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DayHeader(startDate: profile?.startDate),
                  const SizedBox(height: 16),
                  _StatusBody(status: status, profile: profile),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatusBody extends ConsumerWidget {
  const _StatusBody({
    required this.status,
    required this.profile,
  });

  final ProgrammeStatus status;
  final dynamic profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (status) {
      case ProgrammeStatus.needsGender:
        return EmptyState(
          title: 'Set your gender',
          message:
              'Reflections content is tailored to your gender. Add it in Profile to continue.',
          actionLabel: 'Go to Profile',
          onAction: () => context.go('/profile'),
        );
      case ProgrammeStatus.needsStartDate:
        return EmptyState(
          title: 'Set your start date',
          message:
              'Choose when your 90-day programme begins in Profile.',
          actionLabel: 'Go to Profile',
          onAction: () => context.go('/profile'),
        );
      case ProgrammeStatus.preStart:
        final label = programmeDayLabel(profile?.startDate);
        return EmptyState(
          title: 'Programme not started yet',
          message: label ?? 'Your programme has not started.',
        );
      case ProgrammeStatus.complete:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EmptyState(
              title: 'Programme complete',
              message: programmeDayLabel(profile?.startDate) ??
                  'Congratulations on completing Paedia.',
            ),
            const SizedBox(height: 24),
            _PastDaysSection(),
          ],
        );
      case ProgrammeStatus.active:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TodaySection(),
            const SizedBox(height: 24),
            _PastDaysSection(),
          ],
        );
      case ProgrammeStatus.unavailable:
        return const EmptyState(
          title: 'Content unavailable',
          message: 'We could not determine your programme day.',
        );
    }
  }
}

class _TodaySection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayAsync = ref.watch(todayDayProvider);
    final theme = Theme.of(context);

    return dayAsync.when(
      loading: () => const Center(child: LoadingIndicator()),
      error: (e, _) => EmptyState(
        title: 'Unable to load today',
        message: e.toString(),
      ),
      data: (day) {
        if (day == null) {
          return const EmptyState(
            title: 'No reflection for today',
            message: 'Check back later or contact your programme leader.',
          );
        }
        return _DayCard(day: day, theme: theme);
      },
    );
  }
}

class _PastDaysSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pastAsync = ref.watch(pastDaysProvider);
    final theme = Theme.of(context);

    return pastAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (days) {
        if (days.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Previous days', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ...days.map((day) => _DayAccordion(day: day)),
          ],
        );
      },
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.day, required this.theme});

  final Day day;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(day.title, style: theme.textTheme.titleMedium),
            if (day.subtitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(day.subtitle, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 16),
            _DaySections(day: day),
          ],
        ),
      ),
    );
  }
}

class _DayAccordion extends StatelessWidget {
  const _DayAccordion({required this.day});

  final Day day;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpandableNotifier(
        child: ExpandablePanel(
          header: ListTile(
            title: Text('Day ${day.dayNumber}: ${day.title}'),
            dense: true,
          ),
          collapsed: const SizedBox.shrink(),
          expanded: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _DaySections(day: day),
          ),
        ),
      ),
    );
  }
}

class _DaySections extends StatelessWidget {
  const _DaySections({required this.day});

  final Day day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sections = <({String title, String body, bool isHtml})>[
      if (day.preamble.isNotEmpty)
        (title: 'Preamble', body: day.preamble, isHtml: false),
      if (day.scripture.isNotEmpty)
        (title: 'Scripture', body: day.scripture, isHtml: true),
      if (day.callToPrayer.isNotEmpty)
        (title: 'Call to prayer', body: day.callToPrayer, isHtml: true),
      if (day.encouragementToRead.isNotEmpty)
        (
          title: 'Encouragement to read',
          body: day.encouragementToRead,
          isHtml: true,
        ),
      if (day.reflection.isNotEmpty)
        (
          title: day.reflectionTitle.isNotEmpty
              ? day.reflectionTitle
              : 'Reflection',
          body: day.reflection,
          isHtml: true,
        ),
      if (day.questions.isNotEmpty)
        (
          title: day.questionsTitle.isNotEmpty
              ? day.questionsTitle
              : 'Questions',
          body: day.questions,
          isHtml: true,
        ),
      if (day.finalWord.isNotEmpty)
        (title: 'Final word', body: day.finalWord, isHtml: true),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final section in sections) ...[
          Text(section.title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          if (section.isHtml)
            HtmlContentView(html: section.body)
          else
            Text(section.body, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
