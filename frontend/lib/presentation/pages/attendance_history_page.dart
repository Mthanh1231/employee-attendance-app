// lib/presentation/pages/attendance_history_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_attendance_clean/presentation/blocs/attendance/attendance_bloc.dart';
import 'package:flutter_attendance_clean/presentation/blocs/attendance/attendance_event.dart';
import 'package:flutter_attendance_clean/presentation/blocs/attendance/attendance_state.dart';

class AttendanceHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Trigger fetching of history when the page is built
    context.read<AttendanceBloc>().add(LoadAttendanceHistory());

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance History')),
      body: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (ctx, state) {
          if (state is AttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AttendanceHistoryLoaded) {
            final history = state.history;
            if (history.isEmpty) {
              return const Center(child: Text('No attendance records'));
            }
            return ListView.separated(
              itemCount: history.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, idx) {
                final rec = history[idx];
                return ListTile(
                  leading: Icon(
                    rec.note.contains('Late')
                        ? Icons.watch_later
                        : Icons.check_circle,
                    color: rec.note.contains('Late') ? Colors.red : Colors.green,
                  ),
                  title: Text(rec.timestamp),
                  subtitle: Text(rec.note),
                );
              },
            );
          }
          if (state is AttendanceError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          // initial or other states
          return const Center(child: Text('Loading attendance history…'));
        },
      ),
    );
  }
}
