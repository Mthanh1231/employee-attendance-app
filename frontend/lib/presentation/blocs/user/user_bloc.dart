// lib/presentation/blocs/user/user_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/login.dart';
import '../../../domain/usecases/register.dart';
import '../../../domain/repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;
  final Register registerUseCase;
  final Login loginUseCase;

  UserBloc(UserRepository repo)
      : repository = repo,
        registerUseCase = Register(repo),
        loginUseCase = Login(repo),
        super(UserInitial()) {
    // Đăng ký user mới
    on<RegisterUser>((e, emit) async {
      emit(UserLoading());
      try {
        final user = await registerUseCase(
          e.email,
          e.phone,
          e.password,
          e.confirmPassword,
        );
        emit(UserAuthenticated(user));
      } catch (ex) {
        emit(UserError(ex.toString()));
      }
    });

    // Login: lấy token rồi gọi LoadUserProfile
    on<LoginUser>((e, emit) async {
      emit(UserLoading());
      try {
        await loginUseCase(e.email, e.password);
        // token đã được set trong HttpClient
        add(LoadUserProfile());
      } catch (ex) {
        emit(UserError(ex.toString()));
      }
    });

    // Load profile thực: gọi repository.getProfile()
    on<LoadUserProfile>((_, emit) async {
      emit(UserLoading());
      try {
        final User user = await repository.getProfile();
        emit(UserAuthenticated(user));
      } catch (ex) {
        emit(UserError(ex.toString()));
      }
    });
  }
}
