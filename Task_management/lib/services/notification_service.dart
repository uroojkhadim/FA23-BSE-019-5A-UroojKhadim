import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart' as task_model;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      print('Timezone data initialized');

      // Create Android notification channel
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
          print('Notification tapped: ${response.payload}');
        },
      );
      print('Notification plugin initialized');
      
      // Create notification channel for Android
      await _createNotificationChannel();
      print('Notification channel created');
    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

  Future<void> _createNotificationChannel() async {
    try {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'task_reminder_channel', // id
        'Task Reminders', // title
        description: 'Channel for task reminder notifications', // description
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
        ledColor: Color(0xFFFF0000), // Red LED for visibility
        enableLights: true,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      print('Notification channel creation completed');
    } catch (e) {
      print('Error creating notification channel: $e');
    }
  }

  Future<void> requestPermissions() async {
    try {
      print('Requesting notification permissions');
      
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
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
              
      if (androidImplementation != null) {
        print('Requesting Android notification permission');
        await androidImplementation.requestNotificationsPermission();
        print('Android notification permission requested');
      }
    } catch (e) {
      print('Error requesting notification permissions: $e');
    }
  }

  Future<void> scheduleNotification(task_model.Task task) async {
    try {
      if (task.dueDate == null) {
        print('Task has no due date, skipping notification');
        return;
      }

      // Get selected notification sound from preferences
      final prefs = await SharedPreferences.getInstance();
      final selectedSound = prefs.getString('notificationSound') ?? 'default';

      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'task_reminder_channel',
        'Task Reminders',
        channelDescription: 'Channel for task reminder notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        ticker: 'Task Reminder',
        playSound: true,
        sound: _getAndroidSound(selectedSound),
        enableVibration: true,
        visibility: NotificationVisibility.public,
        fullScreenIntent: true, // This will make the notification appear on top of the screen
        showProgress: false,
        category: AndroidNotificationCategory.reminder,
        timeoutAfter: 30000, // Dismiss after 30 seconds if not interacted with
        color: const Color(0xFFFF0000), // Red color for visibility
        colorized: true,
        ledColor: const Color(0xFFFF0000),
        enableLights: true,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]), // Vibrate pattern
      );
      
      final DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        subtitle: 'Task Reminder',
        sound: _getiOSSound(selectedSound),
      );

      final NotificationDetails platformChannelSpecifics =
          NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      // Schedule notification 1 day before due date for better user experience
      // For testing purposes, let's schedule it for 1 minute from now if it's in the past
      final notificationDate = task.dueDate!.subtract(Duration(days: 1));
      final scheduleDate = notificationDate.isAfter(DateTime.now()) 
          ? notificationDate 
          : DateTime.now().add(Duration(minutes: 1));
      
      print('Scheduling notification for task: ${task.title} at $scheduleDate (originally $notificationDate)');
      
      await flutterLocalNotificationsPlugin.zonedSchedule(
        task.id ?? 0,
        'Task Reminder: ${task.title}',
        task.description ?? 'Your task is due soon',
        tz.TZDateTime.from(scheduleDate, tz.local),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      
      print('Notification scheduled successfully for task: ${task.title}');
    } catch (e) {
      print('Error scheduling notification for task ${task.title}: $e');
    }
    
    // If task is repeated, schedule next occurrence
    if (task.repeatType != task_model.RepeatType.none) {
      try {
        final nextDueDate = _calculateNextDueDate(task.dueDate!, task.repeatType);
        if (nextDueDate != null) {
          final repeatedTask = task.copyWith(
            id: (task.id ?? 0) + 1000000, // Use a different ID for repeated notification
            dueDate: nextDueDate,
          );
          await scheduleNotification(repeatedTask);
        }
      } catch (e) {
        print('Error scheduling repeated notification: $e');
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
    try {
      await flutterLocalNotificationsPlugin.cancel(taskId);
      print('Notification cancelled for task ID: $taskId');
    } catch (e) {
      print('Error cancelling notification for task ID $taskId: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
      print('All notifications cancelled');
    } catch (e) {
      print('Error cancelling all notifications: $e');
    }
  }
  
  Future<bool> areNotificationsEnabled() async {
    try {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
              
      if (androidImplementation != null) {
        final result = await androidImplementation.areNotificationsEnabled();
        return result ?? false;
      }
      return false;
    } catch (e) {
      print('Error checking if notifications are enabled: $e');
      return false;
    }
  }

  // Helper method to get Android sound based on selection
  AndroidNotificationSound? _getAndroidSound(String soundOption) {
    switch (soundOption) {
      case 'bell':
        return RawResourceAndroidNotificationSound('bell');
      case 'chime':
        return RawResourceAndroidNotificationSound('chime');
      case 'ping':
        return RawResourceAndroidNotificationSound('ping');
      case 'vibrate':
        return null; // No sound, just vibration
      default:
        return null; // Default system sound
    }
  }

  // Helper method to get iOS sound based on selection
  String? _getiOSSound(String soundOption) {
    switch (soundOption) {
      case 'bell':
        return 'bell.caf';
      case 'chime':
        return 'chime.caf';
      case 'ping':
        return 'ping.aiff';
      case 'vibrate':
        return null; // No sound, just vibration
      default:
        return null; // Default system sound
    }
  }
}       return null; // No sound, just vibration
      default:
        return null; // Default system sound
    }
  }

  // Helper method to get iOS sound based on selection
  String? _getiOSSound(String soundOption) {
    switch (soundOption) {
      case 'bell':
        return 'bell.caf';
      case 'chime':
        return 'chime.caf';
      case 'ping':
        return 'ping.aiff';
      case 'vibrate':
        return null; // No sound, just vibration
      default:
        return null; // Default system sound
    }
  }
}