import 'package:flutter/material.dart';
import '../../models/homepage_section.dart';
import '../../models/song.dart';
import '../../models/playlist.dart';
import '../../models/album.dart';
import '../../models/artist.dart';
import '../neo_cover_art.dart';
import '../../theme/neo_theme.dart';
import 'package:provider/provider.dart';
import '../../services/player_provider.dart';
import '../../screens/playback_screen.dart';

class HorizontalListWidget extends StatelessWidget {
  final HomepageSection section;

  const HorizontalListWidget({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    if (section.items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                section.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See all',
                style: TextStyle(color: NeoTheme.accentGlow, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: section.items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = section.items[index];
              return _buildCard(context, item);
            },
          ),
        ),
        const SizedBox(height: 36),
      ],
    );
  }

  Widget _buildCard(BuildContext context, HomepageItem item) {
    if (item.data == null) return const SizedBox.shrink();

    if (item.data is Song) {
      final song = item.data as Song;
      return SizedBox(
        width: 140,
        child: _HoverCard(
          title: song.title,
          subtitle: song.artist,
          imagePath: song.imagePath,
          colors: song.colors,
          seed: song.artworkSeed ?? song.id.hashCode,
          isCircular: false,
          onTap: () {
            final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
            playerProvider.playTrack(song);
          },
        ),
      );
    } else if (item.data is Playlist) {
      final playlist = item.data as Playlist;
      return SizedBox(
        width: 150,
        child: _HoverCard(
          title: playlist.title,
          subtitle: playlist.subtitle,
          imagePath: playlist.imagePath,
          colors: playlist.colors,
          seed: playlist.artworkSeed ?? playlist.id.hashCode,
          isCircular: false,
          onTap: () {},
        ),
      );
    } else if (item.data is Album) {
      final album = item.data as Album;
      return SizedBox(
        width: 140,
        child: _HoverCard(
          title: album.title,
          subtitle: album.artistName,
          imagePath: album.coverImage,
          colors: [Color(0xFF8B5CF6), Color(0xFF24103D)],
          seed: album.id.hashCode,
          isCircular: false,
          onTap: () {},
        ),
      );
    } else if (item.data is Artist) {
      final artist = item.data as Artist;
      return SizedBox(
        width: 140,
        child: _HoverCard(
          title: artist.name,
          subtitle: 'Artist',
          imagePath: artist.imageUrl,
          colors: [Color(0xFF8B5CF6), Color(0xFF24103D)],
          seed: artist.id.hashCode,
          isCircular: true,
          onTap: () {},
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _HoverCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? imagePath;
  final List<Color> colors;
  final int seed;
  final bool isCircular;
  final VoidCallback onTap;

  const _HoverCard({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.colors,
    required this.seed,
    required this.isCircular,
    required this.onTap,
  });

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    transform: Matrix4.diagonal3Values(
                      _hovered ? 1.03 : 1.0,
                      _hovered ? 1.03 : 1.0,
                      1.0,
                    ),
                    transformAlignment: Alignment.center,
                    child: NeoCoverArt(
                      colors: widget.colors.isNotEmpty ? widget.colors : [Color(0xFF8B5CF6), Color(0xFF24103D)],
                      seed: widget.seed,
                      borderRadius: widget.isCircular
                          ? BorderRadius.circular(100)
                          : BorderRadius.circular(10),
                      imagePath: widget.imagePath,
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: _hovered ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        width: 31,
                        height: 31,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: NeoTheme.accent,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x558B5CF6),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: NeoTheme.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
