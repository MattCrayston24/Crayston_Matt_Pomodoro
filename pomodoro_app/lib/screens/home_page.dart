import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../auth/login_screen.dart';
import '../services/notification_service.dart';
import '../pages/session_page.dart'; // 👈 import ajouté

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final SupabaseService _supabaseService = SupabaseService();

  static const int defaultWorkDuration = 25 * 60;
  int remainingTime = defaultWorkDuration;
  Timer? _timer;
  bool isRunning = false;
  DateTime? sessionStartTime;

  void startTimer() {
    setState(() {
      isRunning = true;
      sessionStartTime = DateTime.now();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() => remainingTime--);
      } else {
        timer.cancel();
        _completeSession();
      }
    });
  }

  void resetTimer() async {
    _timer?.cancel();
    if (sessionStartTime != null) {
      await _completeSession();
    }
    setState(() {
      remainingTime = defaultWorkDuration;
      isRunning = false;
      sessionStartTime = null;
    });
  }

  Future<void> _completeSession() async {
    final session = {
      'type': 'Pomodoro',
      'duration': defaultWorkDuration,
      'start_time': sessionStartTime?.toIso8601String(),
      'end_time': DateTime.now().toIso8601String(),
      'user_id': supabase.auth.currentUser!.id,
    };
    await _supabaseService.saveSession(session);
    await NotificationService.showSessionCompletedNotification();
  }

  void logout() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final sec = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("⏱ Pomodoro"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(formatDuration(remainingTime),
                style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isRunning ? resetTimer : startTimer,
              child: Text(isRunning ? "Reset (compte comme terminé)" : "Démarrer"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SessionPage()),
                );
              },
              child: const Text('Voir mes sessions'),
            ),
          ],
        ),
      ),
    );
  }
}
