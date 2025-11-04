// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'onesignal_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _notificationsEnabledKey = 'notifications_enabled';

  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize local notifications
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(settings);

    developer.log('Notification service initialized', name: 'NotificationService');
  }

  // static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //   print('Handling background message: ${message.messageId}');
  // }

  // void _handleForegroundMessage(RemoteMessage message) {
  //   print('Received foreground message: ${message.notification?.title}');

  //   // Show local notification for foreground messages
  //   _showLocalNotification(
  //     title: message.notification?.title ?? 'E-Saver',
  //     body: message.notification?.body ?? 'You have a new notification',
  //     payload: message.data.toString(),
  //   );
  // }

  // void _handleMessageOpenedApp(RemoteMessage message) {
  //   print('Message opened from background: ${message.notification?.title}');
  //   // Handle navigation based on message data
  // }

  Future<String?> getFCMToken() async {
    developer.log('FCM Token: Not available (Firebase commented out)', name: 'NotificationService');
    return null;
  }

  Future<void> subscribeToTopic(String topic) async {
    developer.log('Topic subscription: Not available (Firebase commented out)', name: 'NotificationService');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    developer.log('Topic unsubscription: Not available (Firebase commented out)', name: 'NotificationService');
  }

  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true; // Default to true for FCM
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);

    if (enabled) {
      // Subscribe to general topics using OneSignal
      await OneSignalService().subscribeToTopic('general');
      await OneSignalService().subscribeToTopic('energy_tips');
    } else {
      // Unsubscribe from topics using OneSignal
      await OneSignalService().unsubscribeFromTopic('general');
      await OneSignalService().unsubscribeFromTopic('energy_tips');
    }
  }

  Future<void> showRateUpdateNotification({
    required String title,
    required String body,
    String? postUrl,
    String? updateId,
  }) async {
    await _showLocalNotification(
      title: title,
      body: body,
      payload: 'rate_update|$postUrl|$updateId',
    );
  }

  Future<void> showEnergyTipNotification({
    required String title,
    required String body,
  }) async {
    await _showLocalNotification(
      title: title,
      body: body,
      payload: 'energy_tip',
    );
  }

  Future<void> showWeeklyReportNotification({
    required String title,
    required String body,
  }) async {
    await _showLocalNotification(
      title: title,
      body: body,
      payload: 'weekly_report',
    );
  }

  Future<void> showPlannerTipNotification({
    required String title,
    required String body,
  }) async {
    await _showLocalNotification(
      title: title,
      body: body,
      payload: 'planner_tip',
    );
  }

  Future<void> showConsumptionAlertNotification({
    required String title,
    required String body,
  }) async {
    await _showLocalNotification(
      title: title,
      body: body,
      payload: 'consumption_alert',
    );
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'e_saver_channel',
      'E-Saver Notifications',
      channelDescription: 'Notifications for energy saving tips and updates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
      title,
      body,
      details,
      payload: payload,
    );
  }
}
