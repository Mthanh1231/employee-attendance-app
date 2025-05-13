// lib/data/datasources/repositories/attendance_repository_impl.dart

import 'dart:async';
import 'package:flutter_attendance_clean/data/datasources/remote/attendance_remote_datasource.dart';
import 'package:flutter_attendance_clean/data/models/attendance_model.dart';
import 'package:flutter_attendance_clean/domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remote;
  AttendanceRepositoryImpl({required this.remote});

  @override
  Future<AttendanceRecord> markAttendance(String type, double lat, double lng) {
    return type == 'checkin'
        ? remote.checkIn(lat, lng)
        : remote.checkOut(lat, lng);
  }

  @override
  Future<List<AttendanceRecord>> getHistory() {
    return remote.getHistory();
  }

  @override
  Future<List<AttendanceDay>> getCalendar(String month) {
    return remote.getCalendar(month);
  }
}
