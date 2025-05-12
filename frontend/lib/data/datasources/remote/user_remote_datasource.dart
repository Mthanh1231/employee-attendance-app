// lib/data/datasources/remote/user_remote_datasource.dart
import 'dart:convert';
import 'package:flutter_attendance_clean/core/network/http_client.dart';
import 'package:flutter_attendance_clean/core/error/exceptions.dart';
import 'package:flutter_attendance_clean/data/models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> register(
      String email, String phone, String password, String confirmPassword);
  Future<UserModel> login(String email, String password);
  Future<UserModel> getProfile();
  Future<void> submitProfileUpdateRequest(Map<String, dynamic> data);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final HttpClient client;
  UserRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> register(String email, String phone, String password,
      String confirmPassword) async {
    final body = jsonEncode({
      'email': email,
      'phone': phone,
      'password': password,
      'confirmPassword': confirmPassword,
    });
    final resp = await client.post('/api/employee/register', body: body);
    if (resp.statusCode == 201) {
      final data = jsonDecode(resp.body);
      // backend chỉ trả employeeId, không có token khi đăng ký
      return UserModel(
        id: data['employeeId'] ?? '',
        email: email,
        phone: phone,
        employeeId: data['employeeId'] ?? '',
        token: '', // Đăng ký chưa có token, để rỗng
      );
    } else {
      final msg = jsonDecode(resp.body)['message'] ?? 'Unknown error';
      throw ServerException(msg);
    }
  }

  @override
  Future<UserModel> login(String email, String password) async {
    final body = jsonEncode({'email': email, 'password': password});
    final resp = await client.post('/api/employee/login', body: body);
    print('Login response: ${resp.body}');
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      // backend trả về token, email, ...
      return UserModel(
        id: data['id'] ?? '',
        email: data['email'] ?? email,
        phone: data['phone'] ?? '',
        employeeId: data['employeeId'] ?? '',
        token: data['token'] ?? '',
      );
    } else {
      final msg = jsonDecode(resp.body)['message'] ?? 'Login failed';
      throw ServerException(msg);
    }
  }

  @override
  Future<UserModel> getProfile() async {
    final resp = await client.get('/api/employee/profile');
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body)['user'];
      return UserModel.fromJson({
        ...data,
        'token': '', // token đã lưu trong HttpClient
      });
    } else {
      final msg = jsonDecode(resp.body)['message'] ?? 'Fetch profile failed';
      throw ServerException(msg);
    }
  }

  @override
  Future<void> submitProfileUpdateRequest(Map<String, dynamic> data) async {
    final body = jsonEncode(data);
    final resp =
        await client.post('/api/employee/profile-update-request', body: body);
    if (resp.statusCode != 201) {
      final msg = jsonDecode(resp.body)['message'] ??
          'Failed to submit profile update request';
      throw ServerException(msg);
    }
  }
}
