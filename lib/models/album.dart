import 'package:flutter/material.dart';

@immutable
class Album {
  final String id;
  final String title;
  final int releaseYear;
  final String coverUrl;
  final String type; // 'ALBUM', 'SINGLE', 'EP'
  final String artistName;

  /// Alias used by homepage widgets (e.g. horizontal_list_widget.dart)
  String get coverImage => coverUrl;

  const Album({
    this.id = '',
    required this.title,
    required this.releaseYear,
    required this.coverUrl,
    this.type = 'ALBUM',
    this.artistName = '',
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    String artistName = '';
    if (json['artist'] != null && json['artist'] is Map) {
      artistName = json['artist']['name'] ?? '';
    }

    return Album(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Unknown Album',
      releaseYear: json['releaseYear'] ?? DateTime.now().year,
      coverUrl: json['coverUrl'] ?? '',
      type: json['type'] ?? 'ALBUM',
      artistName: artistName,
    );
  }
}
