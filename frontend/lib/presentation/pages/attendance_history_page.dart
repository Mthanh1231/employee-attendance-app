// lib/presentation/pages/attendance_history_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:flutter_attendance_clean/presentation/blocs/attendance/attendance_bloc.dart';
import 'package:flutter_attendance_clean/presentation/blocs/attendance/attendance_event.dart';
import 'package:flutter_attendance_clean/presentation/blocs/attendance/attendance_state.dart';

class AttendanceHistoryPage extends StatefulWidget {
  @override
  _AttendanceHistoryPageState createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());
  final List<String> _statusFilters = ['All', 'Checkin', 'Checkout', 'Absent'];
  String _currentFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Trigger fetching of history when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceBloc>().add(LoadAttendanceHistory());
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'List View'),
            Tab(text: 'Calendar View'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => context.read<AttendanceBloc>().add(LoadAttendanceHistory()),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListView(),
          _buildCalendarView(),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (ctx, state) {
        if (state is AttendanceLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AttendanceHistoryLoaded) {
          final history = _filterAttendance(state.history);
          
          if (history.isEmpty) {
            return const Center(child: Text('No attendance records found'));
          }
          
          // Group by date
          final Map<String, List<dynamic>> groupedRecords = {};
          for (var rec in history) {
            final date = _formatDate(rec.timestamp, 'yyyy-MM-dd');
            if (!groupedRecords.containsKey(date)) {
              groupedRecords[date] = [];
            }
            groupedRecords[date]!.add(rec);
          }

          final sortedDates = groupedRecords.keys.toList()..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            itemCount: sortedDates.length,
            itemBuilder: (_, dateIndex) {
              final date = sortedDates[dateIndex];
              final records = groupedRecords[date]!;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ExpansionTile(
                  title: Text(
                    _formatDate(records.first.timestamp, 'EEEE, MMM dd, yyyy'),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: records.map<Widget>((rec) {
                    return _buildAttendanceItem(rec);
                  }).toList(),
                ),
              );
            },
          );
        }
        if (state is AttendanceError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.message}', style: TextStyle(color: Colors.red)),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<AttendanceBloc>().add(LoadAttendanceHistory()),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }
        // initial or other states
        return const Center(child: Text('Loading attendance history…'));
      },
    );
  }

  Widget _buildAttendanceItem(dynamic rec) {
    final IconData icon;
    final Color color;
    
    if (rec.status == 'checkin') {
      icon = Icons.login;
      color = _getColorForNote(rec.note);
    } else if (rec.status == 'checkout') {
      icon = Icons.logout;
      color = _getColorForNote(rec.note);
    } else if (rec.status == 'absent') {
      icon = Icons.do_not_disturb;
      color = Colors.red;
    } else {
      icon = Icons.help_outline;
      color = Colors.grey;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(
        '${rec.status.toUpperCase()} at ${_formatDate(rec.timestamp, 'HH:mm:ss')}',
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(rec.note.isNotEmpty ? rec.note : 'No note'),
      trailing: rec.lat != null && rec.lng != null
          ? Tooltip(
              message: 'Location recorded',
              child: Icon(Icons.location_on, color: Colors.blue),
            )
          : null,
    );
  }

  Widget _buildCalendarView() {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (ctx, state) {
        if (state is AttendanceLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AttendanceHistoryLoaded) {
          // Here we'd normally use the Calendar API endpoint
          // but for now we'll display a placeholder with a month picker
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () => _changeMonth(-1),
                    ),
                    SizedBox(width: 8),
                    Text(
                      DateFormat('MMMM yyyy').format(
                        DateTime.parse('$_selectedMonth-01')
                      ),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Calendar view will be implemented soon.\nPlease use the List View tab for now.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AttendanceBloc>().add(
                      LoadAttendanceCalendar(_selectedMonth)
                    );
                  },
                  child: Text('Load Calendar Data'),
                ),
              ),
            ],
          );
        }
        return const Center(child: Text('No calendar data available'));
      },
    );
  }

  void _changeMonth(int delta) {
    final date = DateTime.parse('$_selectedMonth-01');
    final newDate = DateTime(date.year, date.month + delta);
    setState(() {
      _selectedMonth = DateFormat('yyyy-MM').format(newDate);
    });
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Filter Records'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: _statusFilters.map((filter) {
                return RadioListTile<String>(
                  title: Text(filter),
                  value: filter,
                  groupValue: _currentFilter,
                  onChanged: (value) {
                    setState(() => _currentFilter = value!);
                  },
                );
              }).toList(),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {}); // Refresh to apply filter
              Navigator.pop(context);
            },
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }

  List<dynamic> _filterAttendance(List<dynamic> history) {
    if (_currentFilter == 'All') return history;
    
    return history.where((rec) {
      return rec.status.toLowerCase() == _currentFilter.toLowerCase();
    }).toList();
  }

  String _formatDate(String timestamp, String format) {
    try {
      final date = DateTime.parse(timestamp);
      return DateFormat(format).format(date);
    } catch (e) {
      return timestamp;
    }
  }

  Color _getColorForNote(String note) {
    if (note.contains('Late')) return Colors.red;
    if (note.contains('Early')) return Colors.orange;
    if (note.contains('OT')) return Colors.green;
    return Colors.blue; // default
  }
}