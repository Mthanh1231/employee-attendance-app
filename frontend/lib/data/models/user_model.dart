// lib/data/models/user_model.dart

import 'package:flutter_attendance_clean/domain/entities/user.dart';

class UserModel extends User {
  final String token;

  UserModel({
    required String id,
    required String email,
    required String phone,
    String? employeeId,
    required this.token,
  }) : super(id: id, email: email, phone: phone, employeeId: employeeId);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      employeeId: json['employeeId'] as String?,
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      if (employeeId != null) 'employeeId': employeeId,
      'token': token,
    };
  }
}
