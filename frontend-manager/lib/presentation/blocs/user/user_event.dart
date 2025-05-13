import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsers extends UserEvent {}

class LoadUserById extends UserEvent {
  final String id;

  const LoadUserById(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateUser extends UserEvent {
  final Map<String, dynamic> userData;

  const CreateUser(this.userData);

  @override
  List<Object?> get props => [userData];
}

class UpdateUser extends UserEvent {
  final String id;
  final Map<String, dynamic> userData;

  const UpdateUser(this.id, this.userData);

  @override
  List<Object?> get props => [id, userData];
}

class DeleteUser extends UserEvent {
  final String id;

  const DeleteUser(this.id);

  @override
  List<Object?> get props => [id];
}
