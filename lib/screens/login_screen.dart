import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main_screen.dart';
import '../theme/neo_theme.dart';
import '../widgets/neo_logo.dart';
import '../services/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final AnimationController _entryController;
  late final AnimationController _spaceController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _spaceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
    _fade = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, .06), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
        );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _entryController.dispose();
    _spaceController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    // Close keyboard
    FocusScope.of(context).unfocus();

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final authProvider = context.read<AuthProvider>();
    
    // AuthProvider manages the loading state, but for smooth UI we keep local state
    setState(() => _submitting = true);
    
    final success = await authProvider.login(username, password);
    
    if (!mounted) return;
    
    setState(() => _submitting = false);

    if (success) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (_, animation, secondaryAnimation) => const MainScreen(),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 450),
        ),
      );
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Authentication failed.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showPasswordHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Password recovery will be connected with authentication.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _spaceController,
        builder: (context, child) {
          return CustomPaint(
            painter: _SpacePainter(phase: _spaceController.value),
            child: child,
          );
        },
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;
              final mobile = constraints.maxWidth < 620;

              final loginContent = SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  mobile ? 18 : 30,
                  mobile ? 32 : 42,
                  mobile ? 18 : 30,
                  28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(),
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!isDesktop) ...[
                            NeoLogo(
                              fontSize: mobile ? 62 : 82,
                              letterSpacing: mobile ? 7 : 11,
                            ),
                            const SizedBox(height: 7),
                            Text(
                              'MUSIC WITHOUT LIMITS',
                              style: TextStyle(
                                color: const Color(0xFFAAA4B9),
                                fontSize: mobile ? 9 : 11,
                                letterSpacing: mobile ? 3.8 : 5,
                              ),
                            ),
                            SizedBox(height: mobile ? 28 : 36),
                          ],
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isDesktop ? 480 : 600,
                            ),
                            child: _LoginCard(
                              formKey: _formKey,
                              usernameController: _usernameController,
                              passwordController: _passwordController,
                              obscurePassword: _obscurePassword,
                              rememberMe: _rememberMe,
                              submitting: _submitting,
                              mobile: mobile,
                              onTogglePassword: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                              onRememberChanged: (value) {
                                setState(() => _rememberMe = value ?? false);
                              },
                              onForgotPassword: _showPasswordHelp,
                              onLogin: _login,
                            ),
                          ),
                          const SizedBox(height: 26),
                          const Text(
                            'NEO v1.0',
                            style: TextStyle(
                              color: Color(0xFF696477),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '© ${DateTime.now().year} NEO. All rights reserved.',
                            style: const TextStyle(
                              color: Color(0xFF514B5E),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
              if (isDesktop) {
                return Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: FadeTransition(
                        opacity: _fade,
                        child: SlideTransition(
                          position: _slide,
                          child: const _DesktopHeroSection(),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: loginContent,
                    ),
                  ],
                );
              }

              return loginContent;
            },
          ),
        ),
      ),
    );
  }
}

class _DesktopHeroSection extends StatelessWidget {
  const _DesktopHeroSection();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          const NeoLogo(
            fontSize: 110,
            letterSpacing: 14,
          ),
          const SizedBox(height: 12),
          const Text(
            'MUSIC WITHOUT LIMITS',
            style: TextStyle(
              color: Color(0xFFAAA4B9),
              fontSize: 16,
              letterSpacing: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0x33FFFFFF)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 40,
                  offset: Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.format_quote_rounded,
                  color: NeoTheme.accentGlow,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'The most premium audio experience ever built for the web. Discover new artists, curate your perfect library, and listen without limits.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    height: 1.4,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: NeoTheme.accent.withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: NeoTheme.accent),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.high_quality, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('Lossless Audio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1B2E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF383252)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.offline_bolt_rounded, color: Color(0xFF9D97AE), size: 20),
                          SizedBox(width: 8),
                          Text('Offline Mode', style: TextStyle(color: Color(0xFF9D97AE), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool rememberMe;
  final bool submitting;
  final bool mobile;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onForgotPassword;
  final VoidCallback onLogin;

  const _LoginCard({
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberMe,
    required this.submitting,
    required this.mobile,
    required this.onTogglePassword,
    required this.onRememberChanged,
    required this.onForgotPassword,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        mobile ? 20 : 48,
        mobile ? 28 : 42,
        mobile ? 20 : 48,
        mobile ? 24 : 36,
      ),
      decoration: BoxDecoration(
        color: const Color(0xE80A0812),
        borderRadius: BorderRadius.circular(mobile ? 24 : 34),
        border: Border.all(color: const Color(0xFF422565), width: 1.3),
        boxShadow: const [
          BoxShadow(color: Color(0x442D0751), blurRadius: 55, spreadRadius: 2),
          BoxShadow(
            color: Color(0xAA000000),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Welcome Back',
              style: TextStyle(
                color: Colors.white,
                fontSize: mobile ? 27 : 32,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Log in to your NEO account',
              style: TextStyle(
                color: const Color(0xFFAAA5B7),
                fontSize: mobile ? 14 : 16,
              ),
            ),
            SizedBox(height: mobile ? 30 : 38),
            TextFormField(
              controller: usernameController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [
                AutofillHints.username,
                AutofillHints.email,
              ],
              style: const TextStyle(color: Colors.white),
              decoration: _fieldDecoration(
                label: 'Username / Email',
                hint: 'Enter your username or email',
                icon: Icons.person_outline_rounded,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your username or email';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => onLogin(),
              style: const TextStyle(color: Colors.white),
              decoration:
                  _fieldDecoration(
                    label: 'Password',
                    hint: 'Enter your password',
                    icon: Icons.lock_outline_rounded,
                  ).copyWith(
                    suffixIcon: IconButton(
                      onPressed: onTogglePassword,
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF9D97AE),
                      ),
                    ),
                  ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 4) {
                  return 'Password must contain at least 4 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                SizedBox(
                  width: 34,
                  height: 34,
                  child: Checkbox(
                    value: rememberMe,
                    onChanged: onRememberChanged,
                    activeColor: NeoTheme.accent,
                    checkColor: Colors.white,
                    side: const BorderSide(color: NeoTheme.accentGlow),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                const Text(
                  'Remember Me',
                  style: TextStyle(color: Color(0xFFE5E1EB), fontSize: 13),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onForgotPassword,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: NeoTheme.accentGlow, fontSize: 13),
                  ),
                ),
              ],
            ),
            SizedBox(height: mobile ? 19 : 26),
            SizedBox(
              width: double.infinity,
              height: 61,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: NeoTheme.accentGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x667B22F4),
                      blurRadius: 28,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: submitting ? null : onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: submitting
                      ? const SizedBox(
                          width: 23,
                          height: 23,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 18),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Row(
              children: [
                Expanded(child: Divider(color: Color(0xFF2A2634))),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(
                    Icons.music_note_rounded,
                    color: NeoTheme.accent,
                    size: 20,
                  ),
                ),
                Expanded(child: Divider(color: Color(0xFF2A2634))),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0x2B000000),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF381F54), width: 1.2),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    color: NeoTheme.accentGlow,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Your music. Your account.\nSecure. Private. Yours.',
                    style: TextStyle(
                      color: Color(0xFF8D879A),
                      fontSize: 11,
                      height: 1.4,
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

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    const borderColor = Color(0xFF312C3E);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: NeoTheme.accentGlow, fontSize: 13),
      floatingLabelStyle: const TextStyle(
        color: NeoTheme.accentGlow,
        fontSize: 14,
      ),
      hintStyle: const TextStyle(color: Color(0xFF777181), fontSize: 14),
      prefixIcon: Icon(icon, color: NeoTheme.accentGlow),
      filled: true,
      fillColor: const Color(0x9A08070D),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: NeoTheme.accentGlow, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE05D8A)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE05D8A), width: 1.4),
      ),
    );
  }
}

class _SpacePainter extends CustomPainter {
  final double phase;

  const _SpacePainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF020206), Color(0xFF080511), Color(0xFF020207)],
        ).createShader(rect),
    );

    final nebulaCenter = Offset(size.width * .91, size.height * .26);
    final nebulaRect = Rect.fromCircle(
      center: nebulaCenter,
      radius: size.shortestSide * .55,
    );
    canvas.drawCircle(
      nebulaCenter,
      size.shortestSide * .55,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(
              const Color(0xAA8A16E8),
              const Color(0xCCB239FF),
              phase,
            )!,
            const Color(0x553D086B),
            Colors.transparent,
          ],
          stops: const [0, .42, 1],
        ).createShader(nebulaRect),
    );

    final random = math.Random(92);
    for (var index = 0; index < 125; index++) {
      final point = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      final radius = random.nextDouble() * 1.15 + .2;
      final twinkle = .25 + .55 * ((index.isEven ? phase : 1 - phase));
      canvas.drawCircle(
        point,
        radius,
        Paint()
          ..color = (index % 5 == 0 ? NeoTheme.accentGlow : Colors.white)
              .withValues(alpha: twinkle),
      );
    }

    final planetRadius = math.max(size.width, size.height) * .28;
    final planetCenter = Offset(-planetRadius * 0.42, size.height * 0.48);
    final planetRect = Rect.fromCircle(
      center: planetCenter,
      radius: planetRadius,
    );
    canvas.drawCircle(
      planetCenter,
      planetRadius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(.45, -.35),
          colors: [Color(0xFF25144D), Color(0xFF0A071A), Color(0xFF020207)],
          stops: [0, .62, 1],
        ).createShader(planetRect),
    );

    final glowPaint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..shader = const SweepGradient(
        colors: [
          Colors.transparent,
          Color(0xAA9B4DFF),
          Color(0xAAF0D7FF),
          Color(0xAA8C27EE),
          Colors.transparent,
        ],
      ).createShader(planetRect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    final glowPaint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..shader = const SweepGradient(
        colors: [
          Colors.transparent,
          Color(0xFFB566FF),
          Color(0xFFFFFFFF),
          Color(0xFFB566FF),
          Colors.transparent,
        ],
      ).createShader(planetRect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawArc(planetRect, -math.pi * .52, math.pi * .64, false, glowPaint1);
    canvas.drawArc(planetRect, -math.pi * .52, math.pi * .64, false, glowPaint2);
  }

  @override
  bool shouldRepaint(_SpacePainter oldDelegate) => oldDelegate.phase != phase;
}
