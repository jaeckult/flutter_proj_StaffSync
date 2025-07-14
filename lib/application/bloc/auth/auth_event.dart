import 'package:equatable/equatable.dart';

class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthAppStarted extends AuthEvent {
  const AuthAppStarted();
}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;
  const AuthLoginRequested(this.username, this.password);
  @override
  List<Object?> get props => [username, password];
}

class AuthSignupRequested extends AuthEvent {
  final String username;
  final String password;
  final String email;
  final String fullName;
  final String gender;
  final String employmentType;
  final String designation;
  final String dateOfBirth;
  final String role;
  const AuthSignupRequested({
    required this.username,
    required this.password,
    required this.email,
    required this.fullName,
    required this.gender,
    required this.employmentType,
    required this.designation,
    required this.dateOfBirth,
    required this.role,
  });
  @override
  List<Object?> get props => [username, password, email, fullName, gender, employmentType, designation, dateOfBirth, role];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthConnectIoRequested extends AuthEvent {
  const AuthConnectIoRequested();
}
