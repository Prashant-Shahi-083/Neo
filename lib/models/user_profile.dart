class ListeningStats {
  final int totalListeningHours;
  final int totalTracksPlayed;
  final List<String> topGenres;

  const ListeningStats({
    required this.totalListeningHours,
    required this.totalTracksPlayed,
    required this.topGenres,
  });

  factory ListeningStats.fromJson(Map<String, dynamic> json) {
    return ListeningStats(
      totalListeningHours: json['totalListeningHours'] ?? 0,
      totalTracksPlayed: json['totalTracksPlayed'] ?? 0,
      topGenres: List<String>.from(json['topGenres'] ?? []),
    );
  }
}

class UserProfile {
  final String id;
  final String username;
  final String displayName;
  final String email;
  final String avatar;
  final String role;
  final String createdAt;
  final bool premium;
  final ListeningStats stats;

  UserProfile({
    required this.id,
    required this.username,
    required this.displayName,
    required this.email,
    required this.avatar,
    required this.role,
    required this.createdAt,
    required this.premium,
    required this.stats,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] ?? json['username'],
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? '',
      role: json['role'] as String,
      createdAt: json['createdAt'] as String,
      premium: json['premium'] ?? false,
      stats: json['stats'] != null ? ListeningStats.fromJson(json['stats']) : const ListeningStats(totalListeningHours: 0, totalTracksPlayed: 0, topGenres: []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'email': email,
      'avatar': avatar,
      'role': role,
      'createdAt': createdAt,
      'premium': premium,
      'stats': {
        'totalListeningHours': stats.totalListeningHours,
        'totalTracksPlayed': stats.totalTracksPlayed,
        'topGenres': stats.topGenres,
      }
    };
  }
}
