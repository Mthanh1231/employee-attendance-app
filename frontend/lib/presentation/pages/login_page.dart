// lib/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_attendance_clean/presentation/blocs/user/user_bloc.dart';
import 'package:flutter_attendance_clean/presentation/blocs/user/user_event.dart';
import 'package:flutter_attendance_clean/presentation/blocs/user/user_state.dart';

import '../widgets/custom_button.dart';

class LoginPage extends StatefulWidget {
  @override State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtl = TextEditingController();
  final _passCtl  = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: BlocListener<UserBloc, UserState>(
        listener: (ctx, state) {
  if (state is UserError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.message))
    );
  }
  if (state is UserAuthenticated) {                  // ← đúng
    Navigator.pushReplacementNamed(context, '/profile');
  }
},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(controller: _emailCtl, decoration: InputDecoration(labelText: 'Email')),
              TextField(controller: _passCtl, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
              SizedBox(height: 20),
              CustomButton(
                label: 'Login',
                onPressed: () {
                  context.read<UserBloc>().add(LoginUser(_emailCtl.text, _passCtl.text));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
