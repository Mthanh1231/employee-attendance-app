//lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/network/http_client.dart';
import 'data/datasources/remote/user_remote_datasource.dart';
import 'data/datasources/remote/attendance_remote_datasource.dart';

import 'data/datasources/repositories/user_repository_impl.dart';
import 'data/datasources/repositories/attendance_repository_impl.dart';


import 'presentation/blocs/user/user_bloc.dart';
import 'presentation/blocs/attendance/attendance_bloc.dart';

import 'presentation/pages/login_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/pages/edit_profile_page.dart';
import 'presentation/pages/attendance_page.dart';
import 'presentation/pages/attendance_history_page.dart';
import 'presentation/pages/user_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();  // loads "./.env"
  
  final httpClient = HttpClient();
  final userRemote = UserRemoteDataSourceImpl(client: httpClient);
  final userRepo   = UserRepositoryImpl(remote: userRemote, httpClient: httpClient);
  final attnRemote = AttendanceRemoteDataSourceImpl(client: httpClient);
  final attnRepo   = AttendanceRepositoryImpl(remote: attnRemote);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => UserBloc(userRepo)),
        BlocProvider(create: (_) => AttendanceBloc(attnRepo)),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FULLER Attendance',
      initialRoute: '/login',
      routes: {
        '/login': (_) => LoginPage(),
        '/register': (_) => RegisterPage(),
        '/profile': (_) => ProfilePage(),
        '/edit-profile': (_) => EditProfilePage(),
        '/attendance': (_) => AttendancePage(),
        '/attendance-history': (_) => AttendanceHistoryPage(),
        '/user-list': (_) => UserListPage(),
      },
    );
  }
}
