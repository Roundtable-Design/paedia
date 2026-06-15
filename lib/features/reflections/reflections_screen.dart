import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import '/core/pdf/day_pdf_builder.dart';

import '/core/features/experimental_features.dart';
import '/core/analytics/app_analytics.dart';
import '/core/domain/date_math.dart';
import '/core/providers/connectivity_provider.dart';
import '/data/models/day.dart';
import '/features/reflections/reflections_providers.dart';
import '/shared/utils/user_error_message.dart';
import '/shared/widgets/cached_content_banner.dart';
import '/shared/widgets/content_skeleton.dart';
import '/shared/widgets/day_header.dart';
import '/shared/widgets/empty_state.dart';
import '/shared/widgets/expandable_panel_theme.dart';
import '/shared/widgets/day_illustration.dart';
import '/shared/widgets/html_content_view.dart';
import '/shared/widgets/loading_indicator.dart';

class ReflectionsScreen extends ConsumerWidget {
  const ReflectionsScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(userProfileProvider);
    ref.invalidate(programmeStartDateProvider);
    ref.invalidate(todayDayProvider);
    ref.invalidate(pastDaysProvider);
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: profileAsync.when(
          loading: () => ContentSkeleton.header(),
          error: (e, _) => EmptyState(
            title: 'Unable to load profile',
            message: userFriendlyError(e),
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(userProfileProvider),
          ),
          data: (profile) {
            final startDate = ref.watch(programmeStartDateProvider);
            final status = programmeStatusFromProfile(
              profile,
              startDate: startDate,
            );

            return RefreshIndicator(
              onRefresh: () => _refresh(ref),
              child: SelectionArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DayHeader(startDate: startDate),
                      const SizedBox(height: 16),
                      _StatusBody(status: status, startDate: startDate),
                    ],
                  ),
                ),
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
    required this.startDate,
  });

  final ProgrammeStatus status;
  final DateTime? startDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isProgrammePreStart(startDate)) {
      return _PreStartCard(startDate: startDate);
    }

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
          message: 'Choose when your 90-day programme begins in Profile.',
          actionLabel: 'Go to Profile',
          onAction: () => context.go('/profile'),
        );
      case ProgrammeStatus.preStart:
        return _PreStartCard(startDate: startDate);
      case ProgrammeStatus.complete:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EmptyState(
              title: 'Programme complete',
              message: programmeDayLabel(startDate) ??
                  'Congratulations on completing Paedia.',
            ),
            const SizedBox(height: 24),
            const _PastDaysSection(),
          ],
        );
      case ProgrammeStatus.active:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isProgrammePreStart(startDate)) const _TodaySection(),
            if (!isProgrammePreStart(startDate)) const SizedBox(height: 24),
            const _PastDaysSection(),
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

class _PreStartCard extends StatelessWidget {
  const _PreStartCard({required this.startDate});

  final DateTime? startDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysUntil = startDate == null ? null : dayOffsetFromStart(startDate);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.hourglass_top_outlined,
                size: 40, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              daysUntil != null && daysUntil < 0 ? '${-daysUntil}' : '—',
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              daysUntil != null && daysUntil < 0
                  ? 'day${-daysUntil == 1 ? '' : 's'} until Paedia begins'
                  : 'Programme not started yet',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _TodaySection extends ConsumerWidget {
  const _TodaySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startDate = ref.watch(programmeStartDateProvider);
    if (isProgrammePreStart(startDate)) {
      return const SizedBox.shrink();
    }

    final dayAsync = ref.watch(todayDayProvider);
    final isOffline = ref.watch(isOfflineProvider);
    final theme = Theme.of(context);

    return dayAsync.when(
      loading: () => ContentSkeleton.card(height: 200),
      error: (e, _) => EmptyState(
        title: 'Unable to load today',
        message: userFriendlyError(e),
        actionLabel: 'Try again',
        onAction: () => ref.invalidate(todayDayProvider),
      ),
      data: (day) {
        if (day == null) {
          return const EmptyState(
            title: 'No reflection for today',
            message: 'Check back later or contact your programme leader.',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isOffline) const CachedContentBanner(),
            _DayCard(day: day, theme: theme),
          ],
        );
      },
    );
  }
}

class _PastDaysSection extends ConsumerWidget {
  const _PastDaysSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pastAsync = ref.watch(pastDaysProvider);
    final theme = Theme.of(context);

    return pastAsync.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Previous days', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ContentSkeleton.card(height: 56),
          const SizedBox(height: 8),
          ContentSkeleton.card(height: 56),
        ],
      ),
      error: (e, _) => EmptyState(
        title: 'Unable to load previous days',
        message: userFriendlyError(e),
        actionLabel: 'Try again',
        onAction: () => ref.invalidate(pastDaysProvider),
      ),
      data: (days) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Previous days', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (days.isEmpty)
              const EmptyState(
                title: 'No previous days yet',
                message:
                    'Past reflections will appear here as you progress through the programme.',
              )
            else
              ...days.map((day) => _DayAccordion(day: day)),
          ],
        );
      },
    );
  }
}

class _DayCard extends ConsumerStatefulWidget {
  const _DayCard({required this.day, required this.theme});

  final Day day;
  final ThemeData theme;

  @override
  ConsumerState<_DayCard> createState() => _DayCardState();
}

class _DayCardState extends ConsumerState<_DayCard> {
  bool _exporting = false;

  Future<void> _exportPdf() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final doc = await const DayPdfBuilder().build(widget.day);
      await Printing.sharePdf(
        bytes: await doc.save(),
        filename: 'paedia-day-${widget.day.dayNumber}.pdf',
      );
      await AppAnalytics.logPdfExport(dayNumber: widget.day.dayNumber);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not create PDF. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final day = widget.day;
    final theme = widget.theme;
    final showIllustration =
        ref.watch(experimentalFeaturesProvider).showDayIllustrations;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showIllustration) ...[
              DayIllustration(imageUrl: day.illustration),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: Text(day.title, style: theme.textTheme.titleMedium),
                ),
                IconButton(
                  tooltip: 'Export PDF',
                  icon: _exporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: LoadingIndicator(size: 20),
                        )
                      : const Icon(Icons.picture_as_pdf_outlined),
                  onPressed: _exporting ? null : _exportPdf,
                ),
              ],
            ),
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
          theme: paediaExpandableTheme(context),
          header: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              minVerticalPadding: 12,
              title: Text('Day ${day.dayNumber}: ${day.title}'),
            ),
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
          title:
              day.questionsTitle.isNotEmpty ? day.questionsTitle : 'Questions',
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
          Text(
            section.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.15,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          if (section.isHtml)
            HtmlContentView(html: section.body)
          else
            SelectionArea(
              child: Text(section.body, style: theme.textTheme.bodyMedium),
            ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}
