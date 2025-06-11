import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:staffsync/application/providers/providers.dart';
import 'package:staffsync/presentaion/screen/login.screen.dart';
import '../mock/auth_repository_mock.mocks.dart';



@override
Future<void> connectToIO() async {}

void main() {

  testWidgets('Login button enables, disables and logs in', (tester) async {
    final mockAuthRepo = MockAuthRepository();
    

    // Stub login method
    when(mockAuthRepo.getToken()).thenAnswer((_) async => null);
    when(mockAuthRepo.logIn('validuser', 'validpass123'))
        .thenAnswer((_) async => 'EMPLOYEE');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepo),
          // authNotifierProvider.overrideWith((ref) => FakeAuthNotifier()),
        ],
        child: const MaterialApp(
          home: LoginPage(),
        ),
      ),
    );

    final loginButton = find.widgetWithText(ElevatedButton, 'Login');

    expect(tester.widget<ElevatedButton>(loginButton).onPressed, isNull);

    await tester.enterText(find.byType(TextFormField).at(0), 'validuser');
    await tester.enterText(find.byType(TextFormField).at(1), 'short');
    await tester.pump();
    expect(tester.widget<ElevatedButton>(loginButton).onPressed, isNull);

    await tester.enterText(find.byType(TextFormField).at(1), 'validpass123');
    await tester.pump();
    expect(tester.widget<ElevatedButton>(loginButton).onPressed, isNotNull);


    await tester.tap(loginButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Successfully logged in!'), findsOneWidget);
  });
}