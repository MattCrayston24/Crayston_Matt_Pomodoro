import 'package:flutter/material.dart';

import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Toujours afficher la page de connexion en premier
    return const LoginScreen();
  }
}
