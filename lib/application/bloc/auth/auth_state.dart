import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class UnLogged extends AuthState {
  const UnLogged();
}

class LoggedIn extends AuthState {
  final String? role;
  const LoggedIn({this.role});

  @override
  List<Object?> get props => [role];
}
class AuthSuccess extends AuthState {
  final String message;
  const AuthSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
