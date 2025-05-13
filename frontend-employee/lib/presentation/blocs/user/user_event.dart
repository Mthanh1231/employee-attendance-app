// lib/presentation/blocs/user/user_event.dart
import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class RegisterUser extends UserEvent {
  final String email, phone, password, confirmPassword;
  RegisterUser(this.email, this.phone, this.password, this.confirmPassword);
  @override
  List<Object?> get props => [email, phone, password, confirmPassword];
}

class LoginUser extends UserEvent {
  final String email, password;
  LoginUser(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class LoadUserProfile extends UserEvent {}

class UpdateProfileRequest extends UserEvent {
  final String email;
  final String phone;
  final String note;
  final Map<String, dynamic>? cccdInfo;

  UpdateProfileRequest({
    required this.email,
    required this.phone,
    required this.note,
    this.cccdInfo,
  });

  @override
  List<Object?> get props => [email, phone, note, cccdInfo];
}
