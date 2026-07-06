import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/player_provider.dart';
import '../models/song.dart';

import '../widgets/neo_cover_art.dart';

class LockScreenControlsScreen extends StatefulWidget {
  const LockScreenControlsScreen({super.key});

  @override
  State<LockScreenControlsScreen> createState() => _LockScreenControlsScreenState();
}

class _LockScreenControlsScreenState extends State<LockScreenControlsScreen> {
  bool _isPlayingLock = true;
  bool _isLikedLock = true;

  bool _isPlayingWidget = true;
  bool _isLikedWidget = true;

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();
    final currentSong = playerProvider.currentTrack;
    
    if (currentSong == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text('No song playing', style: TextStyle(color: Colors.white))),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 950;
        return Scaffold(
          backgroundColor: const Color(0xFF030306),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 40,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFE9D5FF), Color(0xFFA855F7), Color(0xFFC4B5FD)],
                    stops: [0.0, 0.5, 1.0],
                  ).createShader(bounds),
                  child: const Text(
                    'NEO LOCK SCREEN CONTROLS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Full music control right from your lock screen',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF9E9EB3),
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Main body layout
                isMobile
                    ? Column(
                        children: [
                          _buildPhoneMockup(currentSong),
                          const SizedBox(height: 40),
                          _buildWidgetsPanel(currentSong),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: _buildPhoneMockup(currentSong),
                            ),
                          ),
                          const SizedBox(width: 40),
                          Expanded(
                            flex: 6,
                            child: _buildWidgetsPanel(currentSong),
                          ),
                        ],
                      ),

                const SizedBox(height: 48),
                // Secure & Seamless Banner
                _buildSecureBanner(isMobile),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // PHONE MOCKUP
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildPhoneMockup(Song currentSong) {
    return Container(
      width: 320,
      height: 670,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(42),
        border: Border.all(color: const Color(0xFF4E4E5A), width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x7F000000),
            blurRadius: 40,
            offset: Offset(0, 16),
          ),
          BoxShadow(
            color: Color(0x3B8B5CF6),
            blurRadius: 60,
            spreadRadius: -10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background cosmic wallpaper
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.2),
                  radius: 1.2,
                  colors: [
                    Color(0xFF240E42),
                    Color(0xFF040409),
                  ],
                ),
              ),
            ),
            // Background planet painting effect
            Positioned(
              bottom: 80,
              left: -80,
              right: -80,
              child: Image.asset(
                'assets/images/albums/album1.jpg',
                height: 380,
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.18),
              ),
            ),
            // Wallpaper details - subtle stars or colors
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xEE040409)],
                ),
              ),
            ),

            // Dynamic Island
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 95,
                  height: 25,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            // Top Status Bar
            const Positioned(
              top: 13,
              left: 22,
              child: Text(
                'Airtel',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
            const Positioned(
              top: 13,
              right: 22,
              child: Row(
                children: [
                  Icon(Icons.signal_cellular_4_bar_rounded, color: Colors.white, size: 11),
                  SizedBox(width: 4),
                  Icon(Icons.wifi_rounded, color: Colors.white, size: 11),
                  SizedBox(width: 4),
                  Icon(Icons.battery_5_bar_rounded, color: Colors.white, size: 12),
                ],
              ),
            ),

            // Date & Time
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const Icon(Icons.lock_rounded, color: Colors.white, size: 16),
                  const SizedBox(height: 8),
                  const Text(
                    'Saturday, 25 May',
                    style: TextStyle(
                      color: Color(0xFFC4B5FD),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFE9D5FF), Color(0xFFD8B4FE)],
                    ).createShader(bounds),
                    child: const Text(
                      '10:42',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 66,
                        fontWeight: FontWeight.w300,
                        letterSpacing: -1,
                        height: 1.15,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Center Lock Screen Widget (After Hours)
            Positioned(
              bottom: 96,
              left: 12,
              right: 12,
              child: _buildLockScreenPlayerWidget(currentSong),
            ),

            // Bottom Buttons (Flashlight & Camera)
            Positioned(
              bottom: 24,
              left: 20,
              child: _buildCircleToolButton(Icons.flashlight_on_rounded),
            ),
            Positioned(
              bottom: 24,
              right: 20,
              child: _buildCircleToolButton(Icons.camera_alt_rounded),
            ),

            // iPhone Home Bar Indicator
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 104,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleToolButton(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Center(
        child: Icon(icon, color: Colors.white, size: 19),
      ),
    );
  }

  Widget _buildLockScreenPlayerWidget(Song currentSong) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xE50B0813),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF382352), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3B8B5CF6),
            blurRadius: 18,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              NeoCoverArt(
                colors: currentSong.colors,
                seed: currentSong.artworkSeed,
                imagePath: currentSong.imagePath,
                size: 48,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NEO',
                      style: TextStyle(
                        color: Color(0xFFA855F7),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentSong.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentSong.artist,
                      style: const TextStyle(
                        color: Color(0xFF9E9EB3),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() => _isLikedLock = !_isLikedLock);
                },
                icon: Icon(
                  _isLikedLock ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: _isLikedLock ? const Color(0xFFA855F7) : const Color(0xFF686881),
                  size: 19,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3.2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
              activeTrackColor: const Color(0xFFA855F7),
              inactiveTrackColor: const Color(0xFF2C1E3F),
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: 0.42,
              onChanged: (val) {},
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1:34', style: TextStyle(color: Color(0xFF686881), fontSize: 10)),
                Text('3:46', style: TextStyle(color: Color(0xFF686881), fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () {
                  setState(() => _isPlayingLock = !_isPlayingLock);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFA855F7),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _isPlayingLock ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // WIDGETS PANEL
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildWidgetsPanel(Song currentSong) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pitch text
        const Text(
          'YES!',
          style: TextStyle(
            color: Color(0xFFA855F7),
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'NEO will show beautiful music controls on your lock screen so you can play, pause, skip or go back anytime.',
          style: TextStyle(
            color: Color(0xFF9E9EB3),
            fontSize: 14,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 32),

        // Widget 1: On Lock Screen
        _buildWidgetHeader(Icons.lock_outline_rounded, 'On Lock Screen'),
        const SizedBox(height: 8),
        _buildLockScreenPreviewWidget(currentSong),

        const SizedBox(height: 28),
        // Widget 2: In Notification
        _buildWidgetHeader(Icons.notifications_none_rounded, 'In Notification'),
        const SizedBox(height: 8),
        _buildNotificationWidget(currentSong),

        const SizedBox(height: 28),
        // Widget 3: Bluetooth/Car Display
        _buildWidgetHeader(Icons.bluetooth_rounded, 'On Bluetooth / Car Display'),
        const SizedBox(height: 8),
        _buildCarDisplayWidget(currentSong),
      ],
    );
  }

  Widget _buildWidgetHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFA855F7), size: 17),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF8B5CF6),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLockScreenPreviewWidget(Song currentSong) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E1C29)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              NeoCoverArt(
                colors: currentSong.colors,
                seed: currentSong.artworkSeed,
                imagePath: currentSong.imagePath,
                size: 44,
                borderRadius: BorderRadius.circular(6),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NEO',
                      style: TextStyle(color: Color(0xFFA855F7), fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentSong.title,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentSong.artist,
                      style: const TextStyle(color: Color(0xFF686881), fontSize: 10),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() => _isLikedWidget = !_isLikedWidget);
                },
                icon: Icon(
                  _isLikedWidget ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: _isLikedWidget ? const Color(0xFFA855F7) : const Color(0xFF686881),
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 3),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 6),
              activeTrackColor: const Color(0xFFA855F7),
              inactiveTrackColor: const Color(0xFF1E152D),
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: 0.44,
              onChanged: (val) {},
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1:24', style: TextStyle(color: Color(0xFF51516A), fontSize: 9)),
                Text('3:20', style: TextStyle(color: Color(0xFF51516A), fontSize: 9)),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() => _isPlayingWidget = !_isPlayingWidget);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFA855F7),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _isPlayingWidget ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationWidget(Song currentSong) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E1C29)),
      ),
      child: Row(
        children: [
          NeoCoverArt(
            colors: currentSong.colors,
            seed: currentSong.artworkSeed,
            imagePath: currentSong.imagePath,
            size: 38,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'NEO',
                  style: TextStyle(color: Color(0xFFA855F7), fontSize: 8, fontWeight: FontWeight.bold),
                ),
                Text(
                  currentSong.title,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
                Text(
                  currentSong.artist,
                  style: const TextStyle(color: Color(0xFF686881), fontSize: 9),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 22),
          ),
          IconButton(
            onPressed: () {
              setState(() => _isPlayingWidget = !_isPlayingWidget);
            },
            icon: Icon(
              _isPlayingWidget ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildCarDisplayWidget(Song currentSong) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E1C29)),
      ),
      child: Row(
        children: [
          // Left Sidebar in Car Display Mock
          Container(
            width: 42,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF07070B),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(11), bottomLeft: Radius.circular(11)),
              border: Border(right: BorderSide(color: Color(0xFF1E1C29))),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.home_outlined, color: Color(0xFF686881), size: 16),
                Icon(Icons.music_note_rounded, color: Colors.pinkAccent, size: 16),
                Icon(Icons.phone_outlined, color: Color(0xFF686881), size: 16),
                Icon(Icons.grid_view_rounded, color: Color(0xFF686881), size: 15),
              ],
            ),
          ),
          // Main Body of Car Display
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  NeoCoverArt(
                    colors: currentSong.colors,
                    seed: currentSong.artworkSeed,
                    imagePath: currentSong.imagePath,
                    size: 68,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentSong.title,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentSong.artist,
                          style: const TextStyle(color: Color(0xFF686881), fontSize: 10),
                        ),
                        const SizedBox(height: 6),
                        // Mini Play controls
                        Row(
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {},
                              icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 21),
                            ),
                            const SizedBox(width: 14),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                setState(() => _isPlayingWidget = !_isPlayingWidget);
                              },
                              icon: Icon(
                                _isPlayingWidget ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 21,
                              ),
                            ),
                            const SizedBox(width: 14),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {},
                              icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 21),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Track timeline inside Car Display
                        Row(
                          children: [
                            const Text('1:24', style: TextStyle(color: Color(0xFF51516A), fontSize: 9)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E152D),
                                  borderRadius: BorderRadius.circular(1.5),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: 0.44,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFA855F7),
                                        borderRadius: BorderRadius.circular(1.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('3:20', style: TextStyle(color: Color(0xFF51516A), fontSize: 9)),
                          ],
                        ),
                      ],
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

  // ═══════════════════════════════════════════════════════════════════
  // SECURE & SEAMLESS BANNER
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildSecureBanner(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0813),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F1230), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0x1B8B5CF6),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.check_circle_rounded, color: Color(0xFFA855F7), size: 21),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Secure & Seamless',
                  style: TextStyle(
                    color: Color(0xFFA855F7),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isMobile
                      ? 'Controls available without unlocking. Privacy always protected.'
                      : 'Controls are available without unlocking your phone. Your privacy and security are always protected.',
                  style: const TextStyle(
                    color: Color(0xFF9E9EB3),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const Icon(Icons.lock_rounded, color: Color(0xFF8B5CF6), size: 19),
        ],
      ),
    );
  }
}
