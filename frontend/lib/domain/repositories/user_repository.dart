// lib/domain/repositories/user_repository.dart
import '../entities/user.dart';

abstract class UserRepository {
  Future<User> register(String email, String phone, String password, String confirmPassword);
  Future<void> login(String email, String password);
  Future<User> getProfile();
}
