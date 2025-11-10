class AppConstants {
  // App Info
  static const String appName = 'E-Saver';
  static const String appTagline = 'Track Your Energy Usage';

  // OneSignal Configuration
  static const String oneSignalAppId = '50beb769-6563-4cd3-a98a-ef3437ae5a2e';
  static const String oneSignalRestApiKey = 'dqhkwveftehde5aqftvp3ri2u';

  // Facebook Monitoring Configuration
  static const String samElcoPageId = '117290636838993'; // SAMELCO Facebook Page ID
  static const String facebookGraphApiUrl = 'https://graph.facebook.com/v18.0';

  // Navigation
  static const List<String> navItems = [
    'Home',
    'Statistics',
    'Add',
    'Planner',
    'Profile',
  ];

  // Appliance Categories
  static const List<Map<String, dynamic>> applianceCategories = [
    {'name': 'Washing', 'icon': '🧺', 'count': 1},
    {'name': 'TV', 'icon': '📺', 'count': 3},
    {'name': 'Essentials', 'icon': '💡', 'count': 1},
    {'name': 'Hairdryer', 'icon': '💨', 'count': 1},
    {'name': 'Roomcooler', 'icon': '❄️', 'count': 1},
  ];

  // Sample Appliances
  static const List<Map<String, dynamic>> sampleAppliances = [
    {
      'name': 'Refrigerator',
      'category': 'Essentials',
      'estimate': 'PHP 245.60',
      'usage': '550 kWh',
    },
    {
      'name': 'Aircon',
      'category': 'Cooling Budget',
      'estimate': 'PHP 8.XX',
      'usage': '101.83 kW',
    },
    {
      'name': 'TV',
      'category': 'Cleaning Budget',
      'estimate': 'PHP 13.XX',
      'usage': 'EUI 104 (G) PHP 13.XX',
    },
  ];

  // Energy Saving Tips
  static const List<Map<String, String>> energyTips = [
    {
      'title': 'Unplug idle devices',
      'subtitle': 'Save Power',
    },
    {
      'title': 'Use natural light',
      'subtitle': 'Save Power',
    },
    {
      'title': 'SAME/C rice update!',
      'subtitle': 'View changes',
    },
  ];
}
