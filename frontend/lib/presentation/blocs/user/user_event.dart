// lib/presentation/blocs/user/user_event.dart
import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class RegisterUser extends UserEvent {
  final String email, phone, password, confirmPassword;
  RegisterUser(this.email, this.phone, this.password, this.confirmPassword);
  @override List<Object?> get props => [email, phone, password, confirmPassword];
}

class LoginUser extends UserEvent {
  final String email, password;
  LoginUser(this.email, this.password);
  @override List<Object?> get props => [email, password];
}

class LoadUserProfile extends UserEvent {}
