import 'package:flutter/material.dart';

@immutable
class Playlist {
  final String id;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final int artworkSeed;
  final String? imagePath;

  const Playlist({
    this.id = '',
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.artworkSeed,
    this.imagePath,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    final defaultColors = [const Color(0xFF130027), const Color(0xFF5F0CA7), const Color(0xFFE63AFF)];
    return Playlist(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Unknown',
      subtitle: json['description'] ?? '',
      colors: defaultColors,
      artworkSeed: json['title']?.hashCode ?? 0,
      imagePath: json['coverUrl'],
    );
  }
}
