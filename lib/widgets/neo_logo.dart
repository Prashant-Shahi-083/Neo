import 'package:flutter/material.dart';

class NeoLogo extends StatelessWidget {
  final double fontSize;
  final double letterSpacing;

  const NeoLogo({super.key, this.fontSize = 60, this.letterSpacing = 6});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: fontSize * 1.2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow layer
          _LogoRow(
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            isGlow: true,
          ),

          // Main layer
          _LogoRow(
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            isGlow: false,
          ),
        ],
      ),
    );
  }
}

class _LogoRow extends StatelessWidget {
  final double fontSize;
  final double letterSpacing;
  final bool isGlow;

  const _LogoRow({
    required this.fontSize,
    required this.letterSpacing,
    required this.isGlow,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isGlow ? const Color(0xFFA855F7) : const Color(0xFFF5ECFF);
    final shadowColor = const Color(0xFFA855F7);

    final textStyle = TextStyle(
      fontFamily: "Orbitron",
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: textColor,
      shadows: isGlow
          ? null
          : [
              Shadow(color: shadowColor, blurRadius: 20),
              Shadow(color: shadowColor, blurRadius: 40),
            ],
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // N
        Text("N", style: textStyle),
        SizedBox(width: letterSpacing),

        // E (≡)
        _FuturisticE(
          size: fontSize,
          color: textColor,
          isGlow: isGlow,
          shadowColor: shadowColor,
        ),
        SizedBox(width: letterSpacing),

        // O
        Text("O", style: textStyle),
      ],
    );
  }
}

class _FuturisticE extends StatelessWidget {
  final double size;
  final Color color;
  final bool isGlow;
  final Color shadowColor;

  const _FuturisticE({
    required this.size,
    required this.color,
    required this.isGlow,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    final thickness = size * 0.08;
    final width = size * 0.58;
    final totalHeight = size * 0.72;

    final bar = Container(
      width: width,
      height: thickness,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(thickness / 2),
        boxShadow: isGlow
            ? [
                BoxShadow(
                  color: shadowColor.withValues(alpha: 0.85),
                  blurRadius: 18,
                  spreadRadius: 2.5,
                ),
              ]
            : [
                BoxShadow(
                  color: shadowColor.withValues(alpha: 0.6),
                  blurRadius: 14,
                ),
                BoxShadow(
                  color: shadowColor.withValues(alpha: 0.4),
                  blurRadius: 28,
                ),
              ],
      ),
    );

    return SizedBox(
      height: totalHeight,
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          bar,
          bar,
          bar,
        ],
      ),
    );
  }
}
