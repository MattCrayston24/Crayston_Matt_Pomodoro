import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _notificationsPlugin.initialize(settings);
  }

  static Future<void> showSessionCompletedNotification() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'pomodoro_channel',
        'Pomodoro Sessions',
        channelDescription: 'Notification après une session',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Session terminée 🎉',
      'Tu viens de finir une session Pomodoro !',
      details,
    );
  }
}
