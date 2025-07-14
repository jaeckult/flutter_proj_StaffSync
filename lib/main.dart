import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:staffsync/presentaion/screen/change.password.dart';
import 'package:staffsync/presentaion/screen/edit.profile.dart';
import 'package:staffsync/presentaion/screen/employee.dart';
// import 'package:staffsync/presentaion/screen/employee.home.dart';
import 'package:staffsync/presentaion/screen/employee.profileScreen.dart';
import 'package:staffsync/presentaion/screen/employee.scheduleScreen.dart';
import 'package:staffsync/presentaion/screen/employee.collegues.Screen.dart';
import 'package:staffsync/presentaion/screen/employee.holidayScreen.dart';
import 'package:staffsync/presentaion/screen/manager.dart';
// import 'package:staffsync/presentaion/screen/managerHome.dart';
import 'package:staffsync/presentaion/screen/managerDashboard.dart';
import 'package:staffsync/presentaion/screen/managerHoliday.dart';
import 'package:staffsync/presentaion/screen/managerColleagues.dart';
import 'package:staffsync/presentaion/screen/notification.screen.dart';
import 'package:staffsync/presentaion/screen/notification.setting.dart';
import './presentaion/screen/login.screen.dart';
import './presentaion/screen/signup.screen.dart';
import 'package:inspector/inspector.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:dio/dio.dart';
import 'package:staffsync/application/bloc/auth/auth_bloc.dart';
import 'package:staffsync/application/bloc/auth/auth_event.dart';
import 'package:staffsync/application/bloc/attendance/attendance_bloc.dart';
import 'package:staffsync/application/bloc/attendance/attendance_event.dart';
import 'package:staffsync/application/bloc/holiday/holiday_bloc.dart';
import 'package:staffsync/application/bloc/holiday/holiday_event.dart';
import 'package:staffsync/application/bloc/leave_dashboard/leave_dashboard_bloc.dart';
// Removed unused event import
import 'package:staffsync/application/bloc/leave_request/leave_request_bloc.dart';
// Removed unused event import
import 'package:staffsync/application/bloc/manager_dashboard/manager_dashboard_bloc.dart';
// Removed unused event import
import 'package:staffsync/application/bloc/user/user_cubit.dart';
import 'package:staffsync/application/bloc/bulk_user/bulk_user_cubit.dart';
import 'package:staffsync/application/bloc/setting/setting_cubit.dart';
import 'package:staffsync/infrastructure/datasource/remote_data_source.dart';
import 'package:staffsync/infrastructure/datasource/attendance.remote_datasourceImpl.dart';
import 'package:staffsync/infrastructure/datasource/leaveDashboard.remote_datasourceImpl.dart';
import 'package:staffsync/infrastructure/datasource/leaveRequest.remote_datasource.dart';
import 'package:staffsync/infrastructure/datasource/managerDashboard.remote_datasource.dart';
import 'package:staffsync/infrastructure/repository/managerDashboard.repositoryImpl.dart';
import 'package:staffsync/domain/repositories/managerDashboard.repository.dart';
import 'package:staffsync/infrastructure/repository/auth.repositoryImpl.dart';
import 'package:staffsync/infrastructure/repository/user.repositoryImpl.dart';
import 'package:staffsync/infrastructure/repository/attendance.repositoryImpl.dart';
import 'package:staffsync/infrastructure/repository/leaveDashboard.repositoryImpl.dart';
import 'package:staffsync/infrastructure/repository/leaveRequest.repositoryImpl.dart';
import 'package:staffsync/infrastructure/repository/holiday.repository.dart' as holiday_repo_impl;
import 'package:staffsync/domain/repositories/auth.repository.dart';
import 'package:staffsync/domain/repositories/user.repository.dart';
import 'package:staffsync/domain/repositories/attendance.repository.dart';
import 'package:staffsync/domain/repositories/leaveDashboard.repository.dart';
import 'package:staffsync/domain/repositories/leaveRequest.repository.dart';
import 'package:staffsync/domain/repositories/holiday.repository.dart';
import 'package:staffsync/infrastructure/storage/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone database
  tz.initializeTimeZones();
  final String timeZoneName = await _getLocalTimeZone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
  
  runApp(
    MultiRepositoryProvider(
      providers: [
        // Core singletons
        RepositoryProvider<Dio>(create: (_) => Dio()),
        RepositoryProvider<RemoteDataSource>(
          create: (ctx) => RemoteDataSource(RepositoryProvider.of<Dio>(ctx)),
        ),
        // Domain repositories
        RepositoryProvider<AuthRepository>(
          create: (ctx) => AuthRepositoryImpl(
            RepositoryProvider.of<RemoteDataSource>(ctx),
            SecureStorage.instance,
          ),
        ),
        RepositoryProvider<UserRepository>(
          create: (ctx) => UserRepositoryImpl(
            RepositoryProvider.of<RemoteDataSource>(ctx),
            SecureStorage.instance,
          ),
        ),
        RepositoryProvider<AttendanceRepository>(
          create: (ctx) => AttendanceRepositoryImpl(
            AttendanceRemoteDatasourceImpl(RepositoryProvider.of<Dio>(ctx)),
            SecureStorage.instance,
          ),
        ),
        RepositoryProvider<LeaveDashboardRepository>(
          create: (ctx) => LeaveDashboardRepositoryImpl(
            LeaveDashboardRemoteDatasourceImpl(RepositoryProvider.of<Dio>(ctx)),
            SecureStorage.instance,
          ),
        ),
        RepositoryProvider<LeaveRequestRepository>(
          create: (ctx) => LeaveRequestRepositoryImpl(
            LeaveRequestRemoteDatasourceImpl(RepositoryProvider.of<Dio>(ctx)),
            SecureStorage.instance,
          ),
        ),
        RepositoryProvider<HolidayRepository>(
          create: (ctx) => holiday_repo_impl.HolidayRepositoryImpl(
            RepositoryProvider.of<RemoteDataSource>(ctx),
            SecureStorage.instance,
          ),
        ),
        // ManagerDashboard repository
        RepositoryProvider<ManagerdashboardRepository>(
          create: (ctx) => ManagerDashboardRepositoryImpl(
            ManagerDashboardRemoteDatasourceImpl(RepositoryProvider.of<Dio>(ctx)),
            SecureStorage.instance,
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: RepositoryProvider.of<AuthRepository>(context),
            )
              ..add(const AuthAppStarted()),
          ),
          BlocProvider<AttendanceBloc>(
            create: (context) => AttendanceBloc(
              authRepository: RepositoryProvider.of<AuthRepository>(context),
              attendanceRepository: RepositoryProvider.of<AttendanceRepository>(context),
            )..add(const AttendanceFetchRequested()),
          ),
          BlocProvider<LeaveDashboardBloc>(
            create: (context) => LeaveDashboardBloc(
              authRepository: RepositoryProvider.of<AuthRepository>(context),
              leaveDashboardRepository: RepositoryProvider.of<LeaveDashboardRepository>(context),
            ),
          ),
          BlocProvider<LeaveRequestBloc>(
            create: (context) => LeaveRequestBloc(
              authRepository: RepositoryProvider.of<AuthRepository>(context),
              leaveRequestRepository: RepositoryProvider.of<LeaveRequestRepository>(context),
            ),
          ),
          BlocProvider<ManagerDashboardBloc>(
            create: (context) => ManagerDashboardBloc(
              authRepository: RepositoryProvider.of<AuthRepository>(context),
              managerDashboardRepository: RepositoryProvider.of<ManagerdashboardRepository>(context),
            ),
          ),
          BlocProvider<HolidayBloc>(
            create: (context) => HolidayBloc(
              holidayRepository: RepositoryProvider.of<HolidayRepository>(context),
            )
              ..add(const HolidayFetchRequested()),
          ),
          BlocProvider<UserCubit>(
            create: (context) => UserCubit(
              authRepository: RepositoryProvider.of<AuthRepository>(context),
              userRepository: RepositoryProvider.of<UserRepository>(context),
            ),
          ),
          BlocProvider<BulkUserCubit>(
            create: (context) => BulkUserCubit(
              authRepository: RepositoryProvider.of<AuthRepository>(context),
              userRepository: RepositoryProvider.of<UserRepository>(context),
            ),
          ),
          BlocProvider<SettingCubit>(
            create: (context) => SettingCubit(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/login', 
        builder: (context, state) => const LoginPage()
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/setting',
        builder: (context, state) => const NotificationSetting(),
      ),
      GoRoute(
        path: '/changePassword',
        builder: (context, state) => const ChangePassword(),
      ),
      GoRoute(
        path: '/editProfile',
        builder: (context, state) => const EditProfile(),
      ),
      GoRoute(
        path: '/notification',
        builder: (context, state) => NotificationList(),
      ),
      // Employee section
      GoRoute(
        path: '/employee/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/employee/schedule',
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: '/employee/colleagues',
        builder: (context, state) => const EmployeeListScreen(),
      ),
      GoRoute(
        path: '/employee/holiday',
        builder: (context, state) => const EmployeeHolidayScreen(),
      ),
      // Manager section
      GoRoute(
        path: '/manager/dashboard',
        builder: (context, state) => const ManagerScheduleScreen(),
      ),
      GoRoute(
        path: '/manager/holiday',
        builder: (context, state) => const ManagerHolidayScreen(),
      ),
      GoRoute(
        path: '/manager/colleagues',
        builder: (context, state) => const ManagerListScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return navigationShell;
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/employee/home',
                builder: (context, state) => const EmployeeLogic(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/manager/home',
                builder: (context, state) => const ManagerLogic(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.orange);

    return MaterialApp.router(
      title: 'StaffSync',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme().apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
      ),
      builder: (context, child) => Inspector(child: child!),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
  
}


// Helper function to get local timezone
// You can customize this based on your needs
Future<String> _getLocalTimeZone() async {
  // Get the system's timezone offset
  final now = DateTime.now();
  final offsetInHours = now.timeZoneOffset.inHours;
  
  // Map common offsets to timezone names
  // You can expand this based on your target regions
  final timezoneMap = {
    3: 'Africa/Nairobi',      // UTC+3 (East Africa Time - Kenya, Ethiopia, Tanzania)
    2: 'Africa/Cairo',         // UTC+2 (Egypt, South Africa)
    1: 'Africa/Lagos',         // UTC+1 (West Africa - Nigeria, Ghana)
    0: 'UTC',                  // UTC+0
    -5: 'America/New_York',    // UTC-5 (EST)
    -6: 'America/Chicago',     // UTC-6 (CST)
    -7: 'America/Denver',      // UTC-7 (MST)
    -8: 'America/Los_Angeles', // UTC-8 (PST)
  };
  
  return timezoneMap[offsetInHours] ?? 'UTC';
}
