import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/task.dart' as task_model;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize timezone data
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap if needed
      },
    );
  }

  Future<void> requestPermissions() async {
    // Request permissions for iOS (Android permissions are requested automatically)
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        
    // For Android 13+, we need to request permission
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleNotification(task_model.Task task) async {
    if (task.dueDate == null) return;

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'task_reminder_channel',
      'Task Reminders',
      channelDescription: 'Channel for task reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      ticker: 'Task Reminder',
    );
    
    final DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Schedule notification 2 days before due date
    final notificationDate = task.dueDate!.subtract(Duration(days: 2));
    
    // Only schedule if the notification date is in the future
    if (notificationDate.isAfter(DateTime.now())) {
      print('Scheduling notification for task: ${task.title} at $notificationDate');
      await flutterLocalNotificationsPlugin.zonedSchedule(
        task.id ?? 0,
        'Task Reminder: ${task.title}',
        task.description ?? 'Your task is due in 2 days',
        tz.TZDateTime.from(notificationDate, tz.local),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } else {
      print('Skipping notification for task: ${task.title} as notification date is in the past');
    }
    
    // If task is repeated, schedule next occurrence
    if (task.repeatType != task_model.RepeatType.none) {
      final nextDueDate = _calculateNextDueDate(task.dueDate!, task.repeatType);
      if (nextDueDate != null) {
        final repeatedTask = task.copyWith(
          id: (task.id ?? 0) + 1000000, // Use a different ID for repeated notification
          dueDate: nextDueDate,
        );
        await scheduleNotification(repeatedTask);
      }
    }
  }

  DateTime? _calculateNextDueDate(DateTime currentDate, task_model.RepeatType repeatType) {
    switch (repeatType) {
      case task_model.RepeatType.daily:
        return currentDate.add(Duration(days: 1));
      case task_model.RepeatType.weekly:
        return currentDate.add(Duration(days: 7));
      case task_model.RepeatType.monthly:
        return DateTime(
          currentDate.year,
          currentDate.month + 1,
          currentDate.day,
          currentDate.hour,
          currentDate.minute,
          currentDate.second,
        );
      case task_model.RepeatType.yearly:
        return DateTime(
          currentDate.year + 1,
          currentDate.month,
          currentDate.day,
          currentDate.hour,
          currentDate.minute,
          currentDate.second,
        );
      default:
        return null;
    }
  }

  Future<void> cancelNotification(int taskId) async {
    await flutterLocalNotificationsPlugin.cancel(taskId);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}