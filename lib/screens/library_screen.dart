import 'package:flutter/material.dart';

import '../models/song.dart';
import '../models/playlist.dart';
import '../theme/neo_theme.dart';
import '../widgets/neo_cover_art.dart';
import 'package:provider/provider.dart';
import '../services/library_provider.dart';
import 'playlist_screen.dart';

enum _LibraryFilter { playlists, albums, artists, likedSongs, downloads }

class LibraryScreen extends StatefulWidget {
  final ValueChanged<Song> onSongSelected;

  const LibraryScreen({super.key, required this.onSongSelected});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  _LibraryFilter _selectedFilter = _LibraryFilter.playlists;
  bool _isGridView = true;
  String _sortOption = 'Recently Added';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 760;
        return Scaffold(
          backgroundColor: NeoTheme.background,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 20 : 28,
                      isMobile ? 20 : 28,
                      isMobile ? 20 : 28,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(isMobile: isMobile),
                        SizedBox(height: isMobile ? 20 : 24),
                        _FilterChips(
                          selected: _selectedFilter,
                          onSelected: (filter) =>
                              setState(() => _selectedFilter = filter),
                        ),
                        const SizedBox(height: 20),
                        _SortRow(
                          sortOption: _sortOption,
                          isGridView: _isGridView,
                          onSortChanged: (value) =>
                              setState(() => _sortOption = value),
                          onViewToggle: () =>
                              setState(() => _isGridView = !_isGridView),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 20 : 28,
                    0,
                    isMobile ? 20 : 28,
                    32,
                  ),
                  sliver: _buildContent(isMobile),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(bool isMobile) {
    return Consumer<LibraryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: NeoTheme.accent),
            ),
          );
        }

        switch (_selectedFilter) {
          case _LibraryFilter.playlists:
            return _PlaylistsContent(
              isGridView: _isGridView,
              isMobile: isMobile,
              playlists: provider.playlists,
            );
          case _LibraryFilter.albums:
            return _AlbumsContent(
              isGridView: _isGridView,
              isMobile: isMobile,
              songs: provider.likedSongs,
            );
          case _LibraryFilter.artists:
            return _ArtistsContent(
              isMobile: isMobile,
              songs: provider.likedSongs,
            );
          case _LibraryFilter.likedSongs:
            return _LikedSongsContent(
              onSongSelected: widget.onSongSelected,
              songs: provider.likedSongs,
            );
          case _LibraryFilter.downloads:
            return const _DownloadsContent();
        }
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final bool isMobile;

  const _Header({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Your Library',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: isMobile ? 26 : 32,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.search_rounded,
            color: NeoTheme.textSecondary,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.add_rounded,
            color: NeoTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Filter Chips
// ---------------------------------------------------------------------------

class _FilterChips extends StatelessWidget {
  final _LibraryFilter selected;
  final ValueChanged<_LibraryFilter> onSelected;

  const _FilterChips({required this.selected, required this.onSelected});

  static const _labels = {
    _LibraryFilter.playlists: 'Playlists',
    _LibraryFilter.albums: 'Albums',
    _LibraryFilter.artists: 'Artists',
    _LibraryFilter.likedSongs: 'Liked Songs',
    _LibraryFilter.downloads: 'Downloads',
  };

  static const _icons = {
    _LibraryFilter.playlists: Icons.queue_music_rounded,
    _LibraryFilter.albums: Icons.album_outlined,
    _LibraryFilter.artists: Icons.person_outline_rounded,
    _LibraryFilter.likedSongs: Icons.favorite_rounded,
    _LibraryFilter.downloads: Icons.download_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _LibraryFilter.values.map((filter) {
          final isSelected = filter == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => onSelected(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected ? NeoTheme.accentGradient : null,
                  color: isSelected ? null : NeoTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: isSelected
                      ? null
                      : Border.all(color: NeoTheme.border),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: NeoTheme.accent.withValues(alpha: .3),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _icons[filter],
                      size: 16,
                      color: isSelected ? Colors.white : NeoTheme.textSecondary,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      _labels[filter]!,
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : NeoTheme.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sort Row
// ---------------------------------------------------------------------------

class _SortRow extends StatelessWidget {
  final String sortOption;
  final bool isGridView;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onViewToggle;

  const _SortRow({
    required this.sortOption,
    required this.isGridView,
    required this.onSortChanged,
    required this.onViewToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _showSortMenu(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.swap_vert_rounded,
                color: NeoTheme.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                sortOption,
                style: const TextStyle(
                  color: NeoTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: NeoTheme.textSecondary,
                size: 18,
              ),
            ],
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onViewToggle,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: NeoTheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: NeoTheme.border),
            ),
            child: Icon(
              isGridView
                  ? Icons.grid_view_rounded
                  : Icons.view_list_rounded,
              color: NeoTheme.textSecondary,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  void _showSortMenu(BuildContext context) {
    const options = [
      'Recently Added',
      'Alphabetical',
      'Recently Played',
      'Creator',
    ];
    showModalBottomSheet<String>(
      context: context,
      backgroundColor: NeoTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text(
                    'Sort by',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                for (final option in options)
                  ListTile(
                    title: Text(
                      option,
                      style: TextStyle(
                        color: option == sortOption
                            ? NeoTheme.accentGlow
                            : NeoTheme.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    trailing: option == sortOption
                        ? const Icon(
                            Icons.check_rounded,
                            color: NeoTheme.accentGlow,
                            size: 20,
                          )
                        : null,
                    onTap: () {
                      onSortChanged(option);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Playlists Content
// ---------------------------------------------------------------------------

class _PlaylistsContent extends StatelessWidget {
  final bool isGridView;
  final bool isMobile;
  final List<Playlist> playlists;

  const _PlaylistsContent({
    required this.isGridView,
    required this.isMobile,
    required this.playlists,
  });

  @override
  Widget build(BuildContext context) {
    if (playlists.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text('No playlists found', style: TextStyle(color: NeoTheme.textSecondary)),
        ),
      );
    }

    if (!isGridView) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final playlist = playlists[index];
            return _LibraryListTile(
              colors: playlist.colors,
              artworkSeed: playlist.artworkSeed,
              title: playlist.title,
              subtitle: playlist.subtitle,
              imagePath: playlist.imagePath,
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: NeoTheme.textHint,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlaylistScreen(
                      playlistId: playlist.id,
                      onSongSelected: (song) {}, // We will handle global playback later
                    ),
                  ),
                );
              },
            );
          },
          childCount: playlists.length,
        ),
      );
    }

    final crossAxisCount = isMobile ? 2 : 4;
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 14,
        childAspectRatio: .78,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final playlist = playlists[index];
          return _LibraryGridCard(
            colors: playlist.colors,
            artworkSeed: playlist.artworkSeed,
            title: playlist.title,
            subtitle: playlist.subtitle,
            imagePath: playlist.imagePath,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlaylistScreen(
                    playlistId: playlist.id,
                    onSongSelected: (song) {},
                  ),
                ),
              );
            },
          );
        },
        childCount: playlists.length,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Albums Content
// ---------------------------------------------------------------------------

class _AlbumsContent extends StatelessWidget {
  final bool isGridView;
  final bool isMobile;
  final List<Song> songs;

  const _AlbumsContent({
    required this.isGridView,
    required this.isMobile,
    required this.songs,
  });

  List<_AlbumInfo> _getUniqueAlbums() {
    final seen = <String>{};
    final albums = <_AlbumInfo>[];
    for (final song in songs) {
      if (seen.add(song.album)) {
        albums.add(_AlbumInfo(
          name: song.album,
          artist: song.artist,
          colors: song.colors,
          artworkSeed: song.artworkSeed,
          imagePath: song.imagePath,
        ));
      }
    }
    return albums;
  }

  @override
  Widget build(BuildContext context) {
    final albums = _getUniqueAlbums();

    if (!isGridView) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final album = albums[index];
            return _LibraryListTile(
              colors: album.colors,
              artworkSeed: album.artworkSeed,
              title: album.name,
              subtitle: album.artist,
              imagePath: album.imagePath,
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: NeoTheme.textHint,
              ),
            );
          },
          childCount: albums.length,
        ),
      );
    }

    final crossAxisCount = isMobile ? 2 : 4;
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 14,
        childAspectRatio: .78,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final album = albums[index];
          return _LibraryGridCard(
            colors: album.colors,
            artworkSeed: album.artworkSeed,
            title: album.name,
            subtitle: album.artist,
            imagePath: album.imagePath,
          );
        },
        childCount: albums.length,
      ),
    );
  }
}

class _AlbumInfo {
  final String name;
  final String artist;
  final List<Color> colors;
  final int artworkSeed;
  final String? imagePath;

  const _AlbumInfo({
    required this.name,
    required this.artist,
    required this.colors,
    required this.artworkSeed,
    this.imagePath,
  });
}

// ---------------------------------------------------------------------------
// Artists Content
// ---------------------------------------------------------------------------

class _ArtistsContent extends StatelessWidget {
  final bool isMobile;
  final List<Song> songs;

  const _ArtistsContent({required this.isMobile, required this.songs});

  List<_ArtistInfo> _getUniqueArtists() {
    final seen = <String>{};
    final artists = <_ArtistInfo>[];
    for (final song in songs) {
      if (seen.add(song.artist)) {
        artists.add(_ArtistInfo(
          name: song.artist,
          colors: song.colors,
          artworkSeed: song.artworkSeed,
        ));
      }
    }
    return artists;
  }

  @override
  Widget build(BuildContext context) {
    final artists = _getUniqueArtists();
    final crossAxisCount = isMobile ? 3 : 5;
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 20,
        crossAxisSpacing: 16,
        childAspectRatio: .82,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final artist = artists[index];
          return Column(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: artist.colors.last.withValues(alpha: .25),
                          blurRadius: 20,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: NeoCoverArt(
                        colors: artist.colors,
                        seed: artist.artworkSeed,
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                artist.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Artist',
                style: TextStyle(
                  color: NeoTheme.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          );
        },
        childCount: artists.length,
      ),
    );
  }
}

class _ArtistInfo {
  final String name;
  final List<Color> colors;
  final int artworkSeed;

  const _ArtistInfo({
    required this.name,
    required this.colors,
    required this.artworkSeed,
  });
}

// ---------------------------------------------------------------------------
// Liked Songs Content
// ---------------------------------------------------------------------------

class _LikedSongsContent extends StatelessWidget {
  final ValueChanged<Song> onSongSelected;
  final List<Song> songs;

  const _LikedSongsContent({required this.onSongSelected, required this.songs});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return _LikedSongsHeader(songCount: songs.length);
          }
          final song = songs[index - 1];
          return InkWell(
            onTap: () => onSongSelected(song),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.transparent,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: NeoCoverArt(
                      colors: song.colors,
                      seed: song.artworkSeed,
                      borderRadius: BorderRadius.circular(8),
                      showOrbit: false,
                      imagePath: song.imagePath,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${song.artist} · ${song.album}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: NeoTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    song.duration,
                    style: const TextStyle(
                      color: NeoTheme.textHint,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.favorite_rounded,
                    color: NeoTheme.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.more_vert_rounded,
                    color: NeoTheme.textHint,
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        },
        childCount: songs.length + 1,
      ),
    );
  }
}

class _LikedSongsHeader extends StatelessWidget {
  final int songCount;

  const _LikedSongsHeader({required this.songCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            NeoTheme.accent.withValues(alpha: .18),
            NeoTheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NeoTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: NeoTheme.accentGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Liked Songs',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$songCount songs',
                  style: const TextStyle(
                    color: NeoTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: NeoTheme.accentGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: NeoTheme.accent.withValues(alpha: .35),
                  blurRadius: 14,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Downloads Content (Empty State)
// ---------------------------------------------------------------------------

class _DownloadsContent extends StatelessWidget {
  const _DownloadsContent();

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: NeoTheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: NeoTheme.border),
              ),
              child: const Icon(
                Icons.download_done_rounded,
                color: NeoTheme.textSecondary,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Downloads Yet',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Music you download will appear here\nfor offline listening.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: NeoTheme.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared: Grid Card
// ---------------------------------------------------------------------------

class _LibraryGridCard extends StatelessWidget {
  final List<Color> colors;
  final int artworkSeed;
  final String title;
  final String subtitle;
  final String? imagePath;
  final VoidCallback? onTap;

  const _LibraryGridCard({
    required this.colors,
    required this.artworkSeed,
    required this.title,
    required this.subtitle,
    this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: NeoTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: NeoTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NeoCoverArt(
                    colors: colors,
                    seed: artworkSeed,
                    borderRadius: BorderRadius.zero,
                    imagePath: imagePath,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xD9090810),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .4),
                            blurRadius: 8,
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: NeoTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared: List Tile
// ---------------------------------------------------------------------------

class _LibraryListTile extends StatelessWidget {
  final List<Color> colors;
  final int artworkSeed;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final String? imagePath;
  final VoidCallback? onTap;

  const _LibraryListTile({
    required this.colors,
    required this.artworkSeed,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: NeoTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: NeoTheme.border.withValues(alpha: .5)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: NeoCoverArt(
                colors: colors,
                seed: artworkSeed,
                borderRadius: BorderRadius.circular(8),
                showOrbit: false,
                imagePath: imagePath,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: NeoTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // ignore: use_null_aware_elements
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
