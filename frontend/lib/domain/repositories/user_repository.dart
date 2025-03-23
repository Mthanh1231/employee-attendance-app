// lib/domain/repositories/user_repository.dart
import '../entities/user.dart';

abstract class UserRepository {
  Future<List<User>> getAllUsers();
  Future<String> login(String email, String password);
  Future<void> register(String email, String phone, String password);
  // ...các hàm khác nếu cần (updateProfile, v.v.)
}
