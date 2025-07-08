import 'package:flutter/material.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'auth/auth_gate.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://yikjhtzveczynnmlofdr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlpa2podHp2ZWN6eW5ubWxvZmRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE1MjQ2MDcsImV4cCI6MjA2NzEwMDYwN30.a3ScUWIX5pseVrXtbPllQ0hvVpWM9ZGDCv0ROHJ1dFE',
  );

  // Optional: Comment out this line if you want to keep user logged in across app restarts
  await Supabase.instance.client.auth.signOut();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(400, 700),
      minimumSize: Size(320, 600),
      maximumSize: Size(600, 1200),
      center: true,
      title: 'Pomodoro Desktop',
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  await NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
      ),
      home: const AuthGate(),
    );
  }
}
