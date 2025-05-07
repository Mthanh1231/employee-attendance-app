//lib/data/models/attendance_model.dart
class AttendanceRecord {
  final String id;
  final String timestamp;
  final String note;

  AttendanceRecord({
    required this.id,
    required this.timestamp,
    required this.note,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      timestamp: json['timestamp'] as String,
      note: json['note'] as String? ?? '',
    );
  }
}

class AttendanceDay {
  final String date;
  final String status;
  final String? detail;

  AttendanceDay({
    required this.date,
    required this.status,
    this.detail,
  });

  factory AttendanceDay.fromJson(Map<String, dynamic> json) {
    return AttendanceDay(
      date: json['date'] as String,
      status: json['status'] as String,
      detail: json['detail'] as String?,
    );
  }
}
