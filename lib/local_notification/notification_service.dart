import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class NotiService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // ✅ Request Exact Alarm Permission (For Android 12+)
  Future<void> requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.scheduleExactAlarm.request();
      if (status.isGranted) {
        print("✅ Exact alarm permission granted!");
      } else {
        print("❌ Exact alarm permission denied!");
        openAppSettings(); // Opens settings if permission is denied
      }
    }
  }

  // Initialized Notification
  Future<void> initNotification() async {
    if (_isInitialized) return; // Prevent re-initialization

    // Request exact alarm permission before initializing notifications
    await requestExactAlarmPermission();

    //init timezone handling
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // Android Initialization Settings
    const AndroidInitializationSettings initSettingsAndroid =
    AndroidInitializationSettings('@drawable/notification_icon');

    // iOS Initialization Settings
    const DarwinInitializationSettings initSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    await notificationsPlugin.initialize(initSettings);

    // ✅ Ensure Notification Channel is created before using it
    await _createNotificationChannel();

    _isInitialized = true;
  }

  // ✅ Create Notification Channel for Android 8+ (API 26+)
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'daily_channel_id', // Unique ID
      'Daily Notifications', // Channel Name
      description: 'Daily notifications', // Description
      importance: Importance.high,
      playSound: true,
    );

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Notification Detail Setup
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id', // Must match the created channel ID
        'Daily Notifications',
        channelDescription: 'Daily notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  // Show Notification on Tap
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    await notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails(), // ✅ Use correct notification details
    );
  }

  // ✅ Schedule Notification
  Future<void> scheduleNotification({
    required int id, // Add an ID parameter
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final scheduledDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    await notificationsPlugin.zonedSchedule(
      id, // Notification ID (change if needed)
      title,
      body,
      scheduledDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'custom_channel_id',
          'Custom Reminders',
          channelDescription: 'User-scheduled reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    print('Notification Scheduled on ${scheduledDateTime.toLocal()}');
  }

  Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required int intervalSeconds,
  }) async {
    await notificationsPlugin.periodicallyShow(
      id,
      title,
      body,
      RepeatInterval.everyMinute, // The lowest interval available is 1 minute
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel_id',
          'Exercise Reminder',
          channelDescription: 'Reminds you to return to your exercise',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // ✅ Required parameter added
    );

    print('Repeating notification scheduled every $intervalSeconds seconds');
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
    print('Notification with ID $id cancelled');
  }

}
