import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/player_provider.dart';
import '../services/auth_provider.dart';
import '../models/song.dart';
import '../theme/neo_theme.dart';
import '../widgets/neo_cover_art.dart';
import '../widgets/neo_logo.dart';

class PlaybackScreen extends StatefulWidget {
  final Song? initialSong;
  final bool initiallyPlaying;

  const PlaybackScreen({
    super.key,
    this.initialSong,
    this.initiallyPlaying = true,
  });

  @override
  State<PlaybackScreen> createState() => _PlaybackScreenState();
}

class _PlaybackScreenState extends State<PlaybackScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _liked = true;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: .88,
      upperBound: 1,
      value: 1,
    );

    // After the first frame, check if we need to start playing a new initialSong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
        if (widget.initialSong != null &&
            playerProvider.currentTrack?.title != widget.initialSong!.title) {
          playerProvider.playTrack(widget.initialSong!);
        } else if (widget.initiallyPlaying && !playerProvider.isPlaying) {
          playerProvider.togglePlayPause();
        }
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context).pop();

  void _selectSong(Song song) {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    playerProvider.playTrack(song);
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();
    final song = playerProvider.currentTrack ?? widget.initialSong;
    if (song == null) return const SizedBox.shrink();
    final isPlaying = playerProvider.isPlaying;
    
    if (isPlaying && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!isPlaying && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 1;
    }

    double progress = 0.0;
    if (playerProvider.duration.inMilliseconds > 0) {
      progress = playerProvider.position.inMilliseconds / playerProvider.duration.inMilliseconds;
    }
    progress = progress.clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return _MobilePlayer(
            song: song,
            isPlaying: isPlaying,
            liked: _liked,
            shuffle: playerProvider.shuffleEnabled,
            repeat: playerProvider.repeatMode != PlayerRepeatMode.off,
            progress: progress,
            pulse: _pulseController,
            onClose: _close,
            onPlayPause: playerProvider.togglePlayPause,
            onShuffle: playerProvider.toggleShuffle,
            onRepeat: playerProvider.cycleRepeatMode,
            onLiked: () => setState(() => _liked = !_liked),
            onProgress: (value) {
              final newPosition = Duration(
                milliseconds: (value * playerProvider.duration.inMilliseconds).round()
              );
              playerProvider.seek(newPosition);
            },
          );
        }

        return _DesktopPlayer(
          song: song,
          isPlaying: isPlaying,
          liked: _liked,
          shuffle: playerProvider.shuffleEnabled,
          repeat: playerProvider.repeatMode != PlayerRepeatMode.off,
          progress: progress,
          volume: playerProvider.volume,
          pulse: _pulseController,
          onClose: _close,
          onPlayPause: playerProvider.togglePlayPause,
          onLiked: () => setState(() => _liked = !_liked),
          onShuffle: playerProvider.toggleShuffle,
          onRepeat: playerProvider.cycleRepeatMode,
          onProgress: (value) {
            final newPosition = Duration(
              milliseconds: (value * playerProvider.duration.inMilliseconds).round()
            );
            playerProvider.seek(newPosition);
          },
          onVolume: (value) => playerProvider.setVolumeLevel(value),
          onSongSelected: _selectSong,
        );
      },
    );
  }
}

class _DesktopPlayer extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final bool liked;
  final bool shuffle;
  final bool repeat;
  final double progress;
  final double volume;
  final Animation<double> pulse;
  final VoidCallback onClose;
  final VoidCallback onPlayPause;
  final VoidCallback onLiked;
  final VoidCallback onShuffle;
  final VoidCallback onRepeat;
  final ValueChanged<double> onProgress;
  final ValueChanged<double> onVolume;
  final ValueChanged<Song> onSongSelected;

  const _DesktopPlayer({
    required this.song,
    required this.isPlaying,
    required this.liked,
    required this.shuffle,
    required this.repeat,
    required this.progress,
    required this.volume,
    required this.pulse,
    required this.onClose,
    required this.onPlayPause,
    required this.onLiked,
    required this.onShuffle,
    required this.onRepeat,
    required this.onProgress,
    required this.onVolume,
    required this.onSongSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030306),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(18),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: NeoTheme.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: NeoTheme.border),
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 205,
                      child: _PlayerSidebar(onClose: onClose),
                    ),
                    Expanded(
                      child: _PlayerCenter(
                        song: song,
                        isPlaying: isPlaying,
                        liked: liked,
                        shuffle: shuffle,
                        repeat: repeat,
                        progress: progress,
                        pulse: pulse,
                        onClose: onClose,
                        onPlayPause: onPlayPause,
                        onLiked: onLiked,
                        onShuffle: onShuffle,
                        onRepeat: onRepeat,
                        onProgress: onProgress,
                      ),
                    ),
                    SizedBox(
                      width: 285,
                      child: _QueuePanel(
                        currentSong: song,
                        onSongSelected: onSongSelected,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 92,
                child: _PlayerFooter(
                  song: song,
                  isPlaying: isPlaying,
                  liked: liked,
                  volume: volume,
                  onPlayPause: onPlayPause,
                  onLiked: onLiked,
                  onVolume: onVolume,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerSidebar extends StatelessWidget {
  final VoidCallback onClose;

  const _PlayerSidebar({required this.onClose});

  @override
  Widget build(BuildContext context) {
    const primary = [
      (Icons.home_outlined, 'Home'),
      (Icons.search_rounded, 'Search'),
      (Icons.library_music_outlined, 'Library'),
    ];
    const library = [
      (Icons.queue_music_rounded, 'Playlists'),
      (Icons.album_outlined, 'Albums'),
      (Icons.person_outline_rounded, 'Artists'),
      (Icons.favorite_border_rounded, 'Liked Songs'),
      (Icons.history_rounded, 'Recently Played'),
    ];
    const playlists = [
      'Chill Vibes',
      'Night Drive',
      'Workout Mix',
      'Rock Classics',
      'Sad Hours',
      'Focus Flow',
    ];

    return Container(
      color: const Color(0xFF07070D),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 18, 16),
            child: Row(
              children: [
                const NeoLogo(fontSize: 34, letterSpacing: 1.5),
                const Spacer(),
                IconButton(
                  tooltip: 'Back to home',
                  onPressed: onClose,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: NeoTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                for (var index = 0; index < primary.length; index++)
                  _PlayerNavTile(
                    icon: primary[index].$1,
                    label: primary[index].$2,
                    selected: index == 2,
                  ),
                const SizedBox(height: 18),
                const _PlayerNavLabel('YOUR LIBRARY'),
                const SizedBox(height: 7),
                for (final item in library)
                  _PlayerNavTile(icon: item.$1, label: item.$2),
                const SizedBox(height: 17),
                const _PlayerNavLabel('PLAYLISTS'),
                const SizedBox(height: 7),
                for (final item in playlists)
                  _PlayerNavTile(icon: Icons.music_note_outlined, label: item),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 15,
                  backgroundColor: Color(0xFF172850),
                  child: Icon(Icons.person, color: Colors.white, size: 17),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Consumer<AuthProvider>(
                    builder: (context, auth, _) => Text(
                      auth.currentUser?.displayName ?? 'User',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                const Icon(
                  Icons.settings_outlined,
                  color: NeoTheme.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerNavLabel extends StatelessWidget {
  final String label;

  const _PlayerNavLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 13),
      child: Text(
        label,
        style: const TextStyle(
          color: NeoTheme.textHint,
          fontSize: 9,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _PlayerNavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _PlayerNavTile({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 3),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF2B0B48) : null,
        borderRadius: BorderRadius.circular(7),
        border: selected
            ? const Border(
                left: BorderSide(color: NeoTheme.accentGlow, width: 3),
              )
            : null,
      ),
      child: Row(
        children: [
          const SizedBox(width: 13),
          Icon(
            icon,
            size: 18,
            color: selected ? NeoTheme.accentGlow : NeoTheme.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFFD1CDDA),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerCenter extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final bool liked;
  final bool shuffle;
  final bool repeat;
  final double progress;
  final Animation<double> pulse;
  final VoidCallback onClose;
  final VoidCallback onPlayPause;
  final VoidCallback onLiked;
  final VoidCallback onShuffle;
  final VoidCallback onRepeat;
  final ValueChanged<double> onProgress;

  const _PlayerCenter({
    required this.song,
    required this.isPlaying,
    required this.liked,
    required this.shuffle,
    required this.repeat,
    required this.progress,
    required this.pulse,
    required this.onClose,
    required this.onPlayPause,
    required this.onLiked,
    required this.onShuffle,
    required this.onRepeat,
    required this.onProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: NeoTheme.border),
          right: BorderSide(color: NeoTheme.border),
        ),
        gradient: RadialGradient(
          center: Alignment(0, -.2),
          radius: .8,
          colors: [Color(0x182D0C54), Color(0xFF06060B)],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 18, 12),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Back',
                  onPressed: onClose,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: NeoTheme.textSecondary,
                  ),
                ),
                const Text(
                  'Now Playing',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF3B175D)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                  ),
                  icon: const Icon(Icons.lyrics_outlined, size: 15),
                  label: const Text('Lyrics', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 560;
                final artSize = math.min(
                  constraints.maxWidth * .42,
                  compact
                      ? constraints.maxHeight * .46
                      : constraints.maxHeight * .53,
                );
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(32, 20, 32, 25),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: artSize,
                            height: artSize,
                            child: AnimatedBuilder(
                              animation: pulse,
                              builder: (context, child) {
                                return DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: NeoTheme.accent.withValues(
                                          alpha: .18 * pulse.value,
                                        ),
                                        blurRadius: 45 * pulse.value,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: child,
                                );
                              },
                              child: NeoCoverArt(
                                colors: song.colors,
                                seed: song.artworkSeed,
                                borderRadius: BorderRadius.circular(16),
                                imagePath: song.imagePath,
                              ),
                            ),
                          ),
                          SizedBox(width: compact ? 25 : 38),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 260),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        song.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: onLiked,
                                      icon: Icon(
                                        liked
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_border_rounded,
                                        color: NeoTheme.accent,
                                        size: 22,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  song.artist,
                                  style: const TextStyle(
                                    color: NeoTheme.accentGlow,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  song.album,
                                  style: const TextStyle(
                                    color: NeoTheme.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Wrap(
                                  spacing: 8,
                                  children: [
                                    _QualityChip('320 kbps'),
                                    _QualityChip('44.1 kHz'),
                                  ],
                                ),
                                SizedBox(height: compact ? 22 : 56),
                                const Row(
                                  children: [
                                    _ActionItem(
                                      icon: Icons.playlist_add_rounded,
                                      label: 'Add to Playlist',
                                    ),
                                    SizedBox(width: 35),
                                    _ActionItem(
                                      icon: Icons.share_outlined,
                                      label: 'Share',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: compact ? 24 : 48),
                      SizedBox(
                        height: 52,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: _WavePainter(progress: progress),
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            '1:34',
                            style: TextStyle(
                              color: NeoTheme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              value: progress,
                              onChanged: onProgress,
                            ),
                          ),
                          Text(
                            song.duration,
                            style: const TextStyle(
                              color: NeoTheme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: onShuffle,
                            icon: Icon(
                              Icons.shuffle_rounded,
                              color: shuffle
                                  ? NeoTheme.accent
                                  : NeoTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 28),
                          const Icon(
                            Icons.skip_previous_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                          const SizedBox(width: 28),
                          _LargePlayButton(
                            isPlaying: isPlaying,
                            onPressed: onPlayPause,
                          ),
                          const SizedBox(width: 28),
                          const Icon(
                            Icons.skip_next_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                          const SizedBox(width: 28),
                          IconButton(
                            onPressed: onRepeat,
                            icon: Icon(
                              Icons.repeat_rounded,
                              color: repeat
                                  ? NeoTheme.accent
                                  : NeoTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QualityChip extends StatelessWidget {
  final String label;

  const _QualityChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFF612291)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: NeoTheme.accentGlow, fontSize: 11),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 7),
        Text(
          label,
          style: const TextStyle(color: NeoTheme.textSecondary, fontSize: 10),
        ),
      ],
    );
  }
}

class _QueuePanel extends StatelessWidget {
  final Song currentSong;
  final ValueChanged<Song> onSongSelected;

  const _QueuePanel({required this.currentSong, required this.onSongSelected});

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();
    return Container(
      color: const Color(0xFF08080E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 15),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Playing Queue',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  Icons.close_rounded,
                  color: NeoTheme.textSecondary,
                  size: 19,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: playerProvider.queue.length,
              itemBuilder: (context, index) {
                final song = playerProvider.queue[index];
                final selected = song == currentSong;
                return InkWell(
                  onTap: () => onSongSelected(song),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: selected
                          ? const LinearGradient(
                              colors: [Color(0xFF3D0B67), Color(0xFF220B3A)],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      border: selected
                          ? const Border(
                              left: BorderSide(
                                color: NeoTheme.accentGlow,
                                width: 3,
                              ),
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 42,
                          height: 42,
                          child: NeoCoverArt(
                            colors: song.colors,
                            seed: song.artworkSeed,
                            borderRadius: BorderRadius.circular(6),
                            imagePath: song.imagePath,
                          ),
                        ),
                        const SizedBox(width: 10),
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
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                song.artist,
                                style: const TextStyle(
                                  color: NeoTheme.textSecondary,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.equalizer_rounded,
                            color: NeoTheme.accentGlow,
                            size: 19,
                          )
                        else
                          Text(
                            song.duration,
                            style: const TextStyle(
                              color: NeoTheme.textSecondary,
                              fontSize: 9,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(18),
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  color: NeoTheme.textSecondary,
                  size: 18,
                ),
                SizedBox(width: 10),
                Text(
                  'Clear Queue',
                  style: TextStyle(color: NeoTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerFooter extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final bool liked;
  final double volume;
  final VoidCallback onPlayPause;
  final VoidCallback onLiked;
  final ValueChanged<double> onVolume;

  const _PlayerFooter({
    required this.song,
    required this.isPlaying,
    required this.liked,
    required this.volume,
    required this.onPlayPause,
    required this.onLiked,
    required this.onVolume,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Color(0xFF090910),
        border: Border(top: BorderSide(color: NeoTheme.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 290,
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: NeoCoverArt(
                    colors: song.colors,
                    seed: song.artworkSeed,
                    borderRadius: BorderRadius.circular(7),
                    imagePath: song.imagePath,
                  ),
                ),
                const SizedBox(width: 12),
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
                    color: NeoTheme.accent,
                    size: 21,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.skip_previous_rounded,
                  color: Colors.white,
                  size: 27,
                ),
                const SizedBox(width: 36),
                _LargePlayButton(
                  isPlaying: isPlaying,
                  onPressed: onPlayPause,
                  size: 47,
                ),
                const SizedBox(width: 36),
                const Icon(
                  Icons.skip_next_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 260,
            child: Row(
              children: [
                const Icon(
                  Icons.queue_music_rounded,
                  color: NeoTheme.textSecondary,
                  size: 19,
                ),
                const SizedBox(width: 15),
                const Icon(
                  Icons.devices_rounded,
                  color: NeoTheme.textSecondary,
                  size: 19,
                ),
                const SizedBox(width: 15),
                const Icon(
                  Icons.volume_up_outlined,
                  color: NeoTheme.textSecondary,
                  size: 19,
                ),
                Expanded(
                  child: Slider(value: volume, onChanged: onVolume),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobilePlayer extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final bool liked;
  final bool shuffle;
  final bool repeat;
  final double progress;
  final Animation<double> pulse;
  final VoidCallback onClose;
  final VoidCallback onPlayPause;
  final VoidCallback onLiked;
  final VoidCallback onShuffle;
  final VoidCallback onRepeat;
  final ValueChanged<double> onProgress;

  const _MobilePlayer({
    required this.song,
    required this.isPlaying,
    required this.liked,
    required this.shuffle,
    required this.repeat,
    required this.progress,
    required this.pulse,
    required this.onClose,
    required this.onPlayPause,
    required this.onLiked,
    required this.onShuffle,
    required this.onRepeat,
    required this.onProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoTheme.background,
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(.8, -.6),
              radius: 1.15,
              colors: [Color(0x321D0A39), NeoTheme.background],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SizedBox(
                  height: 68,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Playing from',
                              style: TextStyle(
                                color: NeoTheme.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Liked Songs',
                              style: TextStyle(
                                color: NeoTheme.accentGlow,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.more_vert_rounded, color: Colors.white),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final artSize = math.min(
                        constraints.maxWidth,
                        constraints.maxHeight * .52,
                      );
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            SizedBox(
                              width: artSize,
                              height: artSize,
                              child: AnimatedBuilder(
                                animation: pulse,
                                builder: (context, child) {
                                  return DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: NeoTheme.accent.withValues(
                                            alpha: .2 * pulse.value,
                                          ),
                                          blurRadius: 35 * pulse.value,
                                        ),
                                      ],
                                    ),
                                    child: child,
                                  );
                                },
                                child: NeoCoverArt(
                                  colors: song.colors,
                                  seed: song.artworkSeed,
                                  borderRadius: BorderRadius.circular(15),
                                  imagePath: song.imagePath,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        song.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 25,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 7),
                                      Text(
                                        song.artist,
                                        style: const TextStyle(
                                          color: NeoTheme.accentGlow,
                                          fontSize: 17,
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
                                    color: NeoTheme.accent,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 21),
                            Slider(value: progress, onChanged: onProgress),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '1:34',
                                  style: TextStyle(
                                    color: NeoTheme.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  song.duration,
                                  style: const TextStyle(
                                    color: NeoTheme.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: onShuffle,
                                  icon: Icon(
                                    Icons.shuffle_rounded,
                                    color: shuffle
                                        ? NeoTheme.accent
                                        : NeoTheme.textSecondary,
                                  ),
                                ),
                                const Icon(
                                  Icons.skip_previous_rounded,
                                  color: Colors.white,
                                  size: 36,
                                ),
                                _LargePlayButton(
                                  isPlaying: isPlaying,
                                  onPressed: onPlayPause,
                                  size: 64,
                                ),
                                const Icon(
                                  Icons.skip_next_rounded,
                                  color: Colors.white,
                                  size: 36,
                                ),
                                IconButton(
                                  onPressed: onRepeat,
                                  icon: Icon(
                                    Icons.repeat_rounded,
                                    color: repeat
                                        ? NeoTheme.accent
                                        : NeoTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _ActionItem(
                                  icon: Icons.playlist_add_rounded,
                                  label: 'Add to Playlist',
                                ),
                                _ActionItem(
                                  icon: Icons.lyrics_outlined,
                                  label: 'Lyrics',
                                ),
                                _ActionItem(
                                  icon: Icons.more_horiz_rounded,
                                  label: 'More',
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                          ],
                        ),
                      );
                    },
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

class _LargePlayButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPressed;
  final double size;

  const _LargePlayButton({
    required this.isPlaying,
    required this.onPressed,
    this.size = 62,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: NeoTheme.accentGradient,
        boxShadow: [BoxShadow(color: Color(0x55851AFF), blurRadius: 18)],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: size * .48,
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;

  const _WavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const bars = 70;
    final barWidth = size.width / (bars * 1.8);
    final spacing = (size.width - barWidth * bars) / (bars - 1);
    for (var index = 0; index < bars; index++) {
      final normalized = index / bars;
      final wave =
          .25 +
          .45 * math.sin(index * .71).abs() +
          .25 * math.sin(index * .17 + 1.5).abs();
      final height = size.height * wave;
      final x = index * (barWidth + spacing);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, (size.height - height) / 2, barWidth, height),
        const Radius.circular(4),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = normalized <= progress
              ? NeoTheme.accentGlow
              : NeoTheme.accent.withValues(alpha: .35),
      );
    }
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
