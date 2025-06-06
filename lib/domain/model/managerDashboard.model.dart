class Managerdashboard {
  final int totalPresent;
  final int totalAbsent;
  final int totalCheckedIn;
  final int totalCheckedOut;

  Managerdashboard({
    required this.totalPresent,
    required this.totalAbsent,
    required this.totalCheckedIn,
    required this.totalCheckedOut,
  });

  factory Managerdashboard.fromJson(Map<String, dynamic> json) {
    return Managerdashboard(
      totalPresent: json['totalPresent'] as int,
      totalAbsent: json['totalAbsent'] as int,
      totalCheckedIn: json['totalCheckedIn'] as int,
      totalCheckedOut: json['totalCheckedOut'] as int,
    );
  }
}
