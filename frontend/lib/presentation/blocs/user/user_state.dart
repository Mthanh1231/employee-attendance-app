// lib/presentation/blocs/user/user_state.dart
import '../../../domain/entities/user.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<User> users;
  UserLoaded(this.users);
}

class UserLoggedIn extends UserState {
  final String token;
  UserLoggedIn(this.token);
}

class UserRegistered extends UserState {}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}
