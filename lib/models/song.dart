import 'package:flutter/material.dart';

@immutable
class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String duration;
  final List<Color> colors;
  final int artworkSeed;
  final String? imagePath;
  final String? audioUrl;
  final String? artistName;
  final String coverUrl;

  const Song({
    this.id = '',
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.colors,
    required this.artworkSeed,
    this.imagePath,
    this.audioUrl,
    this.artistName = '',
    this.coverUrl = '',
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    String artistName = 'Unknown Artist';
    if (json['artists'] != null && (json['artists'] as List).isNotEmpty) {
      artistName = (json['artists'] as List).map((a) => a['name']).join(', ');
    }
    String albumName = 'Unknown Album';
    if (json['album'] != null) {
      albumName = json['album']['title'] ?? 'Unknown Album';
    }
    
    String durationStr = '0:00';
    if (json['durationMs'] != null) {
      final duration = Duration(milliseconds: json['durationMs']);
      final minutes = duration.inMinutes;
      final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
      durationStr = '$minutes:$seconds';
    }

    final defaultColors = [const Color(0xFF180028), const Color(0xFF8B16D9), const Color(0xFFEF5CFF)];

    return Song(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Unknown',
      artist: artistName,
      artistName: artistName,
      album: albumName,
      duration: durationStr,
      colors: defaultColors,
      artworkSeed: json['title']?.hashCode ?? 0,
      imagePath: json['coverUrl'],
      coverUrl: json['coverUrl'] ?? '',
      audioUrl: json['audioUrl'],
    );
  }
}
