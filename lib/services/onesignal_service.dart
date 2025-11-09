import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'dart:developer' as developer;
import '../models/notification.dart';
import '../services/notification_storage_service.dart';

class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  static const String _appId = '418744e0-0f43-40b7-ab7b-70c2748fe2f9'; // Updated with provided App ID
  final NotificationStorageService _notificationStorage = NotificationStorageService();

  String? _currentUserId;

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
        _handleNotificationClick(event.notification.additionalData ?? {});
      });

      // Handle notification received
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        developer.log('Notification received: ${event.notification.additionalData}', name: 'OneSignalService');
        // Store the notification when received
        _handleNotificationReceived(event.notification.additionalData ?? {});
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

  // Set current user ID for notification storage
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  // Handle notification received - store it locally
  void _handleNotificationReceived(Map<String, dynamic> data) {
    if (_currentUserId == null) {
      developer.log('No user ID set, cannot store notification', name: 'OneSignalService');
      return;
    }

    try {
      // Create notification from OneSignal data
      final notification = NotificationModel.fromOneSignal(data);

      // Store the notification
      _notificationStorage.storeNotification(_currentUserId!, notification);

      developer.log('Notification stored from OneSignal: ${notification.id}', name: 'OneSignalService');
    } catch (e) {
      developer.log('Error storing notification from OneSignal: $e', name: 'OneSignalService');
    }
  }

  // Handle notification click
  void _handleNotificationClick(Map<String, dynamic> data) {
    developer.log('Handling notification click with data: $data', name: 'OneSignalService');
    // TODO: Implement navigation based on notification type
    // For example, navigate to rate screen for rate_update type
  }
}
