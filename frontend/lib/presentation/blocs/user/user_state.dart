// lib/presentation/blocs/user/user_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserAuthenticated extends UserState {
  final User user;
  UserAuthenticated(this.user);
  @override List<Object?> get props => [user];
}

class UserUnauthenticated extends UserState {}

class UserError extends UserState {
  final String message;
  UserError(this.message);
  @override List<Object?> get props => [message];
}
