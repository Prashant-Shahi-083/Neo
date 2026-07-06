import 'package:flutter/foundation.dart';

@immutable
class User {
  final String id;
  final String username;
  final String? email;
  final String role;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  const User({
    required this.id,
    required this.username,
    this.email,
    required this.role,
    this.avatarUrl,
    this.createdAt,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['sub'] ?? '',
      username: json['username'] ?? '',
      email: json['email'],
      role: json['role'] ?? 'NORMAL_USER',
      avatarUrl: json['avatarUrl'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      lastLogin: json['lastLogin'] != null ? DateTime.tryParse(json['lastLogin']) : null,
    );
  }
}
