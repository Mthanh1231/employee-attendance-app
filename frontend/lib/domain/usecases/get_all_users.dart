// lib/domain/usecases/get_all_users.dart
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class GetAllUsers {
  final UserRepository repository;

  GetAllUsers(this.repository);

  Future<List<User>> call() async {
    return await repository.getAllUsers();
  }
}
