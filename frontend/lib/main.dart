// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'core/network/http_client.dart';
import 'data/datasources/remote/user_remote_datasource.dart';
import 'data/datasources/repositories/user_repository_impl.dart';
import 'domain/usecases/get_all_users.dart';
import 'domain/usecases/login.dart';
import 'domain/usecases/register.dart';
import 'presentation/blocs/user/user_bloc.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/pages/profile_page.dart'; // import mới
import 'presentation/blocs/user/user_event.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userRemoteDataSource = UserRemoteDataSource(
      client: AppHttpClient.client,
      baseUrl: 'http://localhost:3000/api',
    );
    final userRepository = UserRepositoryImpl(remoteDataSource: userRemoteDataSource);

    final getAllUsersUseCase = GetAllUsers(userRepository);
    final loginUseCase = Login(userRepository);
    final registerUseCase = Register(userRepository);

    final userBloc = UserBloc(
      getAllUsersUseCase: getAllUsersUseCase,
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
    );

    return MaterialApp(
      title: 'Flutter Attendance Clean',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (_) => userBloc,
        child: const LoginPage(),
      ),
      routes: {
        '/login': (_) => BlocProvider.value(
              value: userBloc,
              child: const LoginPage(),
            ),
        '/register': (_) => BlocProvider.value(
              value: userBloc,
              child: const RegisterPage(),
            ),
        '/profile': (_) => BlocProvider.value(
              value: userBloc,
              child: const ProfilePage(),
            ),
      },
    );
  }
}
