import 'package:staffsync/domain/model/profile.mode.l.dart';

class User {
  final int id;
  final String username;
  final String email;
  final String role;
  final int points;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Profile profile;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.points,
    required this.createdAt,
    required this.updatedAt,
    required this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      points: json['points'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      profile: Profile.fromJson(json['profile']),
    );
  }
}
