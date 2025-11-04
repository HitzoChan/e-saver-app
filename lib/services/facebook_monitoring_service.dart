import 'dart:convert';
import 'package:http/http.dart' as http;
import 'notification_service.dart';

class FacebookMonitoringService {
  static const String _samElcoPageId = 'samElcoPage'; // Replace with actual SAMELCO page ID
  static const String _facebookGraphApiUrl = 'https://graph.facebook.com/v18.0';
  static const String _accessToken = 'YOUR_FACEBOOK_ACCESS_TOKEN'; // Replace with actual token

  final NotificationService _notificationService = NotificationService();

  Future<void> checkForRateUpdates() async {
    try {
      // Fetch recent posts from SAMELCO Facebook page
      final response = await http.get(
        Uri.parse(
          '$_facebookGraphApiUrl/$_samElcoPageId/posts?'
          'fields=id,message,created_time,permalink_url&'
          'access_token=$_accessToken&'
          'limit=10',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final posts = data['data'] as List<dynamic>;

        for (final post in posts) {
          await _analyzePost(post);
        }
      }
    } catch (e) {
      print('Error checking Facebook posts: $e');
    }
  }

  Future<void> _analyzePost(Map<String, dynamic> post) async {
    final message = post['message'] as String? ?? '';
    final postId = post['id'] as String;
    final permalinkUrl = post['permalink_url'] as String?;
    final createdTime = post['created_time'] as String;

    // Check if post contains rate-related keywords
    final rateKeywords = [
      'rate', 'rates', 'electricity rate', 'power rate',
      'samelco rate', 'rate update', 'new rate', 'rate change',
      '₱', 'peso', 'centavo', 'per kwh', '/kWh'
    ];

    final lowerMessage = message.toLowerCase();
    final containsRateKeyword = rateKeywords.any((keyword) =>
        lowerMessage.contains(keyword.toLowerCase()));

    if (containsRateKeyword) {
      // Extract rate information if possible
      final extractedRate = _extractRateFromMessage(message);

      await _notificationService.showRateUpdateNotification(
        title: '⚡ SAMELCO Rate Update',
        body: extractedRate != null
            ? 'New electricity rate detected: ₱${extractedRate.toStringAsFixed(2)}/kWh'
            : 'SAMELCO has posted about electricity rates. Tap to view details.',
        postUrl: permalinkUrl ?? 'https://www.facebook.com/samelco/posts/$postId',
        updateId: postId,
      );
    }
  }

  double? _extractRateFromMessage(String message) {
    // Simple regex to extract rate patterns like "₱12.50/kWh" or "12.50 per kWh"
    final ratePatterns = [
      RegExp(r'₱(\d+\.?\d*)/kWh', caseSensitive: false),
      RegExp(r'₱(\d+\.?\d*)\s*per\s*kWh', caseSensitive: false),
      RegExp(r'(\d+\.?\d*)\s*peso.*kWh', caseSensitive: false),
      RegExp(r'rate.*₱(\d+\.?\d*)', caseSensitive: false),
    ];

    for (final pattern in ratePatterns) {
      final match = pattern.firstMatch(message);
      if (match != null && match.groupCount >= 1) {
        final rateString = match.group(1);
        if (rateString != null) {
          return double.tryParse(rateString);
        }
      }
    }

    return null;
  }

  Future<void> startMonitoring() async {
    // Check for updates every 30 minutes
    // In a real app, this would be handled by a background service/worker
    while (true) {
      await checkForRateUpdates();
      await Future.delayed(const Duration(minutes: 30));
    }
  }

  // Method to manually trigger a rate update notification for testing
  Future<void> sendTestRateUpdateNotification() async {
    await _notificationService.showRateUpdateNotification(
      title: '⚡ Test: SAMELCO Rate Update',
      body: 'This is a test notification for rate updates.',
      postUrl: 'https://www.facebook.com/samelco',
      updateId: 'test_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}
