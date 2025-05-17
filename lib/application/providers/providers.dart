import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';
import 'package:staffsync/application/notifiers/auth.notifier.dart';
import 'package:staffsync/application/states/auth.state.dart';
import 'package:http/http.dart' as http;
import 'package:staffsync/infrastructure/repository/auth.repositoryImpl.dart';
import 'package:staffsync/infrastructure/datasource/remote_data_source.dart';
import 'package:staffsync/infrastructure/storage/storage.dart';

final httpClient = http.Client();
final remoteDataSource = RemoteDataSource(httpClient);

final authRepository = AuthRepositoryImpl(
  remoteDataSource,
  SecureStorage.instance,
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return authRepository;
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository: authRepository);
});
