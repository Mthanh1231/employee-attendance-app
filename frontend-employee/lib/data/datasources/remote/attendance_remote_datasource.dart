//lib/data/datasources/remote/attendance_remote_datasource.dart

import 'dart:convert';
import 'package:flutter_attendance_clean/core/network/http_client.dart';
import 'package:flutter_attendance_clean/core/error/exceptions.dart';
import 'package:flutter_attendance_clean/data/models/attendance_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<AttendanceRecord> checkIn(double lat, double lng);
  Future<AttendanceRecord> checkOut(double lat, double lng);
  Future<List<AttendanceRecord>> getHistory();
  Future<List<AttendanceDay>> getCalendar(String month);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final HttpClient client;
  AttendanceRemoteDataSourceImpl({required this.client});

  @override
  Future<AttendanceRecord> checkIn(double lat, double lng) async {
    final resp = await client.post(
      '/api/employee/attendance',
      body: jsonEncode({'status': 'checkin', 'lat': lat, 'lng': lng}),
    );
    if (resp.statusCode == 200) {
      final result = jsonDecode(resp.body);
      // Create a record with proper fields
      return AttendanceRecord(
        id: result['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: result['timestamp'] ?? DateTime.now().toIso8601String(),
        status: 'checkin',
        lat: lat,
        lng: lng,
        note: result['note'] ?? result['message'] ?? 'Check-in successful',
      );
    } else {
      final msg = jsonDecode(resp.body)['message'] ?? 'Check-in failed';
      throw ServerException(msg);
    }
  }

  @override
  Future<AttendanceRecord> checkOut(double lat, double lng) async {
    final resp = await client.post(
      '/api/employee/attendance',
      body: jsonEncode({'status': 'checkout', 'lat': lat, 'lng': lng}),
    );
    if (resp.statusCode == 200) {
      final result = jsonDecode(resp.body);
      // Create a record with proper fields
      return AttendanceRecord(
        id: result['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: result['timestamp'] ?? DateTime.now().toIso8601String(),
        status: 'checkout',
        lat: lat,
        lng: lng,
        note: result['note'] ?? result['message'] ?? 'Check-out successful',
      );
    } else {
      final msg = jsonDecode(resp.body)['message'] ?? 'Check-out failed';
      throw ServerException(msg);
    }
  }

  @override
  Future<List<AttendanceRecord>> getHistory() async {
    final resp = await client.get('/api/employee/attendance');
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      final list = data['attendance'] as List;
      return list.map((e) => AttendanceRecord.fromJson(e)).toList();
    } else {
      final msg = jsonDecode(resp.body)['message'] ?? 'Fetch history failed';
      throw ServerException(msg);
    }
  }

  @override
  Future<List<AttendanceDay>> getCalendar(String month) async {
    final resp =
        await client.get('/api/employee/attendance/calendar?month=$month');
    if (resp.statusCode == 200) {
      final list = jsonDecode(resp.body)['calendar'] as List;
      return list.map((e) => AttendanceDay.fromJson(e)).toList();
    } else {
      final msg = jsonDecode(resp.body)['message'] ?? 'Fetch calendar failed';
      throw ServerException(msg);
    }
  }
}
