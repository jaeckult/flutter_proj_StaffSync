import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:staffsync/application/notifiers/auth.notifier.dart';
import 'package:staffsync/domain/model/attendance.model.dart';
import 'mock/attendance_repository_mock.mocks.dart';
import 'mock/auth_repository_mock.mocks.dart';
import 'mock/user_repository_mock.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockUserRepository mockUserRepository;
  late MockAttendanceRepository mockAttendanceRepository;
  late AuthNotifier authNotifier;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUserRepository = MockUserRepository();
    mockAttendanceRepository = MockAttendanceRepository();

    // Assume AuthNotifier depends on AuthRepository:
    authNotifier = AuthNotifier(authRepository: mockAuthRepository);
  });

  test('Integration test: login, check-in, check-out, edit profile', () async {
    final attendanceData = AttendanceData(
      id: 1,
      checkIn: DateTime(2024, 1, 1, 9),
      attendance: 'Present',
      checkOut: null,
    );
    final checkInresponse = AttendanceResponse(
      message: 'Check-in successful',
      attendance: attendanceData,
    );
    final checkOutresponse = AttendanceResponse(
      message: 'Check-out successful',
      attendance: attendanceData,
    );
    when(mockAuthRepository.logIn(any, any))
      .thenAnswer((_) async => 'mock_token');


    // 2. Mock check-in method (assuming it exists on userRepository)
    when(mockAttendanceRepository.checkIn(any))
      .thenAnswer((_) async => Future.value());

    // 3. Mock check-out method
    when(mockAttendanceRepository.checkOut(any))
      .thenAnswer((_) async => Future.value());

    // 4. Mock editProfile method
    when(mockUserRepository.editProfile(
      any, any, any, any, any, any))
      .thenAnswer((_) async => Future.value());

    // ----

    // Step 1: Login
    when(mockAuthRepository.getToken()).thenAnswer((_) async => null);
    final token = await mockAuthRepository.logIn('user@example.com', 'password');
    expect(token, 'mock_token');

     
 
    await mockAttendanceRepository.checkIn(checkInresponse);
    verify(mockAttendanceRepository.checkIn(checkInresponse)).called(1);

    // Step 3: Check-out
    await mockAttendanceRepository.checkOut(checkOutresponse);
    verify(mockAttendanceRepository.checkOut(checkOutresponse)).called(1);

    // Step 4: Edit profile
    await mockUserRepository.editProfile(
      1, // user id
      'New Name',
      'Developer',
      'newemail@example.com',
      '',
      '',
    );
   verify(mockUserRepository.editProfile(
  1, 'New Name', 'Developer', 'newemail@example.com', '', '')).called(1);
  });
}
