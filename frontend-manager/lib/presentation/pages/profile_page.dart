import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>?> fetchManagerProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) return null;

  final response = await http.get(
    Uri.parse('http://localhost:3000/api/manager/profile'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  return null;
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin cá nhân'), centerTitle: true),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchManagerProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
                child: Text('Không lấy được thông tin manager'));
          }
          final manager = snapshot.data!;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.blue.shade100,
                    child:
                        const Icon(Icons.person, size: 48, color: Colors.blue),
                  ),
                  const SizedBox(height: 24),
                  Text(manager['email']?.toString() ?? '',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('ID: ${manager['employeeId']?.toString() ?? ''}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('SĐT: ${manager['phone']?.toString() ?? ''}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(manager['role']?.toString() ?? ''),
                    backgroundColor: Colors.blue.shade50,
                    labelStyle: const TextStyle(color: Colors.blue),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Đăng xuất'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('token');
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
