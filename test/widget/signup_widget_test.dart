import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:staffsync/application/notifiers/auth.notifier.dart';
import 'package:staffsync/application/providers/providers.dart';
import 'package:staffsync/presentaion/screen/signup.screen.dart';
import 'package:staffsync/application/providers/providers.dart';
import '../mock/auth_repository_mock.mocks.dart';



void main() {
  late MockAuthNotifier mockAuthNotifier;
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockAuthNotifier = MockAuthNotifier();
    mockAuthRepo = MockAuthRepository();
   

  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepo),
        authNotifierProvider.overrideWith((ref) => mockAuthNotifier),

      ],
      child: MaterialApp.router(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => const SignupScreen(),
            ),
            GoRoute(
              path: '/login',
              builder: (_, __) => const Scaffold(body: Text('Login Page')),
            ),
          ],
        ),
      ),
    );
  }

  testWidgets('SignupScreen shows validation errors and submits when valid',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Wait for initial rendering
        await tester.pumpAndSettle();

        // Check step 1 fields exist
        expect(find.text('Username'), findsOneWidget);
        expect(find.text('Login'), findsOneWidget);
       


        // Fill out step 1 and go to step 2
        await tester.enterText(find.byType(TextFormField).at(0), 'testuser');
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');
        await tester.enterText(find.byType(TextFormField).at(2), 'test@example.com');
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        // Fill out step 2
        await tester.enterText(find.byType(TextFormField).at(0), 'Test User');

        // Set a date
        await tester.tap(find.byIcon(Icons.calendar_today));
        await tester.pumpAndSettle();
        await tester.tap(find.text('15')); 
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

    
        await tester.enterText(find.byType(TextFormField).at(0), 'Developer');

//       when(() => mockAuthNotifier.signup(
//   any, any, any, any, any, any, any, any, any
// )).thenAnswer(() async => Future<void>.value());


        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        verify(() => mockAuthNotifier.signup(
          'testuser',
          'password123',
          'test@example.com',
          'Test User',
          'MALE',
          'PERMANENT',
          'Developer',
          any, // Date in ISO8601
          'EMPLOYEE',
        )).called(1);

        expect(find.text('Login Page'), findsOneWidget);
      });
}