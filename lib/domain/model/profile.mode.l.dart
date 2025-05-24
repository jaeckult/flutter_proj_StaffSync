class Profile {
  final int id;
  final String fullName;
  final String gender;
  final String employmentType;
  final String designation;
  final int userId;
  final DateTime dateOfBirth;
  final String profilePicture;

  Profile({
    required this.id,
    required this.fullName,
    required this.gender,
    required this.employmentType,
    required this.designation,
    required this.userId,
    required this.dateOfBirth,
    required this.profilePicture,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      fullName: json['fullName'],
      gender: json['gender'],
      employmentType: json['employmentType'],
      designation: json['designation'],
      userId: json['userId'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      profilePicture: json['profilePicture']
    );
  }
}
