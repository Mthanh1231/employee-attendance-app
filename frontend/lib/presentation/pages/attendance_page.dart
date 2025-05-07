// lib/presentation/pages/attendance_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter_attendance_clean/presentation/blocs/attendance/attendance_bloc.dart';
import 'package:flutter_attendance_clean/presentation/blocs/attendance/attendance_event.dart';
import 'package:flutter_attendance_clean/presentation/blocs/attendance/attendance_state.dart';
import 'package:flutter_attendance_clean/presentation/widgets/custom_button.dart';

class AttendancePage extends StatelessWidget {
  Future<Position> _determinePosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (ctx, state) {
          if (state is AttendanceError) {
            ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is AttendanceMarked) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Marked at ${state.record.timestamp}')),
            );
          }
        },
        builder: (ctx, state) {
          if (state is AttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  label: 'Check In',
                  onPressed: () async {
                    final pos = await _determinePosition();
                    context.read<AttendanceBloc>().add(
                          MarkAttendance('checkin', pos.latitude, pos.longitude),
                        );
                  },
                ),
                const SizedBox(height: 20),
                CustomButton(
                  label: 'Check Out',
                  onPressed: () async {
                    final pos = await _determinePosition();
                    context.read<AttendanceBloc>().add(
                          MarkAttendance('checkout', pos.latitude, pos.longitude),
                        );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
