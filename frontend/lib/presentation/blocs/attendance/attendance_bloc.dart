//lib/presentation/blocs/attendance/attendance_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/attendance_repository.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository repository;

  AttendanceBloc(this.repository) : super(AttendanceInitial()) {
    on<MarkAttendance>((e, emit) async {
      emit(AttendanceLoading());
      try {
        final rec = await repository.markAttendance(e.type, e.lat, e.lng);
        emit(AttendanceMarked(rec));
      } catch (ex) {
        emit(AttendanceError(ex.toString()));
      }
    });
    on<LoadAttendanceHistory>((_, emit) async {
      emit(AttendanceLoading());
      try {
        final hist = await repository.getHistory();
        emit(AttendanceHistoryLoaded(hist));
      } catch (ex) {
        emit(AttendanceError(ex.toString()));
      }
    });
    on<LoadAttendanceCalendar>((e, emit) async {
      emit(AttendanceLoading());
      try {
        final cal = await repository.getCalendar(e.month);
        emit(AttendanceCalendarLoaded(cal));
      } catch (ex) {
        emit(AttendanceError(ex.toString()));
      }
    });
  }
}
