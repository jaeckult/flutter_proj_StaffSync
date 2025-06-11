import 'package:mockito/annotations.dart';
import 'package:staffsync/application/notifiers/auth.notifier.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';

// Tell mockito to generate mocks for AuthRepository
// auth_repository_mock.dart
@GenerateMocks([AuthRepository, AuthNotifier])


void main() {}
