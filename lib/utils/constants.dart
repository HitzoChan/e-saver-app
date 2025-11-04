class AppConstants {
  // App Info
  static const String appName = 'E-Saver';
  static const String appTagline = 'Track Your Energy Usage';
  
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
      'estimate': 'P245.60',
      'usage': '550 kWh',
    },
    {
      'name': 'Aircon',
      'category': 'Cooling Budget',
      'estimate': 'PX8.XX',
      'usage': '101.83 kW',
    },
    {
      'name': 'TV',
      'category': 'Cleaning Budget',
      'estimate': 'P13.XX',
      'usage': 'EUI 104 (G) P13.XX',
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
