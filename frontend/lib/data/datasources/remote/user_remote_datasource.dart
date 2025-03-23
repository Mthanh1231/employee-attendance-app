// lib/data/datasources/remote/user_remote_datasource.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../core/error/exceptions.dart';
import '../../models/user_model.dart';

class UserRemoteDataSource {
  final http.Client client;
  final String baseUrl; // e.g. "http://10.0.2.2:3000/api"

  UserRemoteDataSource({
    required this.client,
    required this.baseUrl,
  });

  Future<List<UserModel>> getAllUsers() async {
    final response = await client.get(Uri.parse('$baseUrl/users/all'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['users'] as List;
      return data.map((e) => UserModel.fromJson(e)).toList();
    } else {
      throw ServerException('Failed to load users');
    }
  }

  Future<String> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"email": email, "password": password}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['token']; // Trả về token
    } else {
      throw ServerException('Failed to login');
    }
  }

  Future<void> register(String email, String phone, String password) async {
    final response = await client.post(
      Uri.parse('$baseUrl/users/register'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "email": email,
        "phone": phone,
        "password": password,
        "confirmPassword": password
      }),
    );
    if (response.statusCode == 201) {
      return; // Đăng ký thành công
    } else {
      throw ServerException('Failed to register');
    }
  }
}
