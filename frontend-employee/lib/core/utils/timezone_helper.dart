import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class TimezoneHelper {
  static const String timezone = 'Asia/Ho_Chi_Minh';
  
  static void initialize() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(timezone));
  }

  static DateTime toLocal(DateTime utc) {
    return tz.TZDateTime.from(utc, tz.getLocation(timezone));
  }

  static DateTime toUTC(DateTime local) {
    return tz.TZDateTime.from(local, tz.getLocation(timezone)).toUtc();
  }

  static String formatDateTime(DateTime dateTime, {String format = 'yyyy-MM-dd HH:mm'}) {
    final local = toLocal(dateTime);
    return DateFormat(format).format(local);
  }

  static String formatDate(DateTime dateTime) {
    return formatDateTime(dateTime, format: 'yyyy-MM-dd');
  }

  static String formatTime(DateTime dateTime) {
    return formatDateTime(dateTime, format: 'HH:mm');
  }

  static bool isWorkday(DateTime date) {
    final local = toLocal(date);
    final weekday = local.weekday;
    return weekday >= DateTime.monday && weekday <= DateTime.friday;
  }

  static bool isWeekend(DateTime date) {
    final local = toLocal(date);
    final weekday = local.weekday;
    return weekday == DateTime.saturday || weekday == DateTime.sunday;
  }

  static DateTime getStartOfDay(DateTime date) {
    final local = toLocal(date);
    return DateTime(local.year, local.month, local.day);
  }

  static DateTime getEndOfDay(DateTime date) {
    final local = toLocal(date);
    return DateTime(local.year, local.month, local.day, 23, 59, 59);
  }

  static DateTime getWorkStartTime(DateTime date) {
    final local = toLocal(date);
    return DateTime(local.year, local.month, local.day, 8, 0, 0);
  }

  static DateTime getWorkEndTime(DateTime date) {
    final local = toLocal(date);
    return DateTime(local.year, local.month, local.day, 17, 0, 0);
  }
} 