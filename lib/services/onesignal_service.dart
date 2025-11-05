import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'dart:developer' as developer;

class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  static const String _appId = '733af534-3c80-4a46-b0d3-63bb2ec6a158'; // Updated with provided App ID

  Future<void> initialize() async {
    try {
      // Initialize OneSignal
      OneSignal.initialize(_appId);

      // Request permission for notifications
      await OneSignal.Notifications.requestPermission(true);

      // Handle notification opened
      OneSignal.Notifications.addClickListener((event) {
        developer.log('Notification clicked: ${event.notification.additionalData}', name: 'OneSignalService');
        // Handle notification click here - could navigate to specific screen based on data
      });

      // Handle notification received
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        developer.log('Notification received: ${event.notification.additionalData}', name: 'OneSignalService');
        // Handle notification received here - could update dashboard notifications
      });

      developer.log('OneSignal initialized successfully', name: 'OneSignalService');
    } catch (e) {
      developer.log('Failed to initialize OneSignal: $e', name: 'OneSignalService');
      rethrow;
    }
  }

  Future<void> setUserId(String userId) async {
    OneSignal.login(userId);
  }

  Future<void> removeUserId() async {
    OneSignal.logout();
  }

  Future<void> sendTag(String key, String value) async {
    OneSignal.User.addTags({key: value});
  }

  Future<void> deleteTag(String key) async {
    OneSignal.User.removeTags([key]);
  }

  Future<void> subscribeToTopic(String topic) async {
    // OneSignal doesn't have topics like FCM, but we can use tags
    await sendTag(topic, 'subscribed');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await deleteTag(topic);
  }

  Future<String?> getPlayerId() async {
    return OneSignal.User.pushSubscription.id;
  }

  Future<void> setExternalUserId(String externalUserId) async {
    OneSignal.login(externalUserId);
  }

  Future<void> removeExternalUserId() async {
    OneSignal.logout();
  }
}