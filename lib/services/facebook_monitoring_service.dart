import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'notification_service.dart';

class FacebookMonitoringService {
  static const String _samElcoPageId = '117290636838993'; // Updated with your Facebook page ID for "𝐻𝑜𝓉-𝒞𝒽𝑜𝒸𝑜𝓁𝒶𝓉𝑒"
  static const String _facebookGraphApiUrl = 'https://graph.facebook.com/v18.0';
  static const String _accessToken = 'EAATR4ZBcmDZBUBPZBK2oZBZChbLyEmbEZCUHtmRKJidx0NGZCNAJOJnuXXYNR8EnfDOrHmX27iHrZB6qJKH8ffwfyejlAXJcXPOqZChZBLuf3TZAGz3YSgcZBKMhfZCjBjJqZC6ELYtD6ZApZCH9gAtIGvHwaGlbtHDxrT1DINFDBL1CMQpq9su3ZANkr6vksZBDtSWZBDeCAj9uKUZD'; // Updated with provided access token

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
      // Log error in development, handle gracefully in production
      developer.log('Error checking Facebook posts: $e', name: 'FacebookMonitoringService');
    }
  }

  Future<void> _analyzePost(Map<String, dynamic> post) async {
    final message = post['message'] as String? ?? '';
    final postId = post['id'] as String;
    final permalinkUrl = post['permalink_url'] as String?;

    // Check if post contains rate-related keywords
    final rateKeywords = [
      'rate', 'rates', 'electricity rate', 'power rate',
      'samelco rate', 'rate update', 'new rate', 'rate change',
      'PHP', 'peso', 'centavo', 'per kwh', '/kWh'
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
            ? 'New electricity rate detected: PHP ${extractedRate.toStringAsFixed(2)}/kWh'
            : 'SAMELCO has posted about electricity rates. Tap to view details.',
        postUrl: permalinkUrl ?? 'https://www.facebook.com/samelco/posts/$postId',
        updateId: postId,
      );
    }
  }

  double? _extractRateFromMessage(String message) {
    // Simple regex to extract rate patterns like "PHP 12.50/kWh" or "12.50 per kWh"
    final ratePatterns = [
      RegExp(r'PHP(\d+\.?\d*)/kWh', caseSensitive: false),
      RegExp(r'PHP(\d+\.?\d*)\s*per\s*kWh', caseSensitive: false),
      RegExp(r'(\d+\.?\d*)\s*peso.*kWh', caseSensitive: false),
      RegExp(r'rate.*PHP(\d+\.?\d*)', caseSensitive: false),
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
    // Note: This infinite loop is for demonstration; in production, use proper scheduling
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
