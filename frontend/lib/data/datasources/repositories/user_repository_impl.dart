// lib/data/repositories/user_repository_impl.dart
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/usecases/register.dart';
import '../../datasources/remote/user_remote_datasource.dart';
import '../../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<User>> getAllUsers() async {
    final List<UserModel> models = await remoteDataSource.getAllUsers();
    return models;
  }

  @override
  Future<String> login(String email, String password) async {
    return await remoteDataSource.login(email, password);
  }

  @override
  Future<void> register(String email, String phone, String password) async {
    await remoteDataSource.register(email, phone, password);
  }
}
