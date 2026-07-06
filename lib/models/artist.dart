import 'package:flutter/material.dart';

@immutable
class Artist {
  final String id;
  final String name;
  final String bio;
  final String imageUrl;

  const Artist({
    this.id = '',
    required this.name,
    this.bio = '',
    this.imageUrl = '',
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Artist',
      bio: json['bio'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
