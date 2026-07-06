import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../models/playlist.dart';
import '../services/playlist_provider.dart';
import '../theme/neo_theme.dart';
import '../widgets/neo_cover_art.dart';

class PlaylistScreen extends StatefulWidget {
  final String playlistId;
  final ValueChanged<Song> onSongSelected;

  const PlaylistScreen({
    super.key,
    required this.playlistId,
    required this.onSongSelected,
  });

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlaylistProvider>().loadPlaylist(widget.playlistId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoTheme.background,
      body: Consumer<PlaylistProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: NeoTheme.accent),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: NeoTheme.accent, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<PlaylistProvider>().loadPlaylist(widget.playlistId),
                    style: ElevatedButton.styleFrom(backgroundColor: NeoTheme.accent),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final playlist = provider.playlist;
          if (playlist == null) {
            return const Center(
              child: Text('Playlist not found', style: TextStyle(color: Colors.white)),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;
              final horizontalPadding = isDesktop ? (constraints.maxWidth - 900) / 2 : 0.0;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: isDesktop ? 400 : 320,
                        pinned: true,
                        backgroundColor: NeoTheme.background,
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        flexibleSpace: FlexibleSpaceBar(
                          titlePadding: EdgeInsets.only(
                            left: isDesktop ? horizontalPadding + 48 : 48,
                            bottom: 16,
                          ),
                          title: Text(
                            playlist.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                            ),
                          ),
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              Hero(
                                tag: 'playlist_${widget.playlistId}',
                                child: NeoCoverArt(
                                  colors: playlist.colors,
                                  seed: playlist.artworkSeed,
                                  imagePath: playlist.imagePath,
                                  borderRadius: BorderRadius.zero,
                                  showOrbit: false,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      NeoTheme.background.withValues(alpha: .6),
                                      NeoTheme.background,
                                    ],
                                    stops: const [0.0, 0.7, 1.0],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? horizontalPadding + 40 : 20,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 32),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (playlist.subtitle.isNotEmpty)
                                        Text(
                                          playlist.subtitle,
                                          style: const TextStyle(
                                            color: NeoTheme.textSecondary,
                                            fontSize: 16,
                                          ),
                                        ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${provider.songs.length} songs',
                                        style: const TextStyle(
                                          color: NeoTheme.textHint,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                FloatingActionButton.large(
                                  backgroundColor: NeoTheme.accent,
                                  elevation: 8,
                                  onPressed: provider.songs.isNotEmpty
                                      ? () => widget.onSongSelected(provider.songs.first)
                                      : null,
                                  child: const Icon(Icons.play_arrow_rounded, size: 40, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? horizontalPadding + 40 : 0,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final song = provider.songs[index];
                              return InkWell(
                                onTap: () => widget.onSongSelected(song),
                                hoverColor: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(isDesktop ? 8 : 0),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 40,
                                        child: Text(
                                          '${index + 1}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: NeoTheme.textHint,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        flex: 4,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              song.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              song.artist,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: NeoTheme.textSecondary,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isDesktop)
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            song.album,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: NeoTheme.textSecondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      Text(
                                        song.duration,
                                        style: const TextStyle(
                                          color: NeoTheme.textHint,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      const Icon(
                                        Icons.more_horiz_rounded,
                                        color: NeoTheme.textHint,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            childCount: provider.songs.length,
                          ),
                        ),
                      ),
                      const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
