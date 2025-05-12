import '../../../core/network/http_client.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../models/user_model.dart';
import '../remote/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remote;
  final HttpClient httpClient;

  UserRepositoryImpl({
    required this.remote,
    required this.httpClient,
  });

  @override
  Future<List<UserModel>> getAllUsers() async {
    return await remote.getAllUsers();
  }

  @override
  Future<UserModel> getUserById(String id) async {
    return await remote.getUserById(id);
  }

  @override
  Future<UserModel> createUser(Map<String, dynamic> userData) async {
    return await remote.createUser(userData);
  }

  @override
  Future<UserModel> updateUser(String id, Map<String, dynamic> userData) async {
    return await remote.updateUser(id, userData);
  }

  @override
  Future<void> deleteUser(String id) async {
    await remote.deleteUser(id);
  }
}
