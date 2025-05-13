// lib/data/models/user_model.dart

import 'package:flutter_attendance_clean/domain/entities/user.dart';

class UserModel extends User {
  final String token;

  UserModel({
    required String id,
    required String email,
    required String phone,
    String? employeeId,
    String? name,
    String? date,
    Map<String, dynamic>? cccdInfo,
    String? note,
    String? home,
    String? place,
    String? na,
    String? s,
    String? ddnd,
    String? img,
    String? tg,
    String? role,
    String? password,
    required this.token,
  }) : super(
          id: id,
          email: email,
          phone: phone,
          employeeId: employeeId,
          name: name,
          date: date,
          cccdInfo: cccdInfo,
          note: note,
          home: home,
          place: place,
          na: na,
          s: s,
          ddnd: ddnd,
          img: img,
          tg: tg,
          role: role,
          password: password,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['appId'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      employeeId: json['employeeId']?.toString(),
      name: json['cccd_name']?.toString() ?? json['name']?.toString(),
      date: json['date']?.toString(),
      cccdInfo: json['cccd_info'],
      note: json['note']?.toString(),
      home: json['home']?.toString(),
      place: json['place']?.toString(),
      na: json['na']?.toString(),
      s: json['s']?.toString(),
      ddnd: json['ddnd']?.toString(),
      img: json['img']?.toString(),
      tg: json['tg']?.toString(),
      role: json['role']?.toString(),
      password: json['password']?.toString(),
      token: (json['token'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      if (employeeId != null) 'employeeId': employeeId,
      if (name != null) 'name': name,
      if (date != null) 'date': date,
      if (cccdInfo != null) 'cccd_info': cccdInfo,
      if (note != null) 'note': note,
      if (home != null) 'home': home,
      if (place != null) 'place': place,
      if (na != null) 'na': na,
      if (s != null) 's': s,
      if (ddnd != null) 'ddnd': ddnd,
      if (img != null) 'img': img,
      if (tg != null) 'tg': tg,
      if (role != null) 'role': role,
      if (password != null) 'password': password,
      'token': token,
    };
  }
}
