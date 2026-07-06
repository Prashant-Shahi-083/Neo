import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/song.dart';
import 'models/playlist.dart';
import 'screens/library_screen.dart';
import 'screens/playback_screen.dart';
import 'screens/premium_screen.dart';
import 'screens/search_screen.dart';
import 'screens/lock_screen_controls_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/neo_theme.dart';
import 'widgets/neo_cover_art.dart';
import 'widgets/neo_logo.dart';
import 'services/home_provider.dart';
import 'services/player_provider.dart';
import 'services/auth_provider.dart';
import 'widgets/playback/bottom_player.dart';
import 'widgets/homepage_sections/homepage_widget_factory.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _liked = true;
  int _mobileTab = 0;
  int _desktopTab = 0;

  void _selectSong(Song song, {bool openPlayer = false}) {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    playerProvider.playTrack(song);
    
    if (openPlayer) {
      _openPlayer();
    }
  }

  Future<void> _openPlayer() async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, _) => const PlaybackScreen(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();
    final currentSong = playerProvider.currentTrack;
    if (currentSong == null) return const SizedBox.shrink();
    final isPlaying = playerProvider.isPlaying;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return _MobileHome(
            currentSong: currentSong,
            isPlaying: isPlaying,
            selectedTab: _mobileTab,
            onTabChanged: (value) => setState(() => _mobileTab = value),
            onSongSelected: _selectSong,
            onPlayPause: playerProvider.togglePlayPause,
            onOpenPlayer: _openPlayer,
          );
        }

        return _DesktopHome(
          currentSong: currentSong,
          isPlaying: isPlaying,
          liked: _liked,
          selectedTab: _desktopTab,
          onTabChanged: (value) => setState(() => _desktopTab = value),
          onLiked: () => setState(() => _liked = !_liked),
          onSongSelected: _selectSong,
          onPlayPause: playerProvider.togglePlayPause,
          onOpenPlayer: _openPlayer,
        );
      },
    );
  }
}

class _DesktopHome extends StatelessWidget {
  final Song currentSong;
  final bool isPlaying;
  final bool liked;
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final ValueChanged<Song> onSongSelected;
  final VoidCallback onPlayPause;
  final VoidCallback onOpenPlayer;
  final VoidCallback onLiked;

  const _DesktopHome({
    required this.currentSong,
    required this.isPlaying,
    required this.liked,
    required this.selectedTab,
    required this.onTabChanged,
    required this.onSongSelected,
    required this.onPlayPause,
    required this.onOpenPlayer,
    required this.onLiked,
  });

  Widget _buildMainContent(BuildContext context) {
    switch (selectedTab) {
      case 0:
        return _DesktopFeed(onSongSelected: onSongSelected);
      case 1:
        return SearchScreen(onSongSelected: onSongSelected);
      case 2:
        return LibraryScreen(onSongSelected: onSongSelected);
      case 3:
        return const LockScreenControlsScreen();
      case 4:
        return ProfileScreen(onSongSelected: onSongSelected);
      default:
        return _DesktopFeed(onSongSelected: onSongSelected);
    }
  }

  Widget _buildRightPanel(BuildContext context) {
    if (selectedTab == 2) {
      return _LibraryQueuePanel(
        currentSong: currentSong,
        onSongSelected: onSongSelected,
        onClearQueue: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Playing queue reset to default playlist.'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      );
    }
    return _NowPlayingPanel(
      song: currentSong,
      isPlaying: isPlaying,
      liked: liked,
      onLiked: onLiked,
      onPlayPause: onPlayPause,
      onOpenPlayer: onOpenPlayer,
      onSongSelected: onSongSelected,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040408),
      body: SafeArea(
        child: Container(
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
            children: [
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 216,
                      child: _DesktopSidebar(
                        selectedTab: selectedTab,
                        onTabChanged: onTabChanged,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          _DesktopTopBar(onTabChanged: onTabChanged),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final showRightPanel = selectedTab != 3 && constraints.maxWidth >= 890;
                                return Row(
                                  children: [
                                    Expanded(
                                      child: _buildMainContent(context),
                                    ),
                                    if (showRightPanel)
                                      SizedBox(
                                        width: constraints.maxWidth > 1200
                                            ? 310
                                            : 270,
                                        child: _buildRightPanel(context),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              BottomPlayer(onOpenPlayer: onOpenPlayer),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  const _DesktopSidebar({
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    const libraryItems = [
      (Icons.queue_music_rounded, 'Playlists'),
      (Icons.album_outlined, 'Albums'),
      (Icons.person_search_outlined, 'Artists'),
      (Icons.favorite_border_rounded, 'Liked Songs'),
      (Icons.history_rounded, 'Recently Played'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF07070D),
        border: Border(right: BorderSide(color: NeoTheme.border)),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 22, 24, 18),
            child: Align(
              alignment: Alignment.centerLeft,
              child: NeoLogo(fontSize: 39, letterSpacing: 2),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _SidebarTile(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  selected: selectedTab == 0,
                  onTap: () => onTabChanged(0),
                ),
                _SidebarTile(
                  icon: Icons.search_rounded,
                  label: 'Search',
                  selected: selectedTab == 1,
                  onTap: () => onTabChanged(1),
                ),
                _SidebarTile(
                  icon: Icons.library_music_outlined,
                  label: 'Library',
                  selected: selectedTab == 2,
                  onTap: () => onTabChanged(2),
                ),
                _SidebarTile(
                  icon: Icons.lock_open_rounded,
                  label: 'Lock Screen',
                  selected: selectedTab == 3,
                  onTap: () => onTabChanged(3),
                ),
                const SizedBox(height: 22),
                const _SidebarLabel('YOUR LIBRARY'),
                const SizedBox(height: 9),
                for (final item in libraryItems)
                  _SidebarTile(
                    icon: item.$1,
                    label: item.$2,
                    selected: selectedTab == 2 && item.$2 == 'Liked Songs',
                    onTap: () => onTabChanged(2),
                  ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: _SidebarLabel('PLAYLISTS')),
                    Icon(
                      Icons.add_circle_outline,
                      color: NeoTheme.textSecondary,
                      size: 19,
                    ),
                    SizedBox(width: 12),
                  ],
                ),
                const SizedBox(height: 9),
                for (final playlist in const ['Chill Vibes', 'Workout Mix', 'Night Drive', 'Feel Good', 'Rock Classics', 'Sad Hours', 'Focus Flow'])
                  _SidebarTile(
                    icon: Icons.music_note_rounded,
                    label: playlist,
                    onTap: () => onTabChanged(2),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: NeoTheme.border)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => onTabChanged(4),
                  child: const _Avatar(radius: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onTabChanged(4),
                    child: Consumer<AuthProvider>(
                      builder: (context, auth, _) => Text(
                        auth.currentUser?.displayName ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                  },
                  child: const Icon(
                    Icons.settings_outlined,
                    color: NeoTheme.textSecondary,
                    size: 19,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarLabel extends StatelessWidget {
  final String label;

  const _SidebarLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14),
      child: Text(
        label,
        style: const TextStyle(
          color: NeoTheme.textHint,
          fontSize: 10,
          letterSpacing: 1.6,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SidebarTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _SidebarTile({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 43,
        margin: const EdgeInsets.only(bottom: 3),
        decoration: BoxDecoration(
          gradient: widget.selected
              ? const LinearGradient(
                  colors: [Color(0xFF4C0A82), Color(0xFF24103D)],
                )
              : _hovered
                  ? const LinearGradient(
                      colors: [Color(0xFF1A0F2E), Color(0xFF13101D)],
                    )
                  : null,
          borderRadius: BorderRadius.circular(8),
          border: widget.selected
              ? const Border(
                  left: BorderSide(color: Color(0xFFB529FF), width: 3),
                )
              : null,
        ),
        child: Row(
          children: [
            const SizedBox(width: 15),
            Icon(
              widget.icon,
              size: 20,
              color: widget.selected ? Colors.white : NeoTheme.textSecondary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                widget.label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: widget.selected
                      ? Colors.white
                      : const Color(0xFFD0CDD8),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _DesktopTopBar extends StatelessWidget {
  final ValueChanged<int> onTabChanged;

  const _DesktopTopBar({required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: NeoTheme.border)),
      ),
      child: Row(
        children: [
          const _RoundIcon(icon: Icons.chevron_left_rounded),
          const SizedBox(width: 8),
          const _RoundIcon(icon: Icons.chevron_right_rounded),
          const SizedBox(width: 18),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 490),
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF111119),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: NeoTheme.border),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: NeoTheme.textSecondary,
                      size: 20,
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'What do you want to play?',
                        style: TextStyle(
                          color: NeoTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.notifications_none_rounded,
            color: NeoTheme.textSecondary,
          ),
          const SizedBox(width: 22),
          GestureDetector(
            onTap: () => onTabChanged(4),
            child: const _Avatar(radius: 18),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => onTabChanged(4),
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) => Text(
                auth.currentUser?.displayName ?? 'User',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: NeoTheme.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _DesktopFeed extends StatefulWidget {
  final ValueChanged<Song> onSongSelected;

  const _DesktopFeed({required this.onSongSelected});

  @override
  State<_DesktopFeed> createState() => _DesktopFeedState();
}

class _DesktopFeedState extends State<_DesktopFeed> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      homeProvider.loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(1, -1),
          radius: 1.3,
          colors: [Color(0x181D0C36), Color(0xFF06060B)],
        ),
      ),
      child: Consumer<HomeProvider>(
        builder: (context, homeProvider, child) {
          if (homeProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: NeoTheme.accentGlow),
            );
          }

          if (homeProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading home feed:\n${homeProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => homeProvider.fetchHomeData(),
                    style: ElevatedButton.styleFrom(backgroundColor: NeoTheme.accent),
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          if (homeProvider.sections.isEmpty) {
            return const Center(
              child: Text(
                'No content available',
                style: TextStyle(color: NeoTheme.textSecondary, fontSize: 18),
              ),
            );
          }

          // +2: 1 for the greeting header, 1 for the bottom loading/retry indicator
          final itemCount = homeProvider.sections.length + 2;

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(24, 24, 22, 36),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                        children: [
                          const TextSpan(text: 'Good Evening, '),
                          TextSpan(
                            text: context.watch<AuthProvider>().currentUser?.displayName ?? 'User',
                            style: const TextStyle(color: NeoTheme.accentGlow),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 27),
                  ],
                );
              }

              // Last item: bottom loading/retry indicator
              if (index == itemCount - 1) {
                return _PaginationFooter(
                  isLoadingMore: homeProvider.isLoadingMore,
                  hasMore: homeProvider.hasMore,
                  paginationError: homeProvider.paginationError,
                  onRetry: () => homeProvider.retryLoadMore(),
                );
              }
              
              final section = homeProvider.sections[index - 1];
              return HomepageWidgetFactory.build(section);
            },
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text(
            'See all',
            style: TextStyle(color: NeoTheme.accentGlow, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _SongCard extends StatefulWidget {
  final Song song;
  final VoidCallback onTap;

  const _SongCard({required this.song, required this.onTap});

  @override
  State<_SongCard> createState() => _SongCardState();
}

class _SongCardState extends State<_SongCard> {
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
                      colors: widget.song.colors,
                      seed: widget.song.artworkSeed,
                      borderRadius: BorderRadius.circular(10),
                      imagePath: widget.song.imagePath,
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: _hovered ? 1 : 0.7,
                    duration: const Duration(milliseconds: 200),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        width: 31,
                        height: 31,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _hovered
                              ? NeoTheme.accent
                              : const Color(0xD9090810),
                          shape: BoxShape.circle,
                          boxShadow: _hovered
                              ? [
                                  const BoxShadow(
                                    color: Color(0x558B5CF6),
                                    blurRadius: 12,
                                  ),
                                ]
                              : null,
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
              widget.song.title,
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
              widget.song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(color: NeoTheme.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistCard extends StatefulWidget {
  final Playlist playlist;

  const _PlaylistCard({required this.playlist});

  @override
  State<_PlaylistCard> createState() => _PlaylistCardState();
}

class _PlaylistCardState extends State<_PlaylistCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: Matrix4.diagonal3Values(
          _hovered ? 1.02 : 1.0,
          _hovered ? 1.02 : 1.0,
          1.0,
        ),
        transformAlignment: Alignment.center,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF12081F),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _hovered
                ? const Color(0xFF5A2D80)
                : const Color(0xFF2C1943),
          ),
          boxShadow: _hovered
              ? [
                  const BoxShadow(
                    color: Color(0x338B5CF6),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.35,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NeoCoverArt(
                    colors: widget.playlist.colors,
                    seed: widget.playlist.artworkSeed,
                    showOrbit: false,
                    borderRadius: BorderRadius.zero,
                    imagePath: widget.playlist.imagePath,
                  ),
                  if (_hovered)
                    Container(
                      color: const Color(0x20000000),
                      alignment: Alignment.center,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: NeoTheme.accentGradient,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x558B5CF6),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.playlist.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.playlist.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: NeoTheme.textSecondary,
                      height: 1.35,
                      fontSize: 10,
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

class _NowPlayingPanel extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final bool liked;
  final VoidCallback onLiked;
  final VoidCallback onPlayPause;
  final VoidCallback onOpenPlayer;
  final ValueChanged<Song> onSongSelected;

  const _NowPlayingPanel({
    required this.song,
    required this.isPlaying,
    required this.liked,
    required this.onLiked,
    required this.onPlayPause,
    required this.onOpenPlayer,
    required this.onSongSelected,
  });

  Widget _buildTrackList(BuildContext context) {
    final queue = context.watch<PlayerProvider>().queue;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF08080E),
        border: Border(left: BorderSide(color: NeoTheme.border)),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          const Text(
            'Now Playing',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: onOpenPlayer,
            borderRadius: BorderRadius.circular(12),
            child: Hero(
              tag: 'now-playing-art',
              child: AspectRatio(
                aspectRatio: 1,
                child: NeoCoverArt(
                  colors: song.colors,
                  seed: song.artworkSeed,
                  borderRadius: BorderRadius.circular(12),
                  imagePath: song.imagePath,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
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
                    const SizedBox(height: 5),
                    Text(
                      song.artist,
                      style: const TextStyle(
                        color: NeoTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onLiked,
                icon: Icon(
                  liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: liked ? NeoTheme.accent : NeoTheme.textSecondary,
                  size: 21,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const _ProgressBar(progress: .42),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '1:34',
                style: TextStyle(color: NeoTheme.textSecondary, fontSize: 10),
              ),
              Text(
                song.duration,
                style: const TextStyle(
                  color: NeoTheme.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.shuffle_rounded,
                color: NeoTheme.textSecondary,
                size: 20,
              ),
              const Icon(
                Icons.skip_previous_rounded,
                color: Colors.white,
                size: 27,
              ),
              _PlayButton(
                isPlaying: isPlaying,
                onPressed: onPlayPause,
                radius: 24,
              ),
              const Icon(
                Icons.skip_next_rounded,
                color: Colors.white,
                size: 27,
              ),
              const Icon(
                Icons.repeat_rounded,
                color: NeoTheme.textSecondary,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: NeoTheme.border),
          const SizedBox(height: 9),
          const Text(
            'Next In Queue',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          for (final item in queue)
            InkWell(
              onTap: () => onSongSelected(item),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 38,
                      height: 38,
                      child: NeoCoverArt(
                        colors: item.colors,
                        seed: item.artworkSeed,
                        borderRadius: BorderRadius.circular(7),
                        imagePath: item.imagePath,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.artist,
                            style: const TextStyle(
                              color: NeoTheme.textSecondary,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.more_vert_rounded,
                      color: NeoTheme.textSecondary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _buildTrackList(context);
}

class _DesktopPlayerBar extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final bool liked;
  final VoidCallback onLiked;
  final VoidCallback onPlayPause;
  final VoidCallback onOpenPlayer;

  const _DesktopPlayerBar({
    required this.song,
    required this.isPlaying,
    required this.liked,
    required this.onLiked,
    required this.onPlayPause,
    required this.onOpenPlayer,
  });

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();
    double progress = 0.0;
    if (playerProvider.duration.inMilliseconds > 0) {
      progress = playerProvider.position.inMilliseconds / playerProvider.duration.inMilliseconds;
    }
    progress = progress.clamp(0.0, 1.0);

    String formatDuration(Duration d) {
      final minutes = d.inMinutes;
      final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
      return '$minutes:$seconds';
    }

    return Material(
      color: const Color(0xFF090910),
      child: InkWell(
        onTap: onOpenPlayer,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: NeoTheme.border)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 310,
                child: Row(
                  children: [
                    SizedBox(
                      width: 62,
                      height: 62,
                      child: NeoCoverArt(
                        colors: song.colors,
                        seed: song.artworkSeed,
                        borderRadius: BorderRadius.circular(8),
                        imagePath: song.imagePath,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                            song.artist,
                            style: const TextStyle(
                              color: NeoTheme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onLiked,
                      icon: Icon(
                        liked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: liked ? NeoTheme.accent : NeoTheme.textSecondary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.shuffle_rounded,
                          color: NeoTheme.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 24),
                        const Icon(
                          Icons.skip_previous_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 20),
                        _PlayButton(
                          isPlaying: isPlaying,
                          onPressed: onPlayPause,
                          radius: 25,
                        ),
                        const SizedBox(width: 20),
                        const Icon(
                          Icons.skip_next_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 24),
                        const Icon(
                          Icons.repeat_rounded,
                          color: NeoTheme.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          formatDuration(playerProvider.position),
                          style: const TextStyle(
                            color: NeoTheme.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: _ProgressBar(progress: progress)),
                        const SizedBox(width: 10),
                        Text(
                          formatDuration(playerProvider.duration),
                          style: const TextStyle(
                            color: NeoTheme.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 275,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.queue_music_rounded,
                      color: NeoTheme.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.devices_rounded,
                      color: NeoTheme.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.volume_up_outlined,
                      color: NeoTheme.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    SizedBox(width: 85, child: _ProgressBar(progress: playerProvider.volume)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileHome extends StatelessWidget {
  final Song currentSong;
  final bool isPlaying;
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final ValueChanged<Song> onSongSelected;
  final VoidCallback onPlayPause;
  final VoidCallback onOpenPlayer;

  const _MobileHome({
    required this.currentSong,
    required this.isPlaying,
    required this.selectedTab,
    required this.onTabChanged,
    required this.onSongSelected,
    required this.onPlayPause,
    required this.onOpenPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _buildTabContent(),
              ),
            ),
            BottomPlayer(onOpenPlayer: onOpenPlayer),
            _MobileNavigation(selected: selectedTab, onChanged: onTabChanged),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTab) {
      case 0:
        return _MobileHomeFeed(
          key: const ValueKey('home'),
          onSongSelected: onSongSelected,
        );
      case 1:
        return SearchScreen(
          key: const ValueKey('search'),
          onSongSelected: onSongSelected,
        );
      case 2:
        return LibraryScreen(
          key: const ValueKey('library'),
          onSongSelected: onSongSelected,
        );
      case 3:
        return const PremiumScreen(key: ValueKey('premium'));
      case 4:
        return ProfileScreen(
          key: const ValueKey('profile'),
          onSongSelected: onSongSelected,
        );
      default:
        return _MobileHomeFeed(
          key: const ValueKey('home'),
          onSongSelected: onSongSelected,
        );
    }
  }
}

class _MobileHomeFeed extends StatefulWidget {
  final ValueChanged<Song> onSongSelected;

  const _MobileHomeFeed({super.key, required this.onSongSelected});

  @override
  State<_MobileHomeFeed> createState() => _MobileHomeFeedState();
}

class _MobileHomeFeedState extends State<_MobileHomeFeed> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      homeProvider.loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(1, -1),
          radius: 1,
          colors: [Color(0x281F0B38), NeoTheme.background],
        ),
      ),
      child: Consumer<HomeProvider>(
        builder: (context, homeProvider, child) {
          if (homeProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: NeoTheme.accentGlow),
            );
          }

          if (homeProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading feed:\n${homeProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => homeProvider.fetchHomeData(),
                    style: ElevatedButton.styleFrom(backgroundColor: NeoTheme.accent),
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          if (homeProvider.sections.isEmpty) {
            return const Center(
              child: Text(
                'No content available',
                style: TextStyle(color: NeoTheme.textSecondary, fontSize: 16),
              ),
            );
          }

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          NeoLogo(fontSize: 29, letterSpacing: 1.6),
                          Spacer(),
                          Icon(
                            Icons.notifications_none_rounded,
                            color: NeoTheme.textSecondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                          ),
                          children: [
                            const TextSpan(text: 'Good Evening, '),
                            TextSpan(
                              text: context.watch<AuthProvider>().currentUser?.displayName ?? 'User',
                              style: const TextStyle(
                                color: NeoTheme.accentGlow,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: homeProvider.sections.length,
                itemBuilder: (context, index) {
                  final section = homeProvider.sections[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: HomepageWidgetFactory.build(section),
                  );
                },
              ),
              // Bottom pagination indicator
              SliverToBoxAdapter(
                child: _PaginationFooter(
                  isLoadingMore: homeProvider.isLoadingMore,
                  hasMore: homeProvider.hasMore,
                  paginationError: homeProvider.paginationError,
                  onRetry: () => homeProvider.retryLoadMore(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Shared bottom-of-list indicator for pagination state.
/// Shows a spinner while loading, a retry button on error, or nothing when done.
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
    // Error state — show retry
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

    // Loading state — show spinner
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

    // All content loaded — subtle end marker
    if (!hasMore) {
      return const SizedBox(height: 16);
    }

    // Default: nothing (shouldn't normally be visible)
    return const SizedBox.shrink();
  }
}

class _MobileSongCard extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const _MobileSongCard({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                NeoCoverArt(
                  colors: song.colors,
                  seed: song.artworkSeed,
                  borderRadius: BorderRadius.circular(10),
                  imagePath: song.imagePath,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xD9090810),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            song.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: NeoTheme.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileMiniPlayer extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onPlayPause;

  const _MobileMiniPlayer({
    required this.song,
    required this.isPlaying,
    required this.onTap,
    required this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: const Color(0xFF170A24),
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(11),
          child: Container(
            height: 64,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: const Color(0xFF472266)),
            ),
            child: Row(
              children: [
                Hero(
                  tag: 'mini-player-art',
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: NeoCoverArt(
                      colors: song.colors,
                      seed: song.artworkSeed,
                      borderRadius: BorderRadius.circular(7),
                      imagePath: song.imagePath,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        song.artist,
                        style: const TextStyle(
                          color: NeoTheme.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onPlayPause,
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
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

class _MobileNavigation extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _MobileNavigation({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const destinations = [
      (Icons.home_rounded, 'Home'),
      (Icons.search_rounded, 'Search'),
      (Icons.library_music_outlined, 'Library'),
      (Icons.workspace_premium_outlined, 'Premium'),
      (Icons.person_outline_rounded, 'Profile'),
    ];
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFF07070C),
        border: Border(top: BorderSide(color: NeoTheme.border)),
      ),
      child: Row(
        children: [
          for (var index = 0; index < destinations.length; index++)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: selected == index ? 4 : 0,
                      height: selected == index ? 4 : 0,
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: const BoxDecoration(
                        color: NeoTheme.accentGlow,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Icon(
                      destinations[index].$1,
                      color: selected == index
                          ? NeoTheme.accent
                          : NeoTheme.textSecondary,
                      size: 23,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      destinations[index].$2,
                      style: TextStyle(
                        color: selected == index
                            ? NeoTheme.accentGlow
                            : NeoTheme.textSecondary,
                        fontSize: 9,
                        fontWeight: selected == index
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPressed;
  final double radius;

  const _PlayButton({
    required this.isPlaying,
    required this.onPressed,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: NeoTheme.accentGradient,
        boxShadow: [BoxShadow(color: Color(0x558B20FF), blurRadius: 16)],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: radius,
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;

  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFF24222D),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: NeoTheme.accentGradient,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;

  const _RoundIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFF101018),
        shape: BoxShape.circle,
        border: Border.all(color: NeoTheme.border),
      ),
      child: Icon(icon, color: NeoTheme.textSecondary, size: 20),
    );
  }
}

class _Avatar extends StatelessWidget {
  final double radius;

  const _Avatar({required this.radius});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF14264F),
      child: const Icon(
        Icons.person_rounded,
        color: Color(0xFFEBD7FF),
        size: 20,
      ),
    );
  }
}

class _LibraryQueuePanel extends StatelessWidget {
  final Song currentSong;
  final ValueChanged<Song> onSongSelected;
  final VoidCallback onClearQueue;

  const _LibraryQueuePanel({
    required this.currentSong,
    required this.onSongSelected,
    required this.onClearQueue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF08080E),
        border: Border(left: BorderSide(color: NeoTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Playing Queue',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.close_rounded,
                    color: NeoTheme.textSecondary,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          Consumer<HomeProvider>(
            builder: (context, homeProvider, child) {
              final songs = homeProvider.recentlyPlayed;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                final isActive = song == currentSong;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF1E0A30) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isActive
                        ? Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3))
                        : null,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    leading: NeoCoverArt(
                      colors: song.colors,
                      seed: song.artworkSeed,
                      imagePath: song.imagePath,
                      size: 40,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    title: Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isActive ? Colors.white : const Color(0xFFE5E5E9),
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: NeoTheme.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isActive)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.equalizer_rounded,
                              color: Color(0xFFA855F7),
                              size: 16,
                            ),
                          ),
                        Text(
                          song.duration,
                          style: const TextStyle(
                            color: NeoTheme.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => onSongSelected(song),
                  ),
                  );
                },
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: onClearQueue,
                icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white, size: 16),
                label: const Text(
                  'Clear Queue',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF32234C)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  backgroundColor: const Color(0xFF0F0B1E),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
