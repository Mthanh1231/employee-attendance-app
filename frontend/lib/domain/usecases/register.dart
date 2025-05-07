// lib/domain/usecases/register.dart
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class Register {
  final UserRepository repository;
  Register(this.repository);

  Future<User> call(String email, String phone, String password, String confirmPassword) async {
    return await repository.register(email, phone, password, confirmPassword);
  }
}
