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

class GridWidget extends StatelessWidget {
  final HomepageSection section;

  const GridWidget({super.key, required this.section});

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
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemCount: section.items.length,
          itemBuilder: (context, index) {
            final item = section.items[index];
            return _buildGridTile(context, item);
          },
        ),
        const SizedBox(height: 36),
      ],
    );
  }

  Widget _buildGridTile(BuildContext context, HomepageItem item) {
    if (item.data == null) return const SizedBox.shrink();

    if (item.data is Song) {
      final song = item.data as Song;
      return _GridTile(
        title: song.title,
        subtitle: song.artist,
        imagePath: song.imagePath,
        colors: song.colors,
        seed: song.artworkSeed,
        isCircular: false,
        onTap: () {
          final playerProvider =
              Provider.of<PlayerProvider>(context, listen: false);
          playerProvider.playTrack(song);
        },
      );
    } else if (item.data is Playlist) {
      final playlist = item.data as Playlist;
      return _GridTile(
        title: playlist.title,
        subtitle: playlist.subtitle,
        imagePath: playlist.imagePath,
        colors: playlist.colors,
        seed: playlist.artworkSeed,
        isCircular: false,
        onTap: () {},
      );
    } else if (item.data is Album) {
      final album = item.data as Album;
      return _GridTile(
        title: album.title,
        subtitle: album.artistName,
        imagePath: album.coverImage,
        colors: const [Color(0xFF8B5CF6), Color(0xFF24103D)],
        seed: album.id.hashCode,
        isCircular: false,
        onTap: () {},
      );
    } else if (item.data is Artist) {
      final artist = item.data as Artist;
      return _GridTile(
        title: artist.name,
        subtitle: 'Artist',
        imagePath: artist.imageUrl,
        colors: const [Color(0xFF8B5CF6), Color(0xFF24103D)],
        seed: artist.id.hashCode,
        isCircular: true,
        onTap: () {},
      );
    }

    return const SizedBox.shrink();
  }
}

class _GridTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? imagePath;
  final List<Color> colors;
  final int seed;
  final bool isCircular;
  final VoidCallback onTap;

  const _GridTile({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.colors,
    required this.seed,
    required this.isCircular,
    required this.onTap,
  });

  @override
  State<_GridTile> createState() => _GridTileState();
}

class _GridTileState extends State<_GridTile> {
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
            Expanded(
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
                      colors: widget.colors.isNotEmpty
                          ? widget.colors
                          : const [Color(0xFF8B5CF6), Color(0xFF24103D)],
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
                        decoration: const BoxDecoration(
                          color: NeoTheme.accent,
                          shape: BoxShape.circle,
                          boxShadow: [
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
