import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffsync/application/bloc/auth/auth_event.dart';
import 'package:staffsync/application/bloc/auth/auth_state.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(UnLogged()) {
    on<AuthAppStarted>(_onAppStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthConnectIoRequested>(_onConnectIoRequested);
  }

  Future<void> _onAppStarted(AuthAppStarted event, Emitter<AuthState> emit) async {
    final token = await authRepository.getToken();
    if (token != null) {
      final role = await authRepository.getRole();
      emit(LoggedIn(role: role));
    }
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    try {
      final role = await authRepository.logIn(event.username, event.password);
      emit(LoggedIn(role: role));
    } catch (error) {
      final errorMessage = error.toString().contains(":")
          ? error.toString().split(":")[1].trim()
          : error.toString();
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onSignupRequested(AuthSignupRequested event, Emitter<AuthState> emit) async {
    try {
      await authRepository.signup(
        event.username,
        event.password,
        event.email,
        event.fullName,
        event.gender,
        event.employmentType,
        event.designation,
        event.dateOfBirth,
        event.role,
      );
      emit(const AuthSuccess("Successfully signed up!"));
    } catch (error) {
      emit(AuthError(error.toString()));
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await authRepository.logout();
      await authRepository.clearData();
      emit(UnLogged());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onConnectIoRequested(AuthConnectIoRequested event, Emitter<AuthState> emit) async {
    try {
      await authRepository.connectToIO();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
