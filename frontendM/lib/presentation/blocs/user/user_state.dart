import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UsersLoaded extends UserState {
  final List<UserModel> users;

  const UsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class UserLoaded extends UserState {
  final UserModel user;

  const UserLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class UserCreated extends UserState {
  final UserModel user;

  const UserCreated(this.user);

  @override
  List<Object?> get props => [user];
}

class UserUpdated extends UserState {
  final UserModel user;

  const UserUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

class UserDeleted extends UserState {}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}
