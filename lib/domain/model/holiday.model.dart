class Holiday {
  final int id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String? description;
  final int? createdById;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Holiday({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.description,
    this.createdById,
    this.createdAt,
    this.updatedAt,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id'],
      title: json['title'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      description: json['description'],
      createdById: json['createdById'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'description': description,
      'createdById': createdById,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
