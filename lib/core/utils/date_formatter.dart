import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String format(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  static String formatWithDay(DateTime date) {
    return DateFormat('EEE, MMM d, yyyy').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat.yMMMM().format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expenseDate = DateTime(date.year, date.month, date.day);

    final difference = today.difference(expenseDate).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference > 1 && difference < 7) {
      return DateFormat('EEEE').format(date); // Day of week
    } else {
      return DateFormat.MMMd().format(date);
    }
  }

}
