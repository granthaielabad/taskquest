import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification clicked: ${details.payload}');
      },
    );

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        
    await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel(
      'taskquest_channel',
      'TaskQuest Notifications',
      description: 'Standard TaskQuest alerts',
      importance: Importance.max,
    ));

    await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel(
      'daily_reminder_channel',
      'Daily Reminders',
      description: 'Recurring study reminders',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    ));

    await requestPermissions();
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  Future<void> showNotification({
    int id = 0,
    String? title, String? body, String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'taskquest_channel', 'TaskQuest Notifications',
      importance: Importance.max, priority: Priority.high, showWhen: true,
    );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails, iOS: DarwinNotificationDetails(),
    );
    await _notificationsPlugin.show(id, title, body, details, payload: payload);
  }

  Future<void> scheduleDailyReminder(int hour, int minute, {int id = 1, String? title, String? body}) async {
    final tz.TZDateTime scheduledTime = _nextInstanceOfTime(hour, minute);
    await _scheduleZoned(id, title ?? 'Reminder', body ?? 'Time for TaskQuest!', scheduledTime);
  }

  // New method specifically for the 30-second test to avoid timezone/rounding issues
  Future<void> scheduleTestNotification(int seconds, {int id = 1, String? title, String? body}) async {
    final tz.TZDateTime scheduledTime = tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));
    debugPrint('SERVICE: Scheduling TEST ID $id for $scheduledTime');
    await _scheduleZoned(id, title ?? 'Test', body ?? 'Test content', scheduledTime);
  }

  Future<void> _scheduleZoned(int id, String title, String body, tz.TZDateTime scheduledTime) async {
    try {
      await _notificationsPlugin.zonedSchedule(
        id, title, body, scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder_channel', 'Daily Reminders',
            importance: Importance.max, priority: Priority.high,
            visibility: NotificationVisibility.public,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('SERVICE: Zoned schedule successful for ID $id');
    } catch (e) {
      debugPrint('SERVICE: Exact alarm failed, falling back to inexact. Error: $e');
      await _notificationsPlugin.zonedSchedule(
        id, title, body, scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder_channel', 'Daily Reminders',
            importance: Importance.max, priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = DateTime.now();
    DateTime scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return tz.TZDateTime.from(scheduledDate.toUtc(), tz.local);
  }
}
