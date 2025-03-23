// lib/domain/usecases/register.dart
import '../repositories/user_repository.dart';

class Register {
  final UserRepository repository;

  Register(this.repository);

  Future<void> call(String email, String phone, String password) async {
    await repository.register(email, phone, password);
  }
}
