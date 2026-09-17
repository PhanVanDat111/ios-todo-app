import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/todo_item.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize Timezones
    tz.initializeTimeZones();

    // iOS Specific Settings
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Android Specific Settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      iOS: initializationSettingsDarwin,
      android: initializationSettingsAndroid,
      macOS: initializationSettingsDarwin,
    );

    try {
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked with payload: ${response.payload}');
        },
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing local notifications: $e');
    }
  }

  Future<bool> requestPermissions() async {
    try {
      final bool? result = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? true;
    } catch (e) {
      debugPrint('Error requesting iOS notification permissions: $e');
      return false;
    }
  }

  Future<int> scheduleTodoReminder(TodoItem todo) async {
    if (todo.reminderTime == null) return -1;
    final scheduledDate = todo.reminderTime!;

    // Don't schedule for past times
    if (scheduledDate.isBefore(DateTime.now())) {
      return -1;
    }

    final int notificationId = todo.id.hashCode & 0x7FFFFFFF;

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'todo_reminders_channel',
      'Todo Reminders',
      channelDescription: 'Notifications for scheduled tasks and reminders',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      iOS: iosDetails,
      android: androidDetails,
      macOS: iosDetails,
    );

    try {
      final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        '⏰ Nhắc nhở: ${todo.title}',
        todo.notes != null && todo.notes!.isNotEmpty
            ? todo.notes
            : 'Đã đến giờ hoàn thành công việc của bạn!',
        tzScheduledDate,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: todo.id,
      );

      debugPrint('Scheduled notification #$notificationId for ${todo.title} at $tzScheduledDate');
      return notificationId;
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      return -1;
    }
  }

  Future<void> cancelReminder(int notificationId) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(notificationId);
      debugPrint('Cancelled notification #$notificationId');
    } catch (e) {
      debugPrint('Error cancelling notification #$notificationId: $e');
    }
  }

  Future<void> showInstantTestNotification({required String title, required String body}) async {
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Channel',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(
      iOS: iosDetails,
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      99999,
      title,
      body,
      platformDetails,
    );
  }
}
