// lib/domain/usecases/get_all_users.dart
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class GetAllUsers {
  final UserRepository repository;
  GetAllUsers(this.repository);

  Future<List<User>> call() async {
    // nếu backend có endpoint getAllUsers
    // return await repository.getAllUsers();
    throw UnimplementedError();
  }
}
