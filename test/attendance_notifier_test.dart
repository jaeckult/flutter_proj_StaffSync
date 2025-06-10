import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:staffsync/domain/model/attendance.model.dart';

import 'mock/attendance_repository_mock.mocks.dart';

void main() {
  late MockAttendanceRepository mockRepository;

  setUp(() {
    mockRepository = MockAttendanceRepository();
  });

  test('getAttendances returns a list of Attendance', () async {
    final mockAttendance = Attendance(
      id: 1,
      date: DateTime(2024, 1, 1),
      checkIn: DateTime(2024, 1, 1, 8, 0),
      checkOut: DateTime(2024, 1, 1, 17, 0),
      attendance: 'Present',
      createdAt: DateTime(2024, 1, 1, 8, 0),
    );

    when(mockRepository.getAttendances('dummy_token')).thenAnswer(
          (_) async => [mockAttendance],
    );

    final result = await mockRepository.getAttendances('dummy_token');

    expect(result, isA<List<Attendance>>());
    expect(result.length, 1);
    expect(result.first.attendance, 'Present');
    expect(result.first.checkIn.hour, 8);

    verify(mockRepository.getAttendances('dummy_token')).called(1);
  });

  test('checkIn completes without error', () async {
    final attendanceData = AttendanceData(
      id: 1,
      checkIn: DateTime(2024, 1, 1, 9),
      attendance: 'Present',
      checkOut: null,
    );

    final response = AttendanceResponse(
      message: 'Check-in successful',
      attendance: attendanceData,
    );

    when(mockRepository.checkIn(response)).thenAnswer((_) async => {});

    await mockRepository.checkIn(response);

    verify(mockRepository.checkIn(response)).called(1);
  });

  test('checkOut completes without error', () async {
    final attendanceData = AttendanceData(
      id: 1,
      checkIn: DateTime(2024, 1, 1, 9),
      attendance: 'Present',
      checkOut: DateTime(2024, 1, 1, 17),
    );

    final response = AttendanceResponse(
      message: 'Check-out successful',
      attendance: attendanceData,
    );

    when(mockRepository.checkOut(response)).thenAnswer((_) async => {});

    await mockRepository.checkOut(response);

    verify(mockRepository.checkOut(response)).called(1);
  });

  test('deleteAttendance completes without error', () async {
    const int id = 1;

    when(mockRepository.deleteAttendance(id)).thenAnswer((_) async => {});

    await mockRepository.deleteAttendance(id);

    verify(mockRepository.deleteAttendance(id)).called(1);
  });
}