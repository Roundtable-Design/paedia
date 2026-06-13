import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '/core/domain/date_math.dart';
import '/shared/theme/paedia_tokens.dart';

/// Programme day header with dates, progress, and special-day badge.
class DayHeader extends StatelessWidget {
  const DayHeader({
    super.key,
    required this.startDate,
    this.missingStartMessage =
        'Please select your gender and start date so we can show the right content.',
  });

  final DateTime? startDate;
  final String missingStartMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.paediaTokens;
    final dateFormat = DateFormat.MMMEd();

    if (startDate == null) {
      return Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Text(
          missingStartMessage,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall,
        ),
      );
    }

    final endDate = programmeEndDate(startDate);
    final dayNumber = programmeDayNumber(startDate);
    final complete = isProgrammeComplete(startDate);
    final label = programmeDayLabel(startDate);
    final specialDay = specialDayLabel();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.spacingSm),
      child: Column(
        children: [
          Text(
            '${dateFormat.format(startDate!)} – ${endDate != null ? dateFormat.format(endDate) : ''}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: tokens.spacingSm),
          if (label != null)
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: complete ? tokens.programmeComplete : null,
              ),
            ),
          if (!complete && dayNumber != null) ...[
            SizedBox(height: tokens.spacingSm),
            Text(
              'Day $dayNumber of 90',
              style: theme.textTheme.labelSmall,
            ),
            SizedBox(height: tokens.spacingSm),
            ClipRRect(
              borderRadius: BorderRadius.circular(tokens.radiusSm),
              child: LinearProgressIndicator(
                value: dayNumber / 90,
                minHeight: 6,
                backgroundColor:
                    theme.colorScheme.onSurface.withValues(alpha: 0.1),
                color: theme.colorScheme.primary,
              ),
            ),
          ],
          if (complete) ...[
            SizedBox(height: tokens.spacingSm),
            Icon(
              Icons.celebration_outlined,
              color: tokens.programmeComplete,
              size: 32,
              semanticLabel: 'Programme complete',
            ),
          ],
          if (specialDay.isNotEmpty && !complete) ...[
            SizedBox(height: tokens.spacingSm),
            Text(
              specialDay,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontStyle: FontStyle.italic,
                color: specialDay == 'Fasting Day'
                    ? tokens.fastingDay
                    : tokens.sabbathDay,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
