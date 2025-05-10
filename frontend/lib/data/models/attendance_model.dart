//lib/data/models/attendance_model.dart
class AttendanceRecord {
  final String id;
  final String timestamp;
  final String status;
  final double? lat;
  final double? lng;
  final String note;

  AttendanceRecord({
    required this.id,
    required this.timestamp,
    this.status = '',
    this.lat,
    this.lng,
    required this.note,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] ?? '',
      timestamp: json['timestamp'] ?? '',
      status: json['status'] ?? '',
      lat: json['lat'] != null ? json['lat'].toDouble() : null,
      lng: json['lng'] != null ? json['lng'].toDouble() : null,
      note: json['note'] ?? '',
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
