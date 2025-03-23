// lib/presentation/blocs/user/user_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_event.dart';
import 'user_state.dart';
import '../../../domain/usecases/get_all_users.dart';
import '../../../domain/usecases/login.dart';
import '../../../domain/usecases/register.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetAllUsers getAllUsersUseCase;
  final Login loginUseCase;
  final Register registerUseCase;

  UserBloc({
    required this.getAllUsersUseCase,
    required this.loginUseCase,
    required this.registerUseCase,
  }) : super(UserInitial()) {
    on<LoadAllUsers>((event, emit) async {
      emit(UserLoading());
      try {
        final users = await getAllUsersUseCase();
        emit(UserLoaded(users));
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });

    on<LoginUser>((event, emit) async {
      emit(UserLoading());
      try {
        final token = await loginUseCase(event.email, event.password);
        emit(UserLoggedIn(token));
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });

    on<RegisterUser>((event, emit) async {
      emit(UserLoading());
      try {
        await registerUseCase(event.email, event.phone, event.password);
        emit(UserRegistered());
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });
  }
}
