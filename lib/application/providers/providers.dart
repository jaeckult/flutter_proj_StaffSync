import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/application/notifiers/user.notifier.dart';
import 'package:staffsync/domain/model/user.model.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';
import 'package:staffsync/application/notifiers/auth.notifier.dart';
import 'package:staffsync/application/states/auth.state.dart';
import 'package:http/http.dart' as http;
import 'package:staffsync/domain/repositories/user.repository.dart';
import 'package:staffsync/infrastructure/repository/auth.repositoryImpl.dart';
import 'package:staffsync/infrastructure/datasource/remote_data_source.dart';
import 'package:staffsync/infrastructure/repository/user.repositoryImpl.dart';
import 'package:staffsync/infrastructure/storage/storage.dart';

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

