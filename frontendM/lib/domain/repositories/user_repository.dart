import '../../data/models/user_model.dart';

abstract class UserRepository {
  Future<List<UserModel>> getAllUsers();
  Future<UserModel> getUserById(String id);
  Future<UserModel> createUser(Map<String, dynamic> userData);
  Future<UserModel> updateUser(String id, Map<String, dynamic> userData);
  Future<void> deleteUser(String id);
}
