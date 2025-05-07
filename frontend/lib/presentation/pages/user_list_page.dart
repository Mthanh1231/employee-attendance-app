// lib/presentation/pages/user_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_attendance_clean/presentation/blocs/user/user_bloc.dart';
import 'package:flutter_attendance_clean/presentation/blocs/user/user_state.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tải danh sách người dùng khi trang được tạo
    // Uncomment và thay thế LoadUserProfile() bằng event phù hợp cho danh sách người dùng
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<UserBloc>().add(LoadUserProfile());
    // });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách người dùng', 
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Uncomment và thay thế với event phù hợp
              // context.read<UserBloc>().add(LoadUserProfile());
            },
            tooltip: 'Làm mới danh sách',
          ),
        ],
      ),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
              )
            );
          }
        },
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is UserAuthenticated /* hoặc UsersLoaded state */) {
            final users = [state.user]; // thay thế bằng danh sách thực tế
            
            if (users.isEmpty) {
              return _buildEmptyState();
            }
            
            return _buildUserList(users, context);
          } else if (state is UserError) {
            return _buildErrorState(state.message);
          }
          
          return _buildInitialState();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Xử lý thêm người dùng mới
          // Navigator.pushNamed(context, '/add-user');
        },
        child: const Icon(Icons.person_add),
        tooltip: 'Thêm người dùng',
      ),
    );
  }

  Widget _buildUserList(List<dynamic> users, BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoText('Email', user.email),
                            if (user.employeeId != null)
                              _buildInfoText('ID nhân viên', user.employeeId),
                            _buildInfoText('Số điện thoại', user.phone),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildActionButton(
                        context,
                        Icons.edit_outlined,
                        'Sửa',
                        Colors.blue,
                        () {
                          // Xử lý chỉnh sửa người dùng
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        context,
                        Icons.delete_outline,
                        'Xóa',
                        Colors.red,
                        () {
                          // Xử lý xóa người dùng
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
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
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return TextButton.icon(
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color)),
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Không có người dùng nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.person_add),
            label: const Text('Thêm người dùng'),
            onPressed: () {
              // Xử lý thêm người dùng
              // Navigator.pushNamed(context, '/add-user');
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Đã xảy ra lỗi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            onPressed: () {
              // Thử lại tải dữ liệu
              // context.read<UserBloc>().add(LoadUserProfile());
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa tải danh sách người dùng',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Tải danh sách'),
            onPressed: () {
              // Tải danh sách người dùng
              // context.read<UserBloc>().add(LoadUserProfile());
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}