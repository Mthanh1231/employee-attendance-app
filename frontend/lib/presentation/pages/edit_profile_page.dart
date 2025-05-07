// lib/presentation/pages/edit_profile_page.dart

import 'dart:typed_data';
import 'dart:io' as io;                    // chỉ dùng trên mobile/desktop
import 'package:flutter/foundation.dart'; // để dùng kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_attendance_clean/presentation/blocs/user/user_bloc.dart';
import 'package:flutter_attendance_clean/presentation/blocs/user/user_event.dart';
import 'package:flutter_attendance_clean/presentation/blocs/user/user_state.dart';

import '../widgets/custom_button.dart';

class EditProfilePage extends StatefulWidget {
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _emailCtl = TextEditingController();
  final _phoneCtl = TextEditingController();

  // Trên web lưu bytes, trên mobile lưu File
  Uint8List? _frontBytes;
  Uint8List? _backBytes;
  io.File?     _frontFile;
  io.File?     _backFile;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Prefill email & phone nếu đã load profile
    final state = context.read<UserBloc>().state;
    if (state is UserAuthenticated) {
      _emailCtl.text = state.user.email;
      _phoneCtl.text = state.user.phone;
    }
  }

  Future<void> _pickImage(bool isFront) async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;

    if (kIsWeb) {
      // Web: đọc ra Uint8List
      final bytes = await picked.readAsBytes();
      setState(() {
        if (isFront) _frontBytes = bytes;
        else         _backBytes  = bytes;
      });
    } else {
      // Mobile/Desktop: dùng File
      final file = io.File(picked.path);
      setState(() {
        if (isFront) _frontFile = file;
        else         _backFile  = file;
      });
    }
  }

  Widget _buildPreview({required Uint8List? bytes, required io.File? file}) {
    if (kIsWeb) {
      return bytes != null
          ? Image.memory(bytes, height: 120, fit: BoxFit.cover)
          : const Placeholder(fallbackHeight: 120);
    } else {
      return file != null
          ? Image.file(file, height: 120, fit: BoxFit.cover)
          : const Placeholder(fallbackHeight: 120);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: BlocListener<UserBloc, UserState>(
        listener: (ctx, state) {
          if (state is UserError) {
            ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is UserAuthenticated) {
            Navigator.pop(context);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              TextField(
                controller: _emailCtl,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneCtl,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              const Text('Scan CCCD Front:'),
              const SizedBox(height: 8),
              _buildPreview(bytes: _frontBytes, file: _frontFile),
              const SizedBox(height: 8),
              CustomButton(
                label: 'Capture Front',
                onPressed: () => _pickImage(true),
              ),
              const SizedBox(height: 24),

              const Text('Scan CCCD Back:'),
              const SizedBox(height: 8),
              _buildPreview(bytes: _backBytes, file: _backFile),
              const SizedBox(height: 8),
              CustomButton(
                label: 'Capture Back',
                onPressed: () => _pickImage(false),
              ),
              const SizedBox(height: 24),

              CustomButton(
                label: 'Save Changes',
                onPressed: () {
                  // TODO: dispatch event UpdateProfile với _emailCtl.text,
                  // _phoneCtl.text, và cả bytes/file tương ứng
                  // ex: context.read<UserBloc>().add(UpdateProfile(...));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
