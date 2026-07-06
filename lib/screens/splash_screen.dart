import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/neo_theme.dart';
import '../widgets/neo_logo.dart';
import 'authentication_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    Timer(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (_, animation, secondaryAnimation) =>
              const AuthenticationGate(),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 550),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            radius: .7,
            colors: [Color(0xFF24103D), NeoTheme.background],
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NeoLogo(fontSize: 78, letterSpacing: 7),
                SizedBox(height: 15),
                Text(
                  'MUSIC WITHOUT LIMITS',
                  style: TextStyle(
                    color: NeoTheme.textSecondary,
                    fontSize: 10,
                    letterSpacing: 4,
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
