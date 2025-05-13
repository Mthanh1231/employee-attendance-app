// lib/domain/repositories/attendance_repository.dart

import 'package:flutter_attendance_clean/data/models/attendance_model.dart';

abstract class AttendanceRepository {
  Future<AttendanceRecord> markAttendance(String type, double lat, double lng);
  Future<List<AttendanceRecord>> getHistory();
  Future<List<AttendanceDay>> getCalendar(String month);
}
