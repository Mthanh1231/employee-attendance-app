// lib/presentation/pages/attendance_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import 'package:flutter_attendance_clean/presentation/blocs/attendance/attendance_bloc.dart';
import 'package:flutter_attendance_clean/presentation/blocs/attendance/attendance_event.dart';
import 'package:flutter_attendance_clean/presentation/blocs/attendance/attendance_state.dart';
import 'package:flutter_attendance_clean/data/models/attendance_model.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  AttendanceRecord? _lastCheckin;
  AttendanceRecord? _lastCheckout;
  bool _hasCheckedInToday = false;
  bool _hasCheckedOutToday = false;
  DateTime _lastRefresh = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Load attendance history when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceBloc>().add(LoadAttendanceHistory());
    });
  }

  Future<Position> _determinePosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp).toLocal();
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  bool _isToday(String timestamp) {
    final today = DateTime.now().toLocal();
    final recordDate = DateTime.parse(timestamp).toLocal();
    return today.year == recordDate.year &&
        today.month == recordDate.month &&
        today.day == recordDate.day;
  }

  void _updateAttendanceStatus(List<AttendanceRecord> history) {
    final todayRecords =
        history.where((record) => _isToday(record.timestamp)).toList();

    // Debug info
    print('Found ${todayRecords.length} records for today');
    for (var rec in todayRecords) {
      print(
          'Record: status=${rec.status}, timestamp=${rec.timestamp}, note=${rec.note}');
    }

    // Find latest check-in and check-out for today based on status field
    AttendanceRecord? latestCheckin;
    AttendanceRecord? latestCheckout;

    for (var record in todayRecords) {
      // Primary method: use the status field
      if (record.status == 'checkin') {
        if (latestCheckin == null ||
            DateTime.parse(record.timestamp)
                .isAfter(DateTime.parse(latestCheckin.timestamp))) {
          latestCheckin = record;
        }
      } else if (record.status == 'checkout') {
        if (latestCheckout == null ||
            DateTime.parse(record.timestamp)
                .isAfter(DateTime.parse(latestCheckout.timestamp))) {
          latestCheckout = record;
        }
      }
      // Fallback method: use the note content
      else if (record.note.toLowerCase().contains('late') ||
          record.note.toLowerCase().contains('early') &&
              !record.note.toLowerCase().contains('checkout')) {
        if (latestCheckin == null ||
            DateTime.parse(record.timestamp)
                .isAfter(DateTime.parse(latestCheckin.timestamp))) {
          latestCheckin = record;
        }
      } else if (record.note.toLowerCase().contains('ot') ||
          record.note.toLowerCase().contains('checkout') ||
          record.note.toLowerCase().contains('check-out')) {
        if (latestCheckout == null ||
            DateTime.parse(record.timestamp)
                .isAfter(DateTime.parse(latestCheckout.timestamp))) {
          latestCheckout = record;
        }
      }
    }

    if (latestCheckin != null) {
      print('Latest check-in: ${latestCheckin.timestamp}');
    }
    if (latestCheckout != null) {
      print('Latest check-out: ${latestCheckout.timestamp}');
    }

    setState(() {
      _lastCheckin = latestCheckin;
      _lastCheckout = latestCheckout;
      _hasCheckedInToday = latestCheckin != null;
      _hasCheckedOutToday = latestCheckout != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());
    final currentTime = DateFormat('HH:mm').format(DateTime.now());

    // Set up a timer to update the current time
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          // Just to trigger a rebuild for time update
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AttendanceBloc>().add(LoadAttendanceHistory());
            },
          ),
        ],
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
            // Directly update UI state based on marked attendance
            final record = state.record;
            final isCheckin = record.status == 'checkin' ||
                record.note.toLowerCase().contains('late') ||
                record.note.toLowerCase().contains('early');
            final isCheckout = record.status == 'checkout' ||
                record.note.toLowerCase().contains('ot');

            setState(() {
              if (isCheckin) {
                _lastCheckin = record;
                _hasCheckedInToday = true;
              }
              if (isCheckout) {
                _lastCheckout = record;
                _hasCheckedOutToday = true;
              }
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Attendance marked successfully'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
              ),
            );

            // Reload attendance history after marking attendance
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                context.read<AttendanceBloc>().add(LoadAttendanceHistory());
              }
            });
          }

          if (state is AttendanceHistoryLoaded) {
            _updateAttendanceStatus(state.history);
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
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

                const SizedBox(height: 20),

                // Today's Attendance Status
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Today's Attendance",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatusIndicator(
                                title: 'Check In',
                                isComplete: _hasCheckedInToday,
                                time: _lastCheckin != null
                                    ? _formatTimestamp(_lastCheckin!.timestamp)
                                    : '--:--',
                                note: _lastCheckin?.note ?? '',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatusIndicator(
                                title: 'Check Out',
                                isComplete: _hasCheckedOutToday,
                                time: _lastCheckout != null
                                    ? _formatTimestamp(_lastCheckout!.timestamp)
                                    : '--:--',
                                note: _lastCheckout?.note ?? '',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Status indicator or message
                if (state is AttendanceLoading)
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text('Processing...'),
                      ],
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
                        color: _hasCheckedInToday ? Colors.grey : Colors.green,
                        type: 'checkin',
                        isLoading: state is AttendanceLoading,
                        isDisabled: _hasCheckedInToday,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAttendanceButton(
                        context: context,
                        label: 'Check Out',
                        icon: Icons.logout,
                        color: (!_hasCheckedInToday || _hasCheckedOutToday)
                            ? Colors.grey
                            : Colors.blue,
                        type: 'checkout',
                        isLoading: state is AttendanceLoading,
                        isDisabled: !_hasCheckedInToday || _hasCheckedOutToday,
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

  Widget _buildStatusIndicator({
    required String title,
    required bool isComplete,
    required String time,
    required String note,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isComplete
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isComplete ? Colors.green : Colors.grey,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isComplete ? Colors.green : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isComplete ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (note.isNotEmpty && isComplete)
            Text(
              note,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
        ],
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
    required bool isDisabled,
  }) {
    return ElevatedButton(
      onPressed: (isLoading || isDisabled)
          ? null
          : () async {
              try {
                final pos = await _determinePosition();
                final bloc = context.read<AttendanceBloc>();
                bloc.add(MarkAttendance(type, pos.latitude, pos.longitude));
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
        disabledBackgroundColor: Colors.grey,
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
