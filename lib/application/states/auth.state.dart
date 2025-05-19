//this is where the auth states goes

abstract class AuthState {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class UnLogged extends AuthState {}

class LoggedIn extends AuthState {
  final String? role;

  const LoggedIn({required this.role});

  @override
  List<Object?> get props => [role];
}



class AuthError extends AuthState {
  final String error;

  const AuthError(this.error);

  @override
  List<Object?> get props => [error];
}

class AuthSuccess extends AuthState {
  final String success;

  const AuthSuccess(this.success);

  @override
  List<Object?> get props => [success];
}
