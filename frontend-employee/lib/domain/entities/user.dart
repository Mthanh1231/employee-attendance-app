// lib/domain/entities/user.dart
class User {
  final String id;
  final String email;
  final String phone;
  final String? employeeId;
  final String? name;
  final String? date;
  final Map<String, dynamic>? cccdInfo;
  final String? note;
  final String? home;
  final String? place;
  final String? na;
  final String? s;
  final String? ddnd;
  final String? img;
  final String? tg;
  final String? role;
  final String? password;

  User({
    required this.id,
    required this.email,
    required this.phone,
    this.employeeId,
    this.name,
    this.date,
    this.cccdInfo,
    this.note,
    this.home,
    this.place,
    this.na,
    this.s,
    this.ddnd,
    this.img,
    this.tg,
    this.role,
    this.password,
  });
}
