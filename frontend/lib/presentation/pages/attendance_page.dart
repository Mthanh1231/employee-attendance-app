// lib/presentation/pages/attendance_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import 'package:flutter_attendance_clean/presentation/blocs/attendance/attendance_bloc.dart';
import 'package:flutter_attendance_clean/presentation/blocs/attendance/attendance_event.dart';
import 'package:flutter_attendance_clean/presentation/blocs/attendance/attendance_state.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({Key? key}) : super(key: key);

  Future<Position> _determinePosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());
    final currentTime = DateFormat('HH:mm').format(DateTime.now());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (ctx, state) {
          if (state is AttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is AttendanceMarked) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Attendance marked successfully at ${state.record.timestamp}'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (ctx, state) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and time display
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          today,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Current Time: $currentTime',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Status indicator or message
                if (state is AttendanceLoading)
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text('Getting your location...'),
                      ],
                    ),
                  )
                else
                  const Center(
                    child: Text(
                      'Please mark your attendance',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                
                const Spacer(),
                
                // Attendance buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildAttendanceButton(
                        context: context,
                        label: 'Check In',
                        icon: Icons.login,
                        color: Colors.green,
                        type: 'checkin',
                        isLoading: state is AttendanceLoading,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAttendanceButton(
                        context: context,
                        label: 'Check Out',
                        icon: Icons.logout,
                        color: Colors.blue,
                        type: 'checkout',
                        isLoading: state is AttendanceLoading,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildAttendanceButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required String type,
    required bool isLoading,
  }) {
    return ElevatedButton(
      onPressed: isLoading
          ? null
          : () async {
              try {
                final pos = await _determinePosition();
                context.read<AttendanceBloc>().add(
                      MarkAttendance(type, pos.latitude, pos.longitude),
                    );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error getting location: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}