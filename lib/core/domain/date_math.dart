/// Unified programme day calculations using local calendar dates.
///
/// All day-index math uses [toLocalDateOnly] so UTC/local mismatches at
/// midnight are avoided consistently across the app.
DateTime toLocalDateOnly(DateTime dateTime) {
  final local = dateTime.toLocal();
  return DateTime(local.year, local.month, local.day);
}

/// Normalises a programme start date to the local calendar day (midnight local).
DateTime normalizeProgrammeStartDate(DateTime date) => toLocalDateOnly(date);

/// Whether the programme has not started yet (start is in the future).
bool isProgrammePreStart(DateTime? startDate) {
  final offset = dayOffsetFromStart(startDate);
  return offset != null && offset < 0;
}

/// Calendar-day difference from [startDate] to today (local). Negative before start.
int? dayOffsetFromStart(DateTime? startDate) {
  if (startDate == null) return null;
  final start = toLocalDateOnly(startDate);
  final today = toLocalDateOnly(DateTime.now());
  return today.difference(start).inDays;
}

/// Programme end date (start + 90 days).
DateTime? programmeEndDate(DateTime? startDate) {
  if (startDate == null) return null;
  return startDate.add(const Duration(days: 90));
}

/// 1-based programme day number, or null before start or after day 90.
int? programmeDayNumber(DateTime? startDate) {
  final offset = dayOffsetFromStart(startDate);
  if (offset == null || offset < 0) return null;
  final day = offset + 1;
  if (day > 90) return null;
  return day;
}

/// Human-readable programme status label.
String? programmeDayLabel(DateTime? startDate) {
  final offset = dayOffsetFromStart(startDate);
  if (offset == null) return null;
  if (offset < 0) {
    final daysUntil = -offset;
    return 'Your Paedia starts in $daysUntil day${daysUntil == 1 ? '' : 's'}';
  }
  final day = offset + 1;
  if (day > 90) {
    return 'Programme complete — congratulations on finishing Paedia!';
  }
  return 'Day $day';
}

/// Whether the user has finished the 90-day programme.
bool isProgrammeComplete(DateTime? startDate) {
  final offset = dayOffsetFromStart(startDate);
  if (offset == null) return false;
  return offset + 1 > 90;
}

/// Fasting / Sabbath label for the current local weekday.
String specialDayLabel() {
  switch (DateTime.now().weekday) {
    case DateTime.wednesday:
    case DateTime.friday:
      return 'Fasting Day';
    case DateTime.saturday:
    case DateTime.sunday:
      return 'Sabbath Day';
    default:
      return '';
  }
}
