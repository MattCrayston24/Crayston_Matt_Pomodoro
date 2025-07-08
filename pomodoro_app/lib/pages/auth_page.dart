import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isLogin = true;
  String errorMessage = '';

  void toggleFormMode() {
    setState(() {
      isLogin = !isLogin;
      errorMessage = '';
    });
  }

  Future<void> handleSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (isLogin) {
        await _authService.signIn(email, password);
      } else {
        await _authService.signUp(email, password);
      }

      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
      }
    } catch (e) {
      setState(() {
        errorMessage = "Échec de l'opération : ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Connexion' : 'Inscription')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Mot de passe')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: handleSubmit, child: Text(isLogin ? 'Connexion' : 'Inscription')),
            TextButton(onPressed: toggleFormMode, child: Text(isLogin ? "Pas encore de compte ?" : "Déjà inscrit ?")),
            if (errorMessage.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
