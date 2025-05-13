//lib/domain/entities/attendance_stats.dart
class AttendanceStats {
  final int totalDays;
  final int presentDays;
  final int lateDays;
  final int absentDays;
  final int leaveDays;

  AttendanceStats({
    required this.totalDays,
    required this.presentDays,
    required this.lateDays,
    required this.absentDays,
    required this.leaveDays,
  });
}
