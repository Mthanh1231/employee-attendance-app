// lib/data/datasources/repositories/user_repository_impl.dart

import 'dart:async';
import 'package:flutter_attendance_clean/core/network/http_client.dart';
import 'package:flutter_attendance_clean/data/datasources/remote/user_remote_datasource.dart';
import 'package:flutter_attendance_clean/data/models/user_model.dart';
import 'package:flutter_attendance_clean/domain/entities/user.dart';
import 'package:flutter_attendance_clean/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remote;
  final HttpClient httpClient;

  UserRepositoryImpl({required this.remote, required this.httpClient});

  @override
  Future<User> register(String email, String phone, String password, String confirmPassword) async {
    final userModel = await remote.register(email, phone, password, confirmPassword);
    httpClient.setToken(userModel.token);
    return userModel;
  }

  @override
  Future<void> login(String email, String password) async {
    final token = await remote.login(email, password);
    httpClient.setToken(token);
  }

  @override
  Future<User> getProfile() async {
    return await remote.getProfile();
  }
}