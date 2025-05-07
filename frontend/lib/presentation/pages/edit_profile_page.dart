// lib/presentation/pages/edit_profile_page.dart

import 'dart:io' as io;                    // chỉ dùng trên mobile/desktop
import 'package:flutter/foundation.dart'; // để dùng kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_attendance_clean/presentation/blocs/user/user_bloc.dart';
import 'package:flutter_attendance_clean/presentation/blocs/user/user_state.dart';

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
  io.File? _frontFile;
  io.File? _backFile;

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
        else _backBytes = bytes;
      });
    } else {
      // Mobile/Desktop: dùng File
      final file = io.File(picked.path);
      setState(() {
        if (isFront) _frontFile = file;
        else _backFile = file;
      });
    }
  }

  Widget _buildImageCard({
    required Uint8List? bytes,
    required io.File? file,
    required String title,
    required VoidCallback onCapture,
  }) {
    final imagePreview = Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      clipBehavior: Clip.antiAlias,
      child: kIsWeb
          ? (bytes != null
              ? Image.memory(bytes, fit: BoxFit.cover)
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey[400]),
                      SizedBox(height: 8),
                      Text(
                        'No image captured',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ))
          : (file != null
              ? Image.file(file, fit: BoxFit.cover)
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey[400]),
                      SizedBox(height: 8),
                      Text(
                        'No image captured',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        imagePreview,
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: Icon(Icons.camera_alt_outlined),
            label: Text('Capture Image'),
            onPressed: onCapture,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        centerTitle: true,
      ),
      body: BlocListener<UserBloc, UserState>(
        listener: (ctx, state) {
          if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is UserAuthenticated) {
            Navigator.pop(context);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Avatar Section
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextButton.icon(
                          icon: Icon(Icons.photo_camera),
                          label: Text('Change Photo'),
                          onPressed: () {
                            // TODO: Implement profile photo change
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Basic Information Section
                  Text(
                    'Basic Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Form Fields with improved styling
                  _buildTextField(
                    controller: _emailCtl,
                    label: 'Email Address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneCtl,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  
                  SizedBox(height: 32),
                  
                  // ID Document Section
                  Text(
                    'ID Document',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Front ID Card
                  _buildImageCard(
                    bytes: _frontBytes,
                    file: _frontFile,
                    title: 'CCCD Front Side',
                    onCapture: () => _pickImage(true),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Back ID Card
                  _buildImageCard(
                    bytes: _backBytes,
                    file: _backFile,
                    title: 'CCCD Back Side',
                    onCapture: () => _pickImage(false),
                  ),
                  
                  SizedBox(height: 40),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: dispatch event UpdateProfile với _emailCtl.text,
                        // _phoneCtl.text, và cả bytes/file tương ứng
                        // ex: context.read<UserBloc>().add(UpdateProfile(...));
                      },
                      child: Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}