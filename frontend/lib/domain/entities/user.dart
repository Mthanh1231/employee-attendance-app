// lib/domain/entities/user.dart
class User {
  final String id;
  final String email;
  final String phone;
  final String? employeeId;

  const User({
    required this.id,
    required this.email,
    required this.phone,
    this.employeeId,
  });
}
