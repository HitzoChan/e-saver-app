import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification.dart';
import 'dart:developer' as developer;

class NotificationStorageService {
  static final NotificationStorageService _instance = NotificationStorageService._internal();
  factory NotificationStorageService() => _instance;
  NotificationStorageService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _localNotificationsKey = 'local_notifications';
  static const int _maxStoredNotifications = 50; // Limit stored notifications

  // Store notification in Firestore for the user
  Future<void> storeNotification(String userId, NotificationModel notification) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());

      developer.log('Notification stored: ${notification.id}', name: 'NotificationStorageService');
    } catch (e) {
      developer.log('Error storing notification: $e', name: 'NotificationStorageService');
      // Fallback to local storage if Firestore fails
      await _storeLocally(notification);
    }
  }

  // Get all notifications for a user
  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(_maxStoredNotifications)
          .get();

      final notifications = querySnapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data()))
          .toList();

      developer.log('Retrieved ${notifications.length} notifications from Firestore', name: 'NotificationStorageService');
      return notifications;
    } catch (e) {
      developer.log('Error retrieving notifications from Firestore: $e', name: 'NotificationStorageService');
      // Fallback to local storage
      return await _getLocalNotifications();
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String userId, String notificationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});

      developer.log('Notification marked as read: $notificationId', name: 'NotificationStorageService');
    } catch (e) {
      developer.log('Error marking notification as read: $e', name: 'NotificationStorageService');
      // Update local storage
      await _markLocalAsRead(notificationId);
    }
  }

  // Delete notification
  Future<void> deleteNotification(String userId, String notificationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .delete();

      developer.log('Notification deleted: $notificationId', name: 'NotificationStorageService');
    } catch (e) {
      developer.log('Error deleting notification: $e', name: 'NotificationStorageService');
      // Remove from local storage
      await _deleteLocalNotification(notificationId);
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications(String userId) async {
    try {
      final batch = _firestore.batch();
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .get();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      developer.log('All notifications cleared for user: $userId', name: 'NotificationStorageService');
    } catch (e) {
      developer.log('Error clearing notifications: $e', name: 'NotificationStorageService');
      // Clear local storage
      await _clearLocalNotifications();
    }
  }

  // Get unread count
  Future<int> getUnreadCount(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      developer.log('Error getting unread count: $e', name: 'NotificationStorageService');
      // Count from local storage
      final notifications = await _getLocalNotifications();
      return notifications.where((n) => !n.isRead).length;
    }
  }

  // Store notification locally (fallback)
  Future<void> _storeLocally(NotificationModel notification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await _getLocalNotifications();
      notifications.insert(0, notification); // Add to beginning

      // Keep only the most recent notifications
      if (notifications.length > _maxStoredNotifications) {
        notifications.removeRange(_maxStoredNotifications, notifications.length);
      }

      final notificationsJson = notifications.map((n) => n.toMap()).toList();
      await prefs.setString(_localNotificationsKey, jsonEncode(notificationsJson));
    } catch (e) {
      developer.log('Error storing notification locally: $e', name: 'NotificationStorageService');
    }
  }

  // Get local notifications
  Future<List<NotificationModel>> _getLocalNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_localNotificationsKey);

      if (notificationsJson == null) return [];

      final notificationsData = jsonDecode(notificationsJson) as List;
      return notificationsData.map((data) => NotificationModel.fromMap(data)).toList();
    } catch (e) {
      developer.log('Error getting local notifications: $e', name: 'NotificationStorageService');
      return [];
    }
  }

  // Mark local notification as read
  Future<void> _markLocalAsRead(String notificationId) async {
    try {
      final notifications = await _getLocalNotifications();
      final index = notifications.indexWhere((n) => n.id == notificationId);

      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        await _saveLocalNotifications(notifications);
      }
    } catch (e) {
      developer.log('Error marking local notification as read: $e', name: 'NotificationStorageService');
    }
  }

  // Delete local notification
  Future<void> _deleteLocalNotification(String notificationId) async {
    try {
      final notifications = await _getLocalNotifications();
      notifications.removeWhere((n) => n.id == notificationId);
      await _saveLocalNotifications(notifications);
    } catch (e) {
      developer.log('Error deleting local notification: $e', name: 'NotificationStorageService');
    }
  }

  // Clear local notifications
  Future<void> _clearLocalNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localNotificationsKey);
    } catch (e) {
      developer.log('Error clearing local notifications: $e', name: 'NotificationStorageService');
    }
  }

  // Save local notifications
  Future<void> _saveLocalNotifications(List<NotificationModel> notifications) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = notifications.map((n) => n.toMap()).toList();
      await prefs.setString(_localNotificationsKey, jsonEncode(notificationsJson));
    } catch (e) {
      developer.log('Error saving local notifications: $e', name: 'NotificationStorageService');
    }
  }

  // Sync local notifications to Firestore (for when user comes back online)
  Future<void> syncLocalToFirestore(String userId) async {
    try {
      final localNotifications = await _getLocalNotifications();

      if (localNotifications.isEmpty) return;

      final batch = _firestore.batch();

      for (final notification in localNotifications) {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .doc(notification.id);

        batch.set(docRef, notification.toMap());
      }

      await batch.commit();

      // Clear local storage after successful sync
      await _clearLocalNotifications();

      developer.log('Synced ${localNotifications.length} local notifications to Firestore', name: 'NotificationStorageService');
    } catch (e) {
      developer.log('Error syncing local notifications to Firestore: $e', name: 'NotificationStorageService');
    }
  }
}
