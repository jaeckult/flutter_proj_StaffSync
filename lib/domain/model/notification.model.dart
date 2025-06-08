class NotificationModel {
  final int id;
  final int userId;
  final String message;
  final DateTime createdAt;
  final int? leaveRequestId;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.message,
    required this.createdAt,
    this.leaveRequestId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['userId'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      leaveRequestId: json['leaveRequestId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'leaveRequestId': leaveRequestId,
    };
  }
}
