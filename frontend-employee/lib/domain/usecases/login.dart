// lib/domain/usecases/login.dart
import '../repositories/user_repository.dart';
import '../entities/user.dart';

class Login {
  final UserRepository repository;
  Login(this.repository);

  Future<User> call(String email, String password) async {
    return await repository.login(email, password);
  }
}
