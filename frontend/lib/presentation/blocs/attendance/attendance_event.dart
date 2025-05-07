//lib/presentation/blocs/attendance/attendance_event.dart

import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class MarkAttendance extends AttendanceEvent {
  final String type; // 'checkin' or 'checkout'
  final double lat, lng;
  MarkAttendance(this.type, this.lat, this.lng);
  @override List<Object?> get props => [type, lat, lng];
}

class LoadAttendanceHistory extends AttendanceEvent {}

class LoadAttendanceCalendar extends AttendanceEvent {
  final String month;
  LoadAttendanceCalendar(this.month);
  @override List<Object?> get props => [month];
}
