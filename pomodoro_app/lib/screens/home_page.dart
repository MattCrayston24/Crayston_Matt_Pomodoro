import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';
import '../auth/login_screen.dart';
import '../services/notification_service.dart';
import '../pages/session_page.dart';

enum SessionType { pomodoro, shortBreak, longBreak }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final SupabaseClient supabase = Supabase.instance.client;
  final SupabaseService _supabaseService = SupabaseService();

  static const Map<SessionType, int> durations = {
    SessionType.pomodoro: 25 * 60,
    SessionType.shortBreak: 5 * 60,
    SessionType.longBreak: 15 * 60,
  };

  static const Color orangeColor = Color(0xFFFF6D00);

  SessionType currentSessionType = SessionType.pomodoro;
  late int remainingTime;
  late int totalTime;
  Timer? _timer;
  bool isRunning = false;
  bool isPaused = false;
  DateTime? sessionStartTime;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    totalTime = durations[currentSessionType]!;
    remainingTime = totalTime;

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: totalTime),
    );
    _animationController.value = 1.0; // Barre pleine au démarrage
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void startTimer() {
    setState(() {
      isRunning = true;
      isPaused = false;
      sessionStartTime = DateTime.now();
      totalTime = durations[currentSessionType]!;
      remainingTime = totalTime;
    });

    _animationController.duration = Duration(seconds: totalTime);
    _animationController.reverse(from: 1.0);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime > 0 && !isPaused) {
        setState(() {
          remainingTime--;
        });
      } else if (remainingTime == 0) {
        timer.cancel();
        _animationController.stop();
        _completeSession();
      }
    });
  }

  void pauseTimer() {
    setState(() {
      isPaused = true;
    });
    _animationController.stop();
  }

  void resumeTimer() {
    setState(() {
      isPaused = false;
    });
    _animationController.reverse(from: _animationController.value);
  }

void resetTimer() async {
  _timer?.cancel();            // Stoppe le timer
  _animationController.stop(); // Arrête l’animation en cours
  _animationController.value = 1.0; // Remet la barre à pleine longueur

  // On ne sauvegarde pas la session ici, on veut juste reset immédiat

  setState(() {
    remainingTime = durations[currentSessionType]!; // Remet le compteur à la valeur initiale
    totalTime = durations[currentSessionType]!;
    isRunning = false;  // Le timer est arrêté
    isPaused = false;
    sessionStartTime = null;
  });
}

  int _elapsedSessionTime() {
    if (sessionStartTime == null) return 0;
    final now = DateTime.now();
    final elapsed = now.difference(sessionStartTime!).inSeconds;
    return elapsed > totalTime ? totalTime : elapsed;
  }

  Future<void> _completeSession() async {
    final elapsedDuration = _elapsedSessionTime();

    final session = {
      'type': _getSessionLabel(currentSessionType),
      'duration': elapsedDuration,
      'timestamp': sessionStartTime?.toIso8601String(),
      'user_id': supabase.auth.currentUser!.id,
    };

    await _supabaseService.saveSession(session);
    await NotificationService.showSessionCompletedNotification();
  }

  void changeSession(SessionType type) {
    _timer?.cancel();
    _animationController.reset();
    setState(() {
      currentSessionType = type;
      totalTime = durations[type]!;
      remainingTime = totalTime;
      isRunning = false;
      isPaused = false;
      sessionStartTime = null;
    });
    _animationController.duration = Duration(seconds: totalTime);
    _animationController.value = 1.0;
  }

  String _getSessionLabel(SessionType type) {
    switch (type) {
      case SessionType.pomodoro:
        return 'Pomodoro';
      case SessionType.shortBreak:
        return 'Pause courte';
      case SessionType.longBreak:
        return 'Pause longue';
    }
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

  void goToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SessionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonWidth = 180.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "⏱ ${_getSessionLabel(currentSessionType)}",
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: orangeColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      backgroundColor: const Color(0xFF292C3A),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 130,
                          height: 130,
                          child: CircularProgressIndicator(
                            value: _animationController.value,
                            strokeWidth: 10,
                            color: orangeColor,
                            backgroundColor: orangeColor.withOpacity(0.3),
                          ),
                        ),
                        Text(
                          formatDuration(remainingTime),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 5,
                                color: Colors.black54,
                                offset: Offset(1, 1),
                              )
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Boutons démarrer/pause/reprendre
              if (!isRunning)
                ElevatedButton(
                  onPressed: startTimer,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(buttonWidth, 40),
                    backgroundColor: orangeColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
                  ),
                  child: const Text(
                    "Démarrer",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                )
              else if (isRunning && !isPaused)
                ElevatedButton(
                  onPressed: pauseTimer,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(buttonWidth, 40),
                    backgroundColor: orangeColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
                  ),
                  child: const Text(
                    "Pause",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                )
              else if (isRunning && isPaused)
                ElevatedButton(
                  onPressed: resumeTimer,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(buttonWidth, 40),
                    backgroundColor: orangeColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
                  ),
                  child: const Text(
                    "Reprendre",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),

              const SizedBox(height: 10),

              if (isRunning)
                ElevatedButton(
                  onPressed: resetTimer,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(buttonWidth, 38),
                    backgroundColor: Colors.red.shade600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 4,
                  ),
                  child: const Text(
                    "Reset",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),

              const SizedBox(height: 30),

              // Boutons pour changer le mode - texte plus petit
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: SessionType.values.map((type) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ElevatedButton(
                          onPressed: () => changeSession(type),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currentSessionType == type
                                ? orangeColor
                                : Colors.grey.shade800,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(
                            _getSessionLabel(type),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: currentSessionType == type
                                  ? Colors.white
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: goToHistory,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(buttonWidth, 40),
                  backgroundColor: orangeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                ),
                child: const Text(
                  "Historique des sessions",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
