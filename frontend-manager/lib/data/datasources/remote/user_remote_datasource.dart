import '../../../core/network/http_client.dart';
import '../../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getAllUsers();
  Future<UserModel> getUserById(String id);
  Future<UserModel> createUser(Map<String, dynamic> userData);
  Future<UserModel> updateUser(String id, Map<String, dynamic> userData);
  Future<void> deleteUser(String id);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final HttpClient client;

  UserRemoteDataSourceImpl({required this.client});

  @override
  Future<List<UserModel>> getAllUsers() async {
    final response = await client.get('/api/users');
    return (response['data'] as List)
        .map((user) => UserModel.fromJson(user))
        .toList();
  }

  @override
  Future<UserModel> getUserById(String id) async {
    final response = await client.get('/api/users/$id');
    return UserModel.fromJson(response['data']);
  }

  @override
  Future<UserModel> createUser(Map<String, dynamic> userData) async {
    final response = await client.post(
      '/api/users',
      body: userData,
    );
    return UserModel.fromJson(response['data']);
  }

  @override
  Future<UserModel> updateUser(String id, Map<String, dynamic> userData) async {
    final response = await client.put(
      '/api/users/$id',
      body: userData,
    );
    return UserModel.fromJson(response['data']);
  }

  @override
  Future<void> deleteUser(String id) async {
    await client.delete('/api/users/$id');
  }
}
