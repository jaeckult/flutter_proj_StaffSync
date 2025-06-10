import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'mock/auth_repository_mock.mocks.dart';
import 'package:staffsync/application/notifiers/auth.notifier.dart';
import 'package:staffsync/application/states/auth.state.dart';

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('Login', () {
    test('Initial state is UnLogged when no token is found', () async {
      when(mockAuthRepository.getToken()).thenAnswer((_) async => null);

      final authNotifier = AuthNotifier(authRepository: mockAuthRepository);
      await Future.microtask(() {}); // let async logic complete

      expect(authNotifier.state, isA<UnLogged>());
    });
    
    test('emits LoggedIn state if token and role are present in storage', () async {
      // here I was just testing the automatic login functionality
      when(mockAuthRepository.getToken()).thenAnswer((_) async => 'dummy_token');
      when(mockAuthRepository.getRole()).thenAnswer((_) async => 'admin');

      final authNotifier = AuthNotifier(authRepository: mockAuthRepository);
      await Future.delayed(Duration.zero);


      expect(authNotifier.state, isA<LoggedIn>());
      final state = authNotifier.state as LoggedIn;
      expect(state.role, 'admin');
    });

    test('state is LoggedIn when getToken returns a valid token', () async {
   
      when(mockAuthRepository.getToken()).thenAnswer((_) async => 'valid_token');
      when(mockAuthRepository.getRole()).thenAnswer((_) async => 'EMPLOYEE'); // Add this!

      final authNotifier = AuthNotifier(authRepository: mockAuthRepository);
      await Future.delayed(Duration.zero);

      expect(authNotifier.state, isA<LoggedIn>());
    });
    test('state is AuthError when logIn fails', () async {
      when(mockAuthRepository.getToken()).thenAnswer((_) async => null);
      
      when(mockAuthRepository.logIn(any, any)).thenThrow("Login failed");

      final authNotifier = AuthNotifier(authRepository: mockAuthRepository);
      await Future.delayed(Duration.zero);
     
      try {
        await authNotifier.logIn('username', 'password');
      } catch (e) {
        Exception("Login failed");

       
      }
      expect(authNotifier.state, isA<AuthError>());

    });
  });
}
