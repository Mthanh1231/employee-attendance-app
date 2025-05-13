// lib/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_attendance_clean/presentation/blocs/user/user_bloc.dart';
import 'package:flutter_attendance_clean/presentation/blocs/user/user_event.dart';
import 'package:flutter_attendance_clean/presentation/blocs/user/user_state.dart';
import 'package:flutter_attendance_clean/data/models/user_model.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _profileLoaded = false;

  @override
  void initState() {
    super.initState();
    final userBloc = context.read<UserBloc>();
    final state = userBloc.state;
    if (state is UserAuthenticated && !_profileLoaded) {
      // Ép kiểu user về UserModel để kiểm tra token
      final user = state.user;
      if (user is UserModel && user.token.isNotEmpty) {
        userBloc.add(LoadUserProfile());
        _profileLoaded = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (ctx, state) {
          if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
        builder: (ctx, state) {
          if (state is UserLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is UserAuthenticated) {
            final user = state.user;
            return SafeArea(
              child: SingleChildScrollView(
                // Thêm SingleChildScrollView ở đây
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile card
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Avatar placeholder
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.2),
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(height: 16),

                            // User information
                            _buildInfoRow(
                                Icons.email_outlined, 'Email', user.email),
                            _buildInfoRow(
                                Icons.phone_outlined, 'Phone', user.phone),
                            if (user.employeeId != null)
                              _buildInfoRow(Icons.badge_outlined, 'Employee ID',
                                  user.employeeId!),
                          ],
                        ),
                      ),

                      SizedBox(height: 32),

                      // Section title
                      Text(
                        'Quick Access',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      SizedBox(height: 16),

                      // Feature buttons grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.5,
                        children: [
                          _buildFeatureCard(
                            context,
                            Icons.edit_outlined,
                            'Edit Profile',
                            () => Navigator.pushNamed(context, '/edit-profile'),
                          ),
                          _buildFeatureCard(
                            context,
                            Icons.calendar_today_outlined,
                            'Attendance',
                            () => Navigator.pushNamed(context, '/attendance'),
                          ),
                          _buildFeatureCard(
                            context,
                            Icons.history_outlined,
                            'History',
                            () => Navigator.pushNamed(
                                context, '/attendance-history'),
                          ),
                          _buildFeatureCard(
                            context,
                            Icons.people_outline,
                            'User List',
                            () => Navigator.pushNamed(context, '/user-list'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_circle_outlined,
                    size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Please login to view your profile',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: Text('Go to Login'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value ?? '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
