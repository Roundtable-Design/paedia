import '/core/domain/date_math.dart' as date_math;

DateTime? calculateEndDate(DateTime? startDate) {
  return date_math.programmeEndDate(startDate);
}

String? calculateDateNumber(DateTime? startDate) {
  return date_math.programmeDayLabel(startDate);
}

int? returnDayInInteger(DateTime? startDate) {
  return date_math.programmeDayNumber(startDate);
}

String specialDayOfTheWeek() {
  return date_math.specialDayLabel();
}

String? returnDayinString(DateTime? startDate) {
  final day = date_math.programmeDayNumber(startDate);
  return day?.toString();
}
