import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/neo_theme.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 760;
        return Scaffold(
          backgroundColor: NeoTheme.background,
          body: Stack(
            children: [
              // ── Decorative background ──
              const _BackgroundOrbs(),

              // ── Content ──
              SafeArea(
                child: CustomScrollView(
                  slivers: [
                    // Top bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 20 : 40,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: NeoTheme.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Restore Purchase',
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

                    // ── Hero header ──
                    SliverToBoxAdapter(
                      child: _HeroHeader(isMobile: isMobile),
                    ),

                    // ── Feature cards ──
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 20 : 60,
                        vertical: 16,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _FeatureSection(isMobile: isMobile),
                      ),
                    ),

                    // ── Pricing cards ──
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 20 : 60,
                        vertical: 8,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _PricingSection(isMobile: isMobile),
                      ),
                    ),

                    // ── CTA Button ──
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 20 : 60,
                        vertical: 20,
                      ),
                      sliver: const SliverToBoxAdapter(
                        child: _CtaButton(),
                      ),
                    ),

                    // ── Fine print ──
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Text(
                          '7 days free, cancel anytime',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: NeoTheme.textHint,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// BACKGROUND ORBS
// ═══════════════════════════════════════════════════════════════════

class _BackgroundOrbs extends StatelessWidget {
  const _BackgroundOrbs();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // Top-center purple orb
          Positioned(
            top: -120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      NeoTheme.accent.withValues(alpha: .18),
                      NeoTheme.accent.withValues(alpha: .04),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Bottom-left orb
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6D28D9).withValues(alpha: .10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Bottom-right subtle orb
          Positioned(
            bottom: 100,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    NeoTheme.accentGlow.withValues(alpha: .06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Subtle grid / dot pattern overlay
          Positioned.fill(
            child: CustomPaint(painter: _DotPatternPainter()),
          ),
        ],
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NeoTheme.border.withValues(alpha: .15)
      ..strokeWidth = 1;

    const spacing = 48.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.6, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════
// HERO HEADER
// ═══════════════════════════════════════════════════════════════════

class _HeroHeader extends StatelessWidget {
  final bool isMobile;

  const _HeroHeader({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 12,
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Crown badge
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: NeoTheme.accentGradient,
              boxShadow: [
                BoxShadow(
                  color: NeoTheme.accent.withValues(alpha: .45),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.diamond_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),

          const SizedBox(height: 28),

          // Title with glow
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFE9D5FF), Colors.white, Color(0xFFC4B5FD)],
              stops: [0.0, 0.5, 1.0],
            ).createShader(bounds),
            child: Text(
              'NEO Premium',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 36 : 48,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Subtitle
          const Text(
            'Unlock the full experience',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: NeoTheme.textSecondary,
              fontSize: 17,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// FEATURE SECTION
// ═══════════════════════════════════════════════════════════════════

class _FeatureSection extends StatelessWidget {
  final bool isMobile;

  const _FeatureSection({required this.isMobile});

  static const _features = [
    _FeatureData(
      emoji: '🎵',
      title: 'Ad-free music',
      description: 'Enjoy uninterrupted listening without any ads',
    ),
    _FeatureData(
      emoji: '🎧',
      title: 'High quality audio',
      description: 'Stream in 320kbps & lossless FLAC quality',
    ),
    _FeatureData(
      emoji: '📱',
      title: 'Offline downloads',
      description: 'Save songs and listen anywhere, anytime',
    ),
    _FeatureData(
      emoji: '🔀',
      title: 'Unlimited skips',
      description: 'Skip as many tracks as you want, no limits',
    ),
    _FeatureData(
      emoji: '🎤',
      title: 'Lyrics display',
      description: 'Sing along with real-time synced lyrics',
    ),
    _FeatureData(
      emoji: '👥',
      title: 'Group listening',
      description: 'Host listening sessions with your friends',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Everything you get',
            style: TextStyle(
              color: NeoTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = isMobile
                ? 1
                : (constraints.maxWidth > 700 ? 3 : 2);
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: _features.map((f) {
                final cardWidth = isMobile
                    ? constraints.maxWidth
                    : (constraints.maxWidth - 14 * (columns - 1)) / columns;
                return SizedBox(
                  width: cardWidth,
                  child: _FeatureCard(feature: f),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _FeatureData {
  final String emoji;
  final String title;
  final String description;

  const _FeatureData({
    required this.emoji,
    required this.title,
    required this.description,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureData feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: NeoTheme.card.withValues(alpha: .55),
            border: Border.all(
              color: NeoTheme.border.withValues(alpha: .6),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                NeoTheme.card.withValues(alpha: .7),
                NeoTheme.surface.withValues(alpha: .4),
              ],
            ),
          ),
          child: Row(
            children: [
              // Emoji container
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: NeoTheme.accent.withValues(alpha: .12),
                  border: Border.all(
                    color: NeoTheme.accent.withValues(alpha: .2),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  feature.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.title,
                      style: const TextStyle(
                        color: NeoTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature.description,
                      style: const TextStyle(
                        color: NeoTheme.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.check_circle_rounded,
                color: NeoTheme.accent.withValues(alpha: .7),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// PRICING SECTION
// ═══════════════════════════════════════════════════════════════════

class _PricingSection extends StatelessWidget {
  final bool isMobile;

  const _PricingSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Choose your plan',
            style: TextStyle(
              color: NeoTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        isMobile
            ? Column(
                children: [
                  _PricingCard(
                    title: 'Individual',
                    price: '₹119',
                    period: '/month',
                    features: const [
                      '1 account',
                      'Ad-free music',
                      'Offline downloads',
                    ],
                    isBestValue: false,
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 14),
                  _PricingCard(
                    title: 'Family',
                    price: '₹179',
                    period: '/month',
                    features: const [
                      'Up to 6 accounts',
                      'Ad-free music',
                      'Offline downloads',
                      'Family mix playlist',
                    ],
                    isBestValue: true,
                    isMobile: isMobile,
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _PricingCard(
                      title: 'Individual',
                      price: '₹119',
                      period: '/month',
                      features: const [
                        '1 account',
                        'Ad-free music',
                        'Offline downloads',
                      ],
                      isBestValue: false,
                      isMobile: isMobile,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _PricingCard(
                      title: 'Family',
                      price: '₹179',
                      period: '/month',
                      features: const [
                        'Up to 6 accounts',
                        'Ad-free music',
                        'Offline downloads',
                        'Family mix playlist',
                      ],
                      isBestValue: true,
                      isMobile: isMobile,
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}

class _PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final List<String> features;
  final bool isBestValue;
  final bool isMobile;

  const _PricingCard({
    required this.title,
    required this.price,
    required this.period,
    required this.features,
    required this.isBestValue,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isBestValue
                ? NeoTheme.accent.withValues(alpha: .08)
                : NeoTheme.card.withValues(alpha: .6),
            border: Border.all(
              color: isBestValue
                  ? NeoTheme.accent.withValues(alpha: .6)
                  : NeoTheme.border.withValues(alpha: .5),
              width: isBestValue ? 1.5 : 1,
            ),
            boxShadow: isBestValue
                ? [
                    BoxShadow(
                      color: NeoTheme.accent.withValues(alpha: .12),
                      blurRadius: 30,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge + Title row
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: NeoTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (isBestValue)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: NeoTheme.accentGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Best Value',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 18),

              // Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      color: isBestValue ? NeoTheme.accentGlow : Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 2),
                    child: Text(
                      period,
                      style: const TextStyle(
                        color: NeoTheme.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Container(
                height: 1,
                color: NeoTheme.border.withValues(alpha: .4),
              ),
              const SizedBox(height: 16),

              // Features list
              ...features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_rounded,
                        color: isBestValue
                            ? NeoTheme.accentGlow
                            : NeoTheme.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          f,
                          style: const TextStyle(
                            color: NeoTheme.textPrimary,
                            fontSize: 14,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
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

// ═══════════════════════════════════════════════════════════════════
// CTA BUTTON
// ═══════════════════════════════════════════════════════════════════

class _CtaButton extends StatelessWidget {
  const _CtaButton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: NeoTheme.accentGradient,
            boxShadow: [
              BoxShadow(
                color: NeoTheme.accent.withValues(alpha: .45),
                blurRadius: 28,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: NeoTheme.accentGlow.withValues(alpha: .20),
                blurRadius: 60,
                spreadRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.rocket_launch_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Start Free Trial',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
