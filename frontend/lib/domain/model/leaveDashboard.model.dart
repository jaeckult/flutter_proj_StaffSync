class LeaveDashboard {
  final int balance;
  final int approved;
  final int pending;
  final int cancelled;

  LeaveDashboard({
    required this.balance,
    required this.approved,
    required this.pending,
    required this.cancelled,
  });

  factory LeaveDashboard.fromJson(Map<String, dynamic> json) {
    return LeaveDashboard(
      balance: json['leaveBalance'] as int,
      approved: json['leaveApproved'] as int,
      pending: json['leavePending'] as int,
      cancelled: json['leaveCancelled'] as int,
    );
  }
}
