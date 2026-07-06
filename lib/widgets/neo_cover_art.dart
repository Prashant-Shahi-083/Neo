import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NeoCoverArt extends StatelessWidget {
  final List<Color> colors;
  final int seed;
  final double? size;
  final BorderRadius borderRadius;
  final bool showOrbit;
  final String? imagePath;

  const NeoCoverArt({
    super.key,
    required this.colors,
    required this.seed,
    this.size,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.showOrbit = true,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final Widget art;
    if (imagePath != null && imagePath!.isNotEmpty) {
      if (imagePath!.startsWith('http')) {
        art = CachedNetworkImage(
          imageUrl: imagePath!,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => CustomPaint(
            painter: _CoverPainter(colors: colors, seed: seed, showOrbit: showOrbit),
            child: const SizedBox.expand(),
          ),
          placeholder: (context, url) => CustomPaint(
            painter: _CoverPainter(colors: colors, seed: seed, showOrbit: showOrbit),
            child: const SizedBox.expand(),
          ),
        );
      } else {
        art = Image.asset(
          imagePath!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return CustomPaint(
              painter: _CoverPainter(colors: colors, seed: seed, showOrbit: showOrbit),
              child: const SizedBox.expand(),
            );
          },
        );
      }
    } else {
      art = CustomPaint(
        painter: _CoverPainter(colors: colors, seed: seed, showOrbit: showOrbit),
        child: const SizedBox.expand(),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(borderRadius: borderRadius, child: art),
    );
  }
}

class _CoverPainter extends CustomPainter {
  final List<Color> colors;
  final int seed;
  final bool showOrbit;

  const _CoverPainter({
    required this.colors,
    required this.seed,
    required this.showOrbit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final random = math.Random(seed);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ).createShader(rect),
    );

    canvas.drawCircle(
      Offset(size.width * .78, size.height * .16),
      size.shortestSide * .42,
      Paint()
        ..shader = RadialGradient(
          colors: [colors.last.withValues(alpha: .62), Colors.transparent],
        ).createShader(rect),
    );

    for (var index = 0; index < 34; index++) {
      final radius = random.nextDouble() * 1.35 + .25;
      final point = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height * .72,
      );
      canvas.drawCircle(
        point,
        radius,
        Paint()
          ..color = Colors.white.withValues(
            alpha: .18 + random.nextDouble() * .52,
          ),
      );
    }

    final mountain = Path()
      ..moveTo(0, size.height * .78)
      ..lineTo(size.width * .18, size.height * .56)
      ..lineTo(size.width * .32, size.height * .72)
      ..lineTo(size.width * .49, size.height * .48)
      ..lineTo(size.width * .66, size.height * .7)
      ..lineTo(size.width * .82, size.height * .56)
      ..lineTo(size.width, size.height * .72)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      mountain,
      Paint()..color = const Color(0xFF07050F).withValues(alpha: .88),
    );

    if (showOrbit) {
      final orbitRect = Rect.fromCircle(
        center: Offset(size.width * .5, size.height * .43),
        radius: size.shortestSide * .32,
      );
      canvas.drawArc(
        orbitRect,
        math.pi * .1,
        math.pi * 1.8,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.4, size.shortestSide * .012)
          ..shader = SweepGradient(
            colors: [
              Colors.transparent,
              colors.last,
              const Color(0xFFF3D8FF),
              colors.last,
              Colors.transparent,
            ],
          ).createShader(orbitRect)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }

    final personX = size.width * (.44 + random.nextDouble() * .12);
    final personY = size.height * .68;
    final personPaint = Paint()..color = const Color(0xFF080710);
    canvas.drawCircle(
      Offset(personX, personY - size.height * .095),
      size.shortestSide * .035,
      personPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(personX, personY - size.height * .035),
          width: size.width * .075,
          height: size.height * .13,
        ),
        Radius.circular(size.shortestSide * .02),
      ),
      personPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(0, size.height * .78, size.width, size.height * .22),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors[1].withValues(alpha: .28), const Color(0xFF05040A)],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_CoverPainter oldDelegate) {
    return oldDelegate.seed != seed ||
        oldDelegate.colors != colors ||
        oldDelegate.showOrbit != showOrbit;
  }
}
