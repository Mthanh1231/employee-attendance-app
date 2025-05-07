// lib/presentation/pages/user_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_attendance_clean/presentation/blocs/user/user_bloc.dart';
import 'package:flutter_attendance_clean/presentation/blocs/user/user_event.dart';
import 'package:flutter_attendance_clean/presentation/blocs/user/user_state.dart';


class UserListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // If you implement GetAllUsers usecase:
    // context.read<UserBloc>().add(LoadAllUsers());

    return Scaffold(
      appBar: AppBar(title: Text('User List')),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (ctx, state) {
          if (state is UserLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is UserAuthenticated /* or a dedicated UsersLoaded state */) {
            final users = [state.user]; // replace with actual list
            if (users.isEmpty) {
              return Center(child: Text('No users found'));
            }
            return ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => Divider(),
              itemBuilder: (_, idx) {
                final u = users[idx];
                return ListTile(
                  title: Text(u.email),
                  subtitle: Text('Phone: ${u.phone}\nEmpID: ${u.employeeId ?? '-'}'),
                  isThreeLine: true,
                );
              },
            );
          }
          if (state is UserError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return Center(child: Text('Load users'));
        },
      ),
    );
  }
}
