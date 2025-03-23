// lib/presentation/blocs/user/user_event.dart
abstract class UserEvent {}

class LoadAllUsers extends UserEvent {}

class LoginUser extends UserEvent {
  final String email;
  final String password;
  LoginUser(this.email, this.password);
}

class RegisterUser extends UserEvent {
  final String email;
  final String phone;
  final String password;
  RegisterUser(this.email, this.phone, this.password);
}
