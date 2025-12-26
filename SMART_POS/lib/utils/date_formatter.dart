import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String formatCurrency(double amount, {String currency = 'USD'}) {
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$', // You can customize this based on your locale
      decimalDigits: 2,
    ).format(amount);
  }

  static String formatNumber(double number) {
    return NumberFormat('#,##0.00').format(number);
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999, 999);
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999, 999);
  }

  static List<DateTime> getDaysInMonth(DateTime date) {
    List<DateTime> days = [];
    DateTime firstDay = startOfMonth(date);
    DateTime lastDay = endOfMonth(date);

    for (DateTime day = firstDay; day.isBefore(lastDay.add(const Duration(days: 1))); day = day.add(const Duration(days: 1))) {
      days.add(day);
    }

    return days;
  }
}