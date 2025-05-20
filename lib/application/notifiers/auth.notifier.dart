import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';
import 'package:staffsync/application/states/auth.state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;

  AuthNotifier({required this.authRepository}) : super(UnLogged()) {
    _automaticLogIn();
  }

  Future<void> _automaticLogIn() async {
    final token = await authRepository.getToken();
    if (token != null) {
      final role = await authRepository.getRole();
      state = LoggedIn(role: role!);
    }
  }

  Future<void> logIn(String username, String password) async {
    try {
      final loggedInRole = await authRepository.logIn(username, password);
      state = LoggedIn(role: loggedInRole);
    } catch (error) {
      state = AuthError(error.toString().split(":")[1]);
    }
  }

  // username,
  //   password,
  //   email,
  //   fullName,
  //   gender,
  //   employmentType,
  //   designation,
  //   dateOfBirth,
  //   role
  Future<void> signup(
    String username,
    String password,
    String email,
    String fullName,
    String gender,
    String employmentType,
    String designation,
    String dateOfBirth,
    String role,
  ) async {
    try {
      print("hello signup in notifier");
      await authRepository.signup(
        username,
        password,
        email,
        fullName,
        gender,
        employmentType,
        designation,
        dateOfBirth,
        role,
      );
      state = const AuthSuccess("Successfully signed up!");
    } catch (error) {
      state = AuthError(error.toString());
    }
  }
}
