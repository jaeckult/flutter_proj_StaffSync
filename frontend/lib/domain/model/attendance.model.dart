class Attendance {
  final int id;
  final DateTime date;
  final DateTime checkIn;
  final DateTime? checkOut;
  final String attendance;
  final DateTime createdAt;
  Attendance({
    required this.id,
    required this.date,
    required this.checkIn,
    this.checkOut,
    required this.attendance,
    required this.createdAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      date: DateTime.parse(json['date']),
      checkIn: DateTime.parse(json['checkIn']),
      checkOut:
          json['checkOut'] != null ? DateTime.parse(json['checkOut']) : null,
      attendance: json['attendance'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class AttendanceResponse {
  final String message;
  final AttendanceData attendance;

  AttendanceResponse({
    required this.message,
    required this.attendance,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      message: json['message'],
      attendance: AttendanceData.fromJson(json['attendance']),
    );
  }
}

class AttendanceData {
  final int id;
  final DateTime checkIn;
  final String attendance;
  final DateTime? checkOut;

  AttendanceData({
    required this.id,
    required this.checkIn,
    required this.attendance,
    this.checkOut,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      id: json['id'],
      checkIn: DateTime.parse(json['checkIn']),
      attendance: json['attendance'],
      checkOut: json['checkOut'] != null ? DateTime.parse(json['checkOut']) : null,
    );
  }
}


