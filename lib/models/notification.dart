import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String type; // 'rate_update', 'energy_tip', 'budget_alert', 'weekly_report', 'consumption_alert', 'planner_tip'
  final String title;
  final String body;
  final String? subtitle;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data; // Additional data like postUrl, updateId, etc.
  final String? iconName; // Icon name for display
  final String? colorHex; // Color hex for display

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.subtitle,
    required this.timestamp,
    this.isRead = false,
    this.data,
    this.iconName,
    this.colorHex,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'body': body,
      'subtitle': subtitle,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'data': data,
      'iconName': iconName,
      'colorHex': colorHex,
    };
  }

  // Create from Map (for retrieval)
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      subtitle: map['subtitle'],
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
      data: map['data'],
      iconName: map['iconName'],
      colorHex: map['colorHex'],
    );
  }

  // Create from OneSignal notification data
  factory NotificationModel.fromOneSignal(Map<String, dynamic> data) {
    // Extract timestamp from data if available, otherwise use current time
    DateTime timestamp = DateTime.now();
    if (data['timestamp'] != null) {
      try {
        timestamp = DateTime.parse(data['timestamp']);
      } catch (e) {
        // Keep current time if parsing fails
      }
    }

    return NotificationModel(
      id: data['notification_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: data['type'] ?? 'general',
      title: data['title'] ?? 'Notification',
      body: data['body'] ?? '',
      subtitle: data['subtitle'],
      timestamp: timestamp,
      isRead: false,
      data: data,
      iconName: _getIconNameForType(data['type']),
      colorHex: _getColorHexForType(data['type']),
    );
  }

  // Helper methods for icon and color based on type
  static String _getIconNameForType(String? type) {
    switch (type) {
      case 'rate_update':
        return 'notifications_active';
      case 'energy_tip':
        return 'lightbulb';
      case 'budget_alert':
        return 'warning';
      case 'weekly_report':
        return 'calendar_today';
      case 'consumption_alert':
        return 'trending_up';
      case 'planner_tip':
        return 'tips_and_updates';
      default:
        return 'notifications';
    }
  }

  static String _getColorHexForType(String? type) {
    switch (type) {
      case 'rate_update':
        return 'FF4CAF50'; // Green
      case 'energy_tip':
        return 'FF2196F3'; // Blue
      case 'budget_alert':
        return 'FFFF9800'; // Orange
      case 'weekly_report':
        return 'FF2196F3'; // Blue
      case 'consumption_alert':
        return 'FFE91E63'; // Pink
      case 'planner_tip':
        return 'FF9C27B0'; // Purple
      default:
        return 'FF607D8B'; // Grey
    }
  }

  // Get time ago string
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) return '1 day ago';
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      if (difference.inHours == 1) return '1 hour ago';
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      if (difference.inMinutes == 1) return '1 minute ago';
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  // Create copy with updated fields
  NotificationModel copyWith({
    String? id,
    String? type,
    String? title,
    String? body,
    String? subtitle,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
    String? iconName,
    String? colorHex,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      subtitle: subtitle ?? this.subtitle,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
    );
  }
}
