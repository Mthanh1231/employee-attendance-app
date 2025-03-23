// lib/domain/usecases/login.dart
import '../repositories/user_repository.dart';

class Login {
  final UserRepository repository;

  Login(this.repository);

  Future<String> call(String email, String password) async {
    return repository.login(email, password);
  }
}
