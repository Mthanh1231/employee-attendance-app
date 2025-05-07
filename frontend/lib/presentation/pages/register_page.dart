//lib/presentation/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_attendance_clean/presentation/blocs/user/user_bloc.dart';
import 'package:flutter_attendance_clean/presentation/blocs/user/user_event.dart';
import 'package:flutter_attendance_clean/presentation/blocs/user/user_state.dart';

import '../widgets/custom_button.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailCtl   = TextEditingController();
  final _phoneCtl   = TextEditingController();
  final _passCtl    = TextEditingController();
  final _confirmCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: BlocListener<UserBloc, UserState>(
        listener: (ctx, state) {
          if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message))
            );
          }
          if (state is UserAuthenticated) {
            // After registration, navigate to profile
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              TextField(
                controller: _emailCtl,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _phoneCtl,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12),
              TextField(
                controller: _passCtl,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 12),
              TextField(
                controller: _confirmCtl,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
              ),
              SizedBox(height: 24),
              BlocBuilder<UserBloc, UserState>(
                builder: (ctx, state) {
                  if (state is UserLoading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return CustomButton(
                    label: 'Register',
                    onPressed: () {
                      context.read<UserBloc>().add(
                        RegisterUser(
                          _emailCtl.text.trim(),
                          _phoneCtl.text.trim(),
                          _passCtl.text,
                          _confirmCtl.text,
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
