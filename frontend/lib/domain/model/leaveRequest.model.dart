class LeaveRequest {
  final int id;
  final int userId;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status;
  final int pointsDeduction;
  final int? approvedById;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  LeaveRequest({
    required this.id,
    required this.userId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.pointsDeduction,
    this.approvedById,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'],
      userId: json['userId'],
      type: json['type'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      reason: json['reason'],
      status: json['status'],
      pointsDeduction: json['pointsDeduction'],
      approvedById: json['approvedById'],
      approvedAt:
          json['approvedAt'] != null
              ? DateTime.parse(json['approvedAt'])
              : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
    };
  }
}
class LeaveRequestCreate {
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;

  LeaveRequestCreate({
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
    };
  }
}
