// lib/presentation/pages/profile_page.dart

import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Giả sử ta chỉ có sẵn token sau khi đăng nhập,
    // chưa có logic lấy dữ liệu thực từ backend,
    // ta tạm để "Trống" hoặc "???"
    final email = "???"; 
    final phone = "???"; 
    final name = "Trống"; 

    return Scaffold(
      appBar: AppBar(title: const Text('Trang cá nhân')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: $email'),
            Text('Phone: $phone'),
            Text('Name: $name'),
            const SizedBox(height: 20),
            // Nút "Chỉnh sửa thông tin"
            ElevatedButton(
              onPressed: () {
                // TODO: Điều hướng hoặc mở trang sửa thông tin
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chỉnh sửa thông tin!')),
                );
              },
              child: const Text('Chỉnh sửa thông tin'),
            ),
            const SizedBox(height: 10),
            // Nút "Chấm công"
            ElevatedButton(
              onPressed: () {
                // TODO: Gọi logic chấm công (POST /api/attendance?)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chấm công!')),
                );
              },
              child: const Text('Chấm công'),
            ),
          ],
        ),
      ),
    );
  }
}
