// lib/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_attendance_clean/presentation/blocs/user/user_bloc.dart';
import 'package:flutter_attendance_clean/presentation/blocs/user/user_event.dart';
import 'package:flutter_attendance_clean/presentation/blocs/user/user_state.dart';

import '../widgets/custom_button.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Trigger load profile when this page is shown
    context.read<UserBloc>().add(LoadUserProfile());

    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (ctx, state) {
          if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message))
            );
          }
        },
        builder: (ctx, state) {
          if (state is UserLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is UserAuthenticated) {
            final user = state.user;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${user.email}', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Phone: ${user.phone}', style: TextStyle(fontSize: 16)),
                  if (user.employeeId != null) ...[
                    SizedBox(height: 8),
                    Text('Employee ID: ${user.employeeId}', style: TextStyle(fontSize: 16)),
                  ],
                  Spacer(),
                  CustomButton(
                    label: 'Edit Profile',
                    onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
                  ),
                  SizedBox(height: 12),
                  CustomButton(
                    label: 'Attendance',
                    onPressed: () => Navigator.pushNamed(context, '/attendance'),
                  ),
                  SizedBox(height: 12),
                  CustomButton(
                    label: 'History',
                    onPressed: () => Navigator.pushNamed(context, '/attendance-history'),
                  ),
                  SizedBox(height: 12),
                  CustomButton(
                    label: 'User List',
                    onPressed: () => Navigator.pushNamed(context, '/user-list'),
                  ),
                ],
              ),
            );
          }
          return Center(child: Text('Please login'));
        },
      ),
    );
  }
}
