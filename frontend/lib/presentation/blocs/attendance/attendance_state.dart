//lib/presentation/blocs/attendance/attendance_state.dart
import 'package:equatable/equatable.dart';
import '../../../data/models/attendance_model.dart';

abstract class AttendanceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceMarked extends AttendanceState {
  final AttendanceRecord record;
  AttendanceMarked(this.record);
  @override List<Object?> get props => [record];
}

class AttendanceHistoryLoaded extends AttendanceState {
  final List<AttendanceRecord> history;
  AttendanceHistoryLoaded(this.history);
  @override List<Object?> get props => [history];
}

class AttendanceCalendarLoaded extends AttendanceState {
  final List<AttendanceDay> calendar;
  AttendanceCalendarLoaded(this.calendar);
  @override List<Object?> get props => [calendar];
}

class AttendanceError extends AttendanceState {
  final String message;
  AttendanceError(this.message);
  @override List<Object?> get props => [message];
}
