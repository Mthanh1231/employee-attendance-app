// lib/domain/entities/user.dart
class User {
  final String id;
  final String email;
  final String phone;
  final String? employeeId;

  User({
    required this.id,
    required this.email,
    required this.phone,
    this.employeeId,
  });
}