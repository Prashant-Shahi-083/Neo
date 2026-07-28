import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_provider.dart';
import 'login_screen.dart';
import '../main_screen.dart';

class AuthenticationGate extends StatefulWidget {
  const AuthenticationGate({super.key});

  @override
  State<AuthenticationGate> createState() => _AuthenticationGateState();
}

class _AuthenticationGateState extends State<AuthenticationGate> {
  @override
  void initState() {
    super.initState();
    print('🚪 [AUTHENTICATION GATE] [${DateTime.now().toIso8601String()}] initState() called. Scheduling restoreSession()...');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🚪 [AUTHENTICATION GATE] [${DateTime.now().toIso8601String()}] PostFrameCallback executing restoreSession()...');
      context.read<AuthProvider>().restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        print('🚪 [AUTHENTICATION GATE] [${DateTime.now().toIso8601String()}] build(): auth.isLoading=${auth.isLoading}, auth.isAuthenticated=${auth.isAuthenticated}');
        if (auth.isLoading) {
          print('🚪 [AUTHENTICATION GATE] [${DateTime.now().toIso8601String()}] -> Rendering CircularProgressIndicator (loading screen)');
          return const Scaffold(
            backgroundColor: Color(0xFF020206),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF8A16E8)),
            ),
          );
        }
        
        if (auth.isAuthenticated) {
          print('🚪 [AUTHENTICATION GATE] [${DateTime.now().toIso8601String()}] -> Rendering MainScreen()');
          return const MainScreen();
        } else {
          print('🚪 [AUTHENTICATION GATE] [${DateTime.now().toIso8601String()}] -> Rendering LoginScreen()');
          return const LoginScreen();
        }
      },
    );
  }
}
