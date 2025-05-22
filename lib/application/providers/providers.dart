import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/application/notifiers/attendance.notifier.dart';
import 'package:staffsync/application/notifiers/leaveDashboard.notifier.dart';
import 'package:staffsync/application/notifiers/user.notifier.dart';
import 'package:staffsync/domain/model/user.model.dart';
import 'package:staffsync/domain/repositories/attendance.repository.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';
import 'package:staffsync/application/notifiers/auth.notifier.dart';
import 'package:staffsync/application/states/auth.state.dart';
import 'package:staffsync/application/states/leaveDashboard.state.dart';
import 'package:http/http.dart' as http;
import 'package:staffsync/domain/repositories/leaveDashboard.repository.dart';
import 'package:staffsync/domain/repositories/user.repository.dart';
import 'package:staffsync/infrastructure/repository/attendance.repositoryImpl.dart';
import 'package:staffsync/infrastructure/repository/auth.repositoryImpl.dart';
import 'package:staffsync/infrastructure/datasource/remote_data_source.dart';
import 'package:staffsync/infrastructure/repository/leaveDashboard.repositoryImpl.dart';
import 'package:staffsync/infrastructure/repository/user.repositoryImpl.dart';
import 'package:staffsync/infrastructure/storage/storage.dart';
import 'package:staffsync/infrastructure/datasource/leaveDashboard.remote_datasourceImpl.dart';

final httpClient = http.Client();
final remoteDataSource = RemoteDataSource(httpClient);

final authRepository = AuthRepositoryImpl(
  remoteDataSource,
  SecureStorage.instance,
);
final userRepository = UserRepositoryImpl( remoteDataSource);
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return userRepository;

});
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return authRepository;
});
final attendanceRepository = AttendanceRepositoryImpl(
  remoteDataSource,
  SecureStorage.instance,
);
final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return attendanceRepository;
});
final leaveDashboardRepository = LeaveDashboardRepositoryImpl(
  LeaveDashboardRemoteDatasourceimpl(httpClient),
  SecureStorage.instance,
);
final leaveDashboardRepositoryProvider = Provider<LeaveDashboardRepository>((ref) {
  return leaveDashboardRepository;
});
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository: authRepository);
});
final userNotifierProvider = StateNotifierProvider<UserNotifier, User?>(
  (ref) {
    final authRepository = ref.watch(authRepositoryProvider);
    final userRepository = ref.watch(userRepositoryProvider);
    return UserNotifier(authRepository, userRepository);
  },
);
final attendanceNotifierProvider = StateNotifierProvider<AttendanceNotifier, void>(
  (ref) {
    final authRepository = ref.watch(authRepositoryProvider);
    final attendanceRepository = ref.watch(attendanceRepositoryProvider);
    return AttendanceNotifier(authRepository, attendanceRepository);
  },
);
final leaveNotifierProvider = StateNotifierProvider<LeaveDashboardNotifier, LeaveDashboardState>(
  (ref) {
    final authRepository = ref.watch(authRepositoryProvider);
    final leaveDashboardRepository = ref.watch(leaveDashboardRepositoryProvider);
    return LeaveDashboardNotifier(authRepository, leaveDashboardRepository);
  },
);
