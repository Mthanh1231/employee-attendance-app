// lib/domain/usecases/login.dart
import '../repositories/user_repository.dart';

class Login {
  final UserRepository repository;
  Login(this.repository);

  Future<void> call(String email, String password) async {
    await repository.login(email, password);
  }
}

