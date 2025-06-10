import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:staffsync/domain/model/user.model.dart';
import 'package:staffsync/domain/model/notification.model.dart';
import 'package:staffsync/domain/model/profile.mode.l.dart';
import 'package:staffsync/domain/model/attendance.model.dart';
import 'mock/user_repository_mock.mocks.dart'; // adjust path as needed

void main() {
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  // Helper function to create a dummy Profile
  Profile createDummyProfile() {
    return Profile(
      id: 1,
      fullName: 'John Doe',
      designation: 'Developer',
      gender: "MALE",
      dateOfBirth: DateTime(1990, 1, 1),
      employmentType: 'Full-time',
      profilePicture: 'url_to_image',
      userId: 1,
    );
  }

  // Helper function to create dummy Attendance
  Attendance createDummyAttendance() {
    return Attendance(
      id: 1,
      date: DateTime(2024, 1, 1),
      checkIn: DateTime(2024, 1, 1, 8, 0),
      checkOut: DateTime(2024, 1, 1, 17, 0),
      attendance: 'Present',
      createdAt: DateTime(2024, 1, 1, 8, 0),
    );
  }

  group('UserRepository Tests', () {
    test('getCurrUser returns a User', () async {
      final dummyUser = User(
        id: 1,
        username: 'johndoe',
        email: 'john@example.com',
        role: 'admin',
        points: 100,
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        updatedAt: DateTime.now(),
        profile: createDummyProfile(),
        attendance: [createDummyAttendance()],
      );

      when(mockUserRepository.getCurrUser(1, 'endpoint'))
          .thenAnswer((_) async => dummyUser);

      final user = await mockUserRepository.getCurrUser(1, 'endpoint');

      expect(user, isA<User>());
      expect(user.id, 1);
      expect(user.username, 'johndoe');
      expect(user.profile.fullName, 'John Doe');
      expect(user.attendance, isNotEmpty);
      verify(mockUserRepository.getCurrUser(1, 'endpoint')).called(1);
    });

    test('getEmployees returns a list of Users', () async {
      final dummyUsers = [
        User(
          id: 1,
          username: 'johndoe',
          email: 'john@example.com',
          role: 'admin',
          points: 100,
          createdAt: DateTime.now().subtract(Duration(days: 30)),
          updatedAt: DateTime.now(),
          profile: createDummyProfile(),
          attendance: [createDummyAttendance()],
        ),
        User(
          id: 2,
          username: 'janedoe',
          email: 'jane@example.com',
          role: 'user',
          points: 50,
          createdAt: DateTime.now().subtract(Duration(days: 15)), // i just used random nums
          updatedAt: DateTime.now(),
          profile: createDummyProfile(),
          attendance: [],
        ),
      ];

      when(mockUserRepository.getEmployees('token123'))
          .thenAnswer((_) async => dummyUsers);

      final employees = await mockUserRepository.getEmployees('token123');

      expect(employees, isA<List<User>>());
      expect(employees.length, 2);
      expect(employees[0].username, 'johndoe');
      expect(employees[1].username, 'janedoe');
      verify(mockUserRepository.getEmployees('token123')).called(1);
    });

    test('deleteEmployee completes successfully', () async {
      when(mockUserRepository.deleteEmployee(1, 'token123'))
          .thenAnswer((_) async => Future.value());

      await mockUserRepository.deleteEmployee(1, 'token123');

      verify(mockUserRepository.deleteEmployee(1, 'token123')).called(1);
    });

    test('changePassword completes successfully', () async {
      when(mockUserRepository.changePassword(
        userId: 1,
        oldPassword: 'oldpass',
        newPassword: 'newpass',
        token: 'token123',
        endpoint: 'endpointA',
      )).thenAnswer((_) async => Future.value());

      await mockUserRepository.changePassword(
          userId: 1,
          oldPassword: 'oldpass',
          newPassword: 'newpass',
          token:'token123',
        endpoint: 'endpointA',
      );

      verify(mockUserRepository.changePassword(
        userId: 1,
        oldPassword: 'oldpass',
        newPassword: 'newpass',
        token: 'token123',
        endpoint: 'endpointA',
      )).called(1);
    });

    test('getNotificationMessage returns a list of NotificationModel', () async {
      final dummyNotifications = [
        NotificationModel(
          id: 1,
          userId: 1,
          message: 'Welcome to StaffSync!',
          createdAt: DateTime.now().subtract(Duration(days: 1)),
          leaveRequestId: null,
        ),
      ];

      when(mockUserRepository.getNotificationMessage())
          .thenAnswer((_) async => dummyNotifications);

      final notifications = await mockUserRepository.getNotificationMessage();

      expect(notifications, isA<List<NotificationModel>>());
      expect(notifications.length, 1);
      expect(notifications[0].message, 'Welcome to StaffSync!');
      verify(mockUserRepository.getNotificationMessage()).called(1);
    });
  });
}