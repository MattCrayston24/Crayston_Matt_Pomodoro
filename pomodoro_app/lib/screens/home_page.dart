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

  static const Map<SessionType, int> defaultDurations = {
    SessionType.pomodoro: 25,
    SessionType.shortBreak: 5,
    SessionType.longBreak: 15,
  };

  static const Color orangeColor = Color(0xFFFF6D00);

  SessionType currentSessionType = SessionType.pomodoro;

  // Durée personnalisée en minutes, initialisée aux valeurs par défaut
  Map<SessionType, double> customDurations = {
    SessionType.pomodoro: 25,
    SessionType.shortBreak: 5,
    SessionType.longBreak: 15,
  };

  late int remainingTime; // en secondes
  late int totalTime; // en secondes
  Timer? _timer;
  bool isRunning = false;
  bool isPaused = false;
  DateTime? sessionStartTime;

  late AnimationController _animationController;

  bool isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    totalTime = (customDurations[currentSessionType]! * 60).toInt();
    remainingTime = totalTime;

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: totalTime),
    );
    _animationController.value = 1.0;
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
      totalTime = (customDurations[currentSessionType]! * 60).toInt();
      remainingTime = totalTime;
    });

    _animationController.duration = Duration(seconds: totalTime);
    _animationController.reverse(from: 1.0);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime > 0 && !isPaused) {
        setState(() {
          remainingTime--;
        });
      } else if (remainingTime == 0) {
        timer.cancel();
        _animationController.stop();
        _completeSession();
        setState(() {
          isRunning = false;
          isPaused = false;
          sessionStartTime = null;
        });
      }
    });
  }

  void pauseTimer() {
    if (!isRunning || isPaused) return;
    setState(() {
      isPaused = true;
    });
    _animationController.stop();
  }

  void resumeTimer() {
    if (!isRunning || !isPaused) return;
    setState(() {
      isPaused = false;
    });
    _animationController.reverse(from: _animationController.value);
  }

  Future<void> resetTimer() async {
    _timer?.cancel();
    _animationController.stop();

    if (isRunning || isPaused) {
      await _completeSession();
    }

    setState(() {
      isRunning = false;
      isPaused = false;
      totalTime = (customDurations[currentSessionType]! * 60).toInt();
      remainingTime = totalTime;
      sessionStartTime = null;
      _animationController.value = 1.0;
      _animationController.duration = Duration(seconds: totalTime);
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
      totalTime = (customDurations[type]! * 60).toInt();
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

    // Choix du thème
    final themeData = isDarkTheme
        ? ThemeData.dark().copyWith(
            primaryColor: orangeColor,
            scaffoldBackgroundColor: const Color(0xFF292C3A),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: orangeColor,
              ),
            ),
          )
        : ThemeData.light().copyWith(
            primaryColor: orangeColor,
            scaffoldBackgroundColor: Colors.white,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: orangeColor,
              ),
            ),
          );

    return Theme(
      data: themeData,
      child: Scaffold(
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
            Switch(
              value: isDarkTheme,
              onChanged: (value) {
                setState(() {
                  isDarkTheme = value;
                });
              },
              activeColor: Colors.white,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.shade400,
            ),
          ],
        ),
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
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: isDarkTheme ? Colors.white : Colors.black,
                              shadows: const [
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

                // Slider de durée personnalisée (minutes)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Text(
                        'Durée personnalisée : ${customDurations[currentSessionType]!.toInt()} min',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkTheme ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Slider(
                        value: customDurations[currentSessionType]!,
                        min: 0,
                        max: 60,
                        divisions: 60,
                        label: '${customDurations[currentSessionType]!.toInt()} min',
                        onChanged: (value) {
                          if (isRunning) return; // Interdit modifier en cours de session
                          setState(() {
                            customDurations[currentSessionType] = value;
                            totalTime = (value * 60).toInt();
                            remainingTime = totalTime;
                            _animationController.duration = Duration(seconds: totalTime);
                            _animationController.value = 1.0;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: SessionType.values.map((type) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            onPressed: () {
                              if (isRunning) return; // interdit changer session en cours
                              changeSession(type);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: currentSessionType == type
                                  ? orangeColor
                                  : (isDarkTheme ? Colors.grey.shade800 : Colors.grey.shade300),
                              foregroundColor: currentSessionType == type
                                  ? Colors.white
                                  : (isDarkTheme ? Colors.white70 : Colors.black87),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: currentSessionType == type ? 6 : 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              _getSessionLabel(type),
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 40),

                ElevatedButton.icon(
                  onPressed: goToHistory,
                  icon: const Icon(Icons.history),
                  label: const Text("Historique"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orangeColor,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
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
