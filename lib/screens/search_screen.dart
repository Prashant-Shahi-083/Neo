import 'package:flutter/material.dart';

import '../models/song.dart';
import '../models/playlist.dart';
import '../models/album.dart';
import '../models/artist.dart';
import '../theme/neo_theme.dart';
import '../widgets/neo_cover_art.dart';
import 'package:provider/provider.dart';
import '../services/search_provider.dart';

class SearchScreen extends StatefulWidget {
  final ValueChanged<Song> onSongSelected;

  const SearchScreen({super.key, required this.onSongSelected});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final text = _controller.text;
      if (_query != text) {
        setState(() => _query = text);
        context.read<SearchProvider>().search(text);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 760;
        final provider = context.watch<SearchProvider>();
        
        return Scaffold(
          backgroundColor: NeoTheme.background,
          body: SafeArea(
            child: isMobile
                ? _MobileSearch(
                    controller: _controller,
                    query: _query,
                    provider: provider,
                    onSongSelected: widget.onSongSelected,
                  )
                : _DesktopSearch(
                    controller: _controller,
                    query: _query,
                    provider: provider,
                    onSongSelected: widget.onSongSelected,
                  ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Mobile Layout
// ─────────────────────────────────────────────

class _MobileSearch extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final SearchProvider provider;
  final ValueChanged<Song> onSongSelected;

  const _MobileSearch({
    required this.controller,
    required this.query,
    required this.provider,
    required this.onSongSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 18, 20, 4),
          child: Text(
            'Search',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: _SearchBar(controller: controller),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: query.isEmpty
                ? _BrowseBody(
                    key: const ValueKey('browse'),
                    crossAxisCount: 2,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  )
                : _ResultsBody(
                    key: const ValueKey('results'),
                    provider: provider,
                    onSongSelected: onSongSelected,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Desktop Layout
// ─────────────────────────────────────────────

class _DesktopSearch extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final SearchProvider provider;
  final ValueChanged<Song> onSongSelected;

  const _DesktopSearch({
    required this.controller,
    required this.query,
    required this.provider,
    required this.onSongSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(14),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: NeoTheme.background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: NeoTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 50,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 8),
            child: Row(
              children: [
                const Text(
                  'Search',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 28),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: _SearchBar(controller: controller),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: query.isEmpty
                  ? _BrowseBody(
                      key: const ValueKey('browse'),
                      crossAxisCount: 4,
                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                    )
                  : _ResultsBody(
                      key: const ValueKey('results'),
                      provider: provider,
                      onSongSelected: onSongSelected,
                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Search Bar
// ─────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: NeoTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: NeoTheme.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: NeoTheme.textSecondary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              cursorColor: NeoTheme.accent,
              decoration: const InputDecoration(
                hintText: 'Songs, artists, or albums...',
                hintStyle: TextStyle(color: NeoTheme.textHint, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (context.watch<SearchProvider>().isSearching) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: NeoTheme.accent),
                  ),
                );
              }
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: controller.clear,
                child: const Icon(
                  Icons.close_rounded,
                  color: NeoTheme.textSecondary,
                  size: 20,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Browse Body (Recent Searches + Category Grid)
// ─────────────────────────────────────────────

class _BrowseBody extends StatelessWidget {
  final int crossAxisCount;
  final EdgeInsets padding;

  const _BrowseBody({
    super.key,
    required this.crossAxisCount,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: padding,
      children: [
        const _RecentSearches(),
        const SizedBox(height: 28),
        const Text(
          'Browse Categories',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        _CategoryGrid(crossAxisCount: crossAxisCount),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Recent Searches
// ─────────────────────────────────────────────

class _RecentSearches extends StatelessWidget {
  const _RecentSearches();

  @override
  Widget build(BuildContext context) {
    final history = context.watch<SearchProvider>().searchHistory;
    if (history.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Recent Searches',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.read<SearchProvider>().clearHistory(),
              child: const Text(
                'Clear all',
                style: TextStyle(color: NeoTheme.accentGlow, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (int i = 0; i < history.length; i++)
          _RecentSearchTile(
            label: history[i],
            onTap: () {
              final controller = context.findAncestorStateOfType<_SearchScreenState>()!._controller;
              controller.text = history[i];
            },
            onDelete: () => context.read<SearchProvider>().removeHistoryItem(i),
          ),
      ],
    );
  }
}

class _RecentSearchTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _RecentSearchTile({
    required this.label,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: NeoTheme.border.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.history_rounded,
                  color: NeoTheme.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: NeoTheme.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onDelete,
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.close_rounded,
                      color: NeoTheme.textHint,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Category Grid
// ─────────────────────────────────────────────

class _CategoryGrid extends StatelessWidget {
  final int crossAxisCount;

  const _CategoryGrid({required this.crossAxisCount});

  static const _categories = <_CategoryData>[
    _CategoryData('Pop', Icons.music_note_rounded, [Color(0xFF7C3AED), Color(0xFF4C1D95)]),
    _CategoryData('Rock', Icons.electric_bolt_rounded, [Color(0xFF6D28D9), Color(0xFF1E1B4B)]),
    _CategoryData('Hip Hop', Icons.headphones_rounded, [Color(0xFF9333EA), Color(0xFF3B0764)]),
    _CategoryData('Electronic', Icons.graphic_eq_rounded, [Color(0xFF8B5CF6), Color(0xFF312E81)]),
    _CategoryData('R&B', Icons.nightlife_rounded, [Color(0xFFA855F7), Color(0xFF581C87)]),
    _CategoryData('Indie', Icons.star_rounded, [Color(0xFF6366F1), Color(0xFF1E1B4B)]),
    _CategoryData('Jazz', Icons.piano_rounded, [Color(0xFF7C3AED), Color(0xFF2E1065)]),
    _CategoryData('Classical', Icons.library_music_rounded, [Color(0xFF8B5CF6), Color(0xFF1E1B4B)]),
    _CategoryData('Workout', Icons.fitness_center_rounded, [Color(0xFFC026D3), Color(0xFF701A75)]),
    _CategoryData('Chill', Icons.spa_rounded, [Color(0xFF7C3AED), Color(0xFF0F172A)]),
    _CategoryData('Party', Icons.celebration_rounded, [Color(0xFFA855F7), Color(0xFF4A044E)]),
    _CategoryData('Focus', Icons.psychology_rounded, [Color(0xFF6366F1), Color(0xFF0C0A3E)]),
  ];

  @override
  Widget build(BuildContext context) {
    const spacing = 12.0;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: 1.65,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        return _CategoryCard(data: _categories[index], index: index);
      },
    );
  }
}

class _CategoryData {
  final String label;
  final IconData icon;
  final List<Color> gradientColors;

  const _CategoryData(this.label, this.icon, this.gradientColors);
}

class _CategoryCard extends StatefulWidget {
  final _CategoryData data;
  final int index;

  const _CategoryCard({required this.data, required this.index});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    final delay = widget.index * 0.07;
    final curvedAnim = CurvedAnimation(
      parent: _animController,
      curve: Interval(delay.clamp(0.0, 0.6), 1.0, curve: Curves.easeOutCubic),
    );
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(curvedAnim);
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnim);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnim.value,
          child: Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.data.gradientColors,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.data.gradientColors.first.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.data.gradientColors.first.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -8,
                  bottom: -8,
                  child: Icon(
                    widget.data.icon,
                    size: 56,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.data.icon,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 22,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.data.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Search Results
// ─────────────────────────────────────────────

class _ResultsBody extends StatefulWidget {
  final SearchProvider provider;
  final ValueChanged<Song> onSongSelected;
  final EdgeInsets padding;

  const _ResultsBody({
    super.key,
    required this.provider,
    required this.onSongSelected,
    required this.padding,
  });

  @override
  State<_ResultsBody> createState() => _ResultsBodyState();
}

class _ResultsBodyState extends State<_ResultsBody> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        widget.provider.loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;

    if (provider.isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: NeoTheme.accent),
      );
    }

    if (provider.error != null && provider.songs.isEmpty && provider.albums.isEmpty && provider.artists.isEmpty && provider.playlists.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              provider.error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => provider.retrySearch(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: TextButton.styleFrom(foregroundColor: NeoTheme.accentGlow),
            ),
          ],
        ),
      );
    }

    final hasResults = provider.songs.isNotEmpty ||
        provider.albums.isNotEmpty ||
        provider.artists.isNotEmpty ||
        provider.playlists.isNotEmpty;

    if (!hasResults) {
      return Center(
        child: Padding(
          padding: widget.padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                color: NeoTheme.textHint.withValues(alpha: 0.5),
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'No results found',
                style: TextStyle(
                  color: NeoTheme.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Try searching for something else',
                style: TextStyle(color: NeoTheme.textHint, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: widget.padding,
      child: CustomScrollView(
        controller: _scrollController,
      slivers: [
        if (provider.songs.isNotEmpty)
          _SearchSection(
            title: 'Songs',
            itemCount: provider.songs.length,
            builder: (context, index) {
              final song = provider.songs[index];
              return _SongResultTile(
                song: song,
                onTap: () => widget.onSongSelected(song),
                index: index,
              );
            },
          ),
        if (provider.albums.isNotEmpty)
          _SearchSection(
            title: 'Albums',
            itemCount: provider.albums.length,
            builder: (context, index) {
              final album = provider.albums[index];
              return _AlbumResultTile(album: album, index: index);
            },
          ),
        if (provider.artists.isNotEmpty)
          _SearchSection(
            title: 'Artists',
            itemCount: provider.artists.length,
            builder: (context, index) {
              final artist = provider.artists[index];
              return _ArtistResultTile(artist: artist, index: index);
            },
          ),
        if (provider.playlists.isNotEmpty)
          _SearchSection(
            title: 'Playlists',
            itemCount: provider.playlists.length,
            builder: (context, index) {
              final playlist = provider.playlists[index];
              return _PlaylistResultTile(playlist: playlist, index: index);
            },
          ),
        SliverToBoxAdapter(
          child: _PaginationFooter(
            isLoadingMore: provider.isLoadingMore,
            hasMore: provider.hasMore,
            paginationError: provider.error,
            onRetry: () => provider.retrySearch(),
          ),
        ),
      ],
    ),
    );
  }
}

class _SearchSection extends StatelessWidget {
  final String title;
  final int itemCount;
  final Widget Function(BuildContext, int) builder;

  const _SearchSection({
    required this.title,
    required this.itemCount,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 12),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            builder,
            childCount: itemCount,
          ),
        ),
      ],
    );
  }
}

class _SongResultTile extends StatefulWidget {
  final Song song;
  final VoidCallback onTap;
  final int index;

  const _SongResultTile({
    required this.song,
    required this.onTap,
    required this.index,
  });

  @override
  State<_SongResultTile> createState() => _SongResultTileState();
}

class _SongResultTileState extends State<_SongResultTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    final curved = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(curved);
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(curved);

    Future.delayed(
      Duration(milliseconds: widget.index * 60),
      () {
        if (mounted) _animController.forward();
      },
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return FractionalTranslation(
          translation: _slideAnim.value,
          child: Opacity(opacity: _fadeAnim.value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: NeoTheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: NeoTheme.border.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: NeoCoverArt(
                      colors: widget.song.colors,
                      seed: widget.song.artworkSeed,
                      borderRadius: BorderRadius.circular(8),
                      imagePath: widget.song.imagePath,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.song.title,
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
                          '${widget.song.artist} • ${widget.song.album}',
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
                  const SizedBox(width: 8),
                  Text(
                    widget.song.duration,
                    style: const TextStyle(
                      color: NeoTheme.textHint,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.play_circle_outline_rounded,
                    color: NeoTheme.textSecondary,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AlbumResultTile extends StatelessWidget {
  final Album album;
  final int index;

  const _AlbumResultTile({required this.album, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: NeoTheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: NeoTheme.border.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: NeoCoverArt(
                    colors: const [Color(0xFF8B5CF6), Color(0xFF24103D)],
                    seed: album.id.hashCode,
                    borderRadius: BorderRadius.circular(8),
                    imagePath: album.coverImage,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        album.title,
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
                        'Album • ${album.artistName}',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArtistResultTile extends StatelessWidget {
  final Artist artist;
  final int index;

  const _ArtistResultTile({required this.artist, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: NeoTheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: NeoTheme.border.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: ClipOval(
                    child: NeoCoverArt(
                      colors: const [Color(0xFF8B5CF6), Color(0xFF24103D)],
                      seed: artist.id.hashCode,
                      borderRadius: BorderRadius.circular(24),
                      imagePath: artist.imageUrl,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Artist',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: NeoTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaylistResultTile extends StatelessWidget {
  final Playlist playlist;
  final int index;

  const _PlaylistResultTile({required this.playlist, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: NeoTheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: NeoTheme.border.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: NeoCoverArt(
                    colors: playlist.colors,
                    seed: playlist.artworkSeed,
                    borderRadius: BorderRadius.circular(8),
                    imagePath: playlist.imagePath,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Playlist',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: NeoTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  final bool isLoadingMore;
  final bool hasMore;
  final String? paginationError;
  final VoidCallback onRetry;

  const _PaginationFooter({
    required this.isLoadingMore,
    required this.hasMore,
    required this.paginationError,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (paginationError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              paginationError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: NeoTheme.accentGlow,
              ),
            ),
          ],
        ),
      );
    }

    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: NeoTheme.accentGlow,
            ),
          ),
        ),
      );
    }

    if (!hasMore) {
      return const SizedBox(height: 16);
    }

    return const SizedBox.shrink();
  }
}
