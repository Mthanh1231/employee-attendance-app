//lib/domain/entities/attendance.dart

class Attendance {
  final String id;
  final DateTime timestamp;
  final String status;
  final double lat;
  final double lng;
  final String? note;
  final bool isLate;

  Attendance({
    required this.id,
    required this.timestamp,
    required this.status,
    required this.lat,
    required this.lng,
    this.note,
    required this.isLate,
  });
}
