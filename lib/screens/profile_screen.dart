import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/song.dart';
import '../models/user_profile.dart';
import '../services/profile_provider.dart';
import '../services/home_provider.dart';
import '../services/auth_provider.dart';
import '../theme/neo_theme.dart';
import '../widgets/neo_cover_art.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  final ValueChanged<Song>? onSongSelected;
  
  const ProfileScreen({super.key, this.onSongSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoTheme.background,
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: NeoTheme.accent,
              ),
            );
          }

          if (profileProvider.error != null || profileProvider.profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: NeoTheme.textSecondary, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    profileProvider.error ?? 'Failed to load profile',
                    style: const TextStyle(color: NeoTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => profileProvider.refreshProfile(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NeoTheme.accent,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final profile = profileProvider.profile!;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, profile),
                      const SizedBox(height: 32),
                      _buildStatsRow(profile.stats),
                      const SizedBox(height: 48),
                      _buildSectionTitle('Recently Played'),
                      const SizedBox(height: 16),
                      _buildRecentlyPlayedList(context),
                      const SizedBox(height: 48),
                      _buildSectionTitle('Favorite Artists'),
                      const SizedBox(height: 16),
                      _buildFavoriteArtistsList(),
                      const SizedBox(height: 64), // extra padding at the bottom
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, profile) {
    final dateFormat = DateFormat('MMMM yyyy');
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: NeoTheme.accent, width: 3),
            boxShadow: [
              BoxShadow(
                color: NeoTheme.accent.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
            image: DecorationImage(
              image: profile.avatarUrl.startsWith('http')
                  ? CachedNetworkImageProvider(profile.avatarUrl) as ImageProvider
                  : AssetImage(profile.avatarUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      color: NeoTheme.textHint,
                      fontSize: 12,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: NeoTheme.textSecondary),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                        },
                        tooltip: 'Settings',
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: NeoTheme.textSecondary),
                        onPressed: () {
                          context.read<AuthProvider>().logout();
                        },
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                profile.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: NeoTheme.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: NeoTheme.accent.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      profile.accountType,
                      style: const TextStyle(
                        color: NeoTheme.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    profile.email,
                    style: const TextStyle(color: NeoTheme.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(width: 12),
                  const Text('•', style: TextStyle(color: NeoTheme.textHint)),
                  const SizedBox(width: 12),
                  Text(
                    'Joined ${dateFormat.format(profile.joinDate)}',
                    style: const TextStyle(color: NeoTheme.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(ListeningStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final children = [
          _buildStatCard('Listening Hours', stats.totalListeningHours.toString(), Icons.headphones_rounded),
          if (isMobile) const SizedBox(height: 16) else const SizedBox(width: 16),
          _buildStatCard('Tracks Played', stats.totalTracksPlayed.toString(), Icons.library_music_rounded),
          if (isMobile) const SizedBox(height: 16) else const SizedBox(width: 16),
          _buildStatCard('Top Genres', stats.topGenres.take(2).join(', '), Icons.graphic_eq_rounded),
        ];

        if (isMobile) {
          return Column(children: children);
        }
        return Row(children: children.map((e) => Expanded(child: e)).toList());
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111119),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: NeoTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: NeoTheme.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: NeoTheme.accent, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: NeoTheme.textHint,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildRecentlyPlayedList(BuildContext context) {
    final songs = context.watch<HomeProvider>().recentlyPlayed.take(6).toList();
    
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: songs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          final song = songs[index];
          return GestureDetector(
            onTap: () => onSongSelected?.call(song),
            child: SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NeoCoverArt(
                    imagePath: song.imagePath ?? '',
                    seed: song.artworkSeed,
                    colors: song.colors,
                    size: 140,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    song.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    style: const TextStyle(
                      color: NeoTheme.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteArtistsList() {
    final artists = [
      {'name': 'The Weeknd', 'image': 'assets/images/albums/album1.jpg'},
      {'name': 'Imagine Dragons', 'image': 'assets/images/albums/album5.jpg'},
      {'name': 'Sia', 'image': 'assets/images/albums/album3.jpg'},
      {'name': 'Glass Animals', 'image': 'assets/images/albums/album6.jpg'},
    ];

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: artists.length,
        separatorBuilder: (context, index) => const SizedBox(width: 24),
        itemBuilder: (context, index) {
          final artist = artists[index];
          return Column(
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: artist['image']!.startsWith('http')
                        ? CachedNetworkImageProvider(artist['image']!) as ImageProvider
                        : AssetImage(artist['image']!),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x20000000),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                artist['name']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
