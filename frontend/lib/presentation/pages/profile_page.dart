import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Biến quản lý trạng thái checkin/checkout
  bool isCheckedIn = false;

  // Các biến để hiển thị thông tin user
  String email = '';
  String phone = '';
  String name = ''; // Nếu bạn có field "name" trong DB
  Map<String, dynamic> cccdInfo = {}; // Lưu các trường place, date, home, ...

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  // Lấy token từ UserBloc (đã login)
  Future<String?> _getToken() async {
    final userBloc = context.read<UserBloc>();
    final userState = userBloc.state;
    if (userState is UserLoggedIn) {
      return userState.token; // token JWT
    }
    return null;
  }

  // Gọi API lấy thông tin user: GET /api/users/profile
  Future<void> _fetchProfile() async {
    final token = await _getToken();
    if (token == null) {
      // Chưa đăng nhập
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/users/profile'), 
        headers: {
          'Authorization': token,
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = data['user']; // { email, phone, cccd_info, ... }
        setState(() {
          email = user['email'] ?? '';
          phone = user['phone'] ?? '';
          name = user['name'] ?? 'Trống'; // Nếu DB có field "name"
          cccdInfo = user['cccd_info'] ?? {};
        });
      } else {
        debugPrint('Lỗi khi fetch profile: ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception khi fetch profile: $e');
    }
  }

  // Hàm checkin/checkout
  Future<void> _onCheckInOut() async {
    final token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn chưa đăng nhập!')),
      );
      return;
    }

    // Xác định status
    final status = isCheckedIn ? 'checkout' : 'checkin';
    final now = DateTime.now();
    final timeString = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/attendance'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final msg = '${data['message']}\nThời gian: $timeString';

        // Hiển thị popup
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            content: Text(msg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        // Đổi trạng thái nút
        setState(() {
          isCheckedIn = !isCheckedIn;
        });
      } else {
        final data = json.decode(response.body);
        final errMsg = data['message'] ?? 'Lỗi không xác định';
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Lỗi'),
            content: Text(errMsg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Lỗi mạng
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Lỗi'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy các trường CCCD
    final place = cccdInfo['place'] ?? 'Trống';
    final date = cccdInfo['date'] ?? 'Trống';
    final home = cccdInfo['home'] ?? 'Trống';
    // ... cccd_name, na, id, s, ddnd, tg nếu có

    return Scaffold(
      appBar: AppBar(title: const Text('Trang cá nhân')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: $email'),
            Text('Phone: $phone'),
            Text('Name: $name'),
            const SizedBox(height: 10),
            // Thông tin CCCD
            Text('CCCD - place: $place'),
            Text('CCCD - date: $date'),
            Text('CCCD - home: $home'),
            // ... hiển thị các trường cccd_info khác nếu cần
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Chỉnh sửa thông tin
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chỉnh sửa thông tin!')),
                );
              },
              child: const Text('Chỉnh sửa thông tin'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _onCheckInOut,
              child: Text(isCheckedIn ? 'Chấm out' : 'Chấm công'),
            ),
          ],
        ),
      ),
    );
  }
}
