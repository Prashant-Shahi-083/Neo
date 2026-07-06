import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/player_provider.dart';
import '../../theme/neo_theme.dart';
import '../neo_cover_art.dart';

class BottomPlayer extends StatelessWidget {
  final VoidCallback onOpenPlayer;

  const BottomPlayer({super.key, required this.onOpenPlayer});

  String _formatDuration(Duration d) {
    String minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerProvider>();
    final song = provider.currentTrack;

    if (song == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 760;

        return GestureDetector(
          onTap: onOpenPlayer,
          child: Container(
            height: isMobile ? 64 : 88,
            margin: isMobile
                ? const EdgeInsets.symmetric(horizontal: 8, vertical: 8)
                : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: isMobile ? NeoTheme.surface : NeoTheme.background,
              borderRadius: isMobile ? BorderRadius.circular(16) : BorderRadius.zero,
              border: Border(
                top: BorderSide(
                  color: NeoTheme.border.withOpacity(0.5),
                ),
                bottom: isMobile ? BorderSide(color: NeoTheme.border.withOpacity(0.5)) : BorderSide.none,
                left: isMobile ? BorderSide(color: NeoTheme.border.withOpacity(0.5)) : BorderSide.none,
                right: isMobile ? BorderSide(color: NeoTheme.border.withOpacity(0.5)) : BorderSide.none,
              ),
            ),
            child: isMobile
                ? _buildMobilePlayer(context, provider, song)
                : _buildDesktopPlayer(context, provider, song),
          ),
        );
      },
    );
  }

  Widget _buildMobilePlayer(BuildContext context, PlayerProvider provider, song) {
    return Column(
      children: [
        SizedBox(
          height: 2,
          child: LinearProgressIndicator(
            value: provider.duration.inMilliseconds > 0
                ? provider.position.inMilliseconds / provider.duration.inMilliseconds
                : 0.0,
            backgroundColor: Colors.transparent,
            valueColor: const AlwaysStoppedAnimation<Color>(NeoTheme.accent),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: NeoCoverArt(
                    imagePath: song.coverUrl,
                    colors: song.colors,
                    seed: song.artworkSeed,
                    borderRadius: BorderRadius.circular(8),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: NeoTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    provider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                  onPressed: provider.togglePlayPause,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopPlayer(BuildContext context, PlayerProvider provider, song) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Left: Song Info
          Expanded(
            flex: 1,
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: NeoCoverArt(
                    imagePath: song.coverUrl,
                    colors: song.colors,
                    seed: song.artworkSeed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: NeoTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Center: Controls & Progress
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.shuffle_rounded,
                        color: provider.shuffleEnabled ? NeoTheme.accent : NeoTheme.textSecondary,
                        size: 20,
                      ),
                      onPressed: provider.toggleShuffle,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
                      onPressed: provider.playPrevious,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                      child: IconButton(
                        icon: Icon(
                          provider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.black,
                        ),
                        onPressed: provider.togglePlayPause,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                      onPressed: provider.playNext,
                    ),
                    IconButton(
                      icon: Icon(
                        provider.repeatMode == PlayerRepeatMode.one
                            ? Icons.repeat_one_rounded
                            : Icons.repeat_rounded,
                        color: provider.repeatMode != PlayerRepeatMode.off ? NeoTheme.accent : NeoTheme.textSecondary,
                        size: 20,
                      ),
                      onPressed: provider.cycleRepeatMode,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _formatDuration(provider.position),
                      style: const TextStyle(color: NeoTheme.textHint, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 24,
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: NeoTheme.border,
                            thumbColor: Colors.white,
                          ),
                          child: Slider(
                            value: provider.duration.inMilliseconds > 0 
                                ? (provider.position.inMilliseconds / provider.duration.inMilliseconds).clamp(0.0, 1.0)
                                : 0.0,
                            onChanged: (val) {
                              final pos = provider.duration * val;
                              provider.seek(pos);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDuration(provider.duration),
                      style: const TextStyle(color: NeoTheme.textHint, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Right: Volume
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.volume_up_rounded, color: NeoTheme.textSecondary, size: 20),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  height: 24,
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: NeoTheme.border,
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: provider.volume,
                      onChanged: (val) => provider.setVolumeLevel(val),
                    ),
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
