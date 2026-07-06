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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFF020206),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF8A16E8)),
            ),
          );
        }
        
        if (auth.isAuthenticated) {
          return const MainScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
