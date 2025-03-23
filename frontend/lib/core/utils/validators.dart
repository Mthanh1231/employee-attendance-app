// lib/core/utils/validators.dart
class Validators {
  static bool isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }
}
