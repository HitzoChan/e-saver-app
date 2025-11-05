import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  String _language = 'English';
  String _currency = 'PHP';
  double _defaultElectricityRate = 12.0;
  bool _isLoading = true;

  // Supported options
  static const List<String> supportedLanguages = ['English', 'Filipino'];
  static const List<String> supportedCurrencies = ['PHP', 'USD'];

  // Getters
  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  String get currency => _currency;
  double get defaultElectricityRate => _defaultElectricityRate;
  bool get isLoading => _isLoading;

  // Currency symbols
  String get currencySymbol {
    switch (_currency) {
      case 'PHP':
        return 'PHP';
      case 'USD':
        return '\$';
      default:
        return 'PHP';
    }
  }

  // Load settings from SharedPreferences
  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _language = prefs.getString('language') ?? 'English';
    _currency = prefs.getString('currency') ?? 'PHP';
    _defaultElectricityRate = prefs.getDouble('defaultElectricityRate') ?? 13.5584;

    _isLoading = false;
    notifyListeners();
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setString('language', _language);
    await prefs.setString('currency', _currency);
    await prefs.setDouble('defaultElectricityRate', _defaultElectricityRate);
  }

  // Setters
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setCurrency(String value) async {
    _currency = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setDefaultElectricityRate(double value) async {
    _defaultElectricityRate = value;
    await _saveSettings();
    notifyListeners();
  }

  // Get localized text (basic implementation)
  String getLocalizedText(String key) {
    const englishTranslations = {
      'no_appliance_insight': '💡 Add your appliances to see personalized energy-saving insights!',
      'high_bill_insight': '⚠️ Your estimated monthly bill is {currencySymbol}{cost}. Consider reducing usage of high-wattage appliances during peak hours.',
      'medium_bill_insight': '📊 Your estimated monthly bill is {currencySymbol}{cost}. Good job so far - small adjustments can save even more!',
      'low_bill_insight': '🎉 Great job! Your estimated monthly bill is {currencySymbol}{cost}. Keep up the efficient energy usage!',
      'tip_monitor_usage': '💡 Tip: Monitor the usage of {appliance} as it is your highest energy consumer.',
    };

    if (_language == 'Filipino') {
      const translations = {
        'Settings': 'Mga Setting',
        'Language': 'Wika',
        'Currency': 'Pera',
        'Dark Mode': 'Madilim na Mode',
        'Default Electricity Rate': 'Default na Rate ng Kuryente',
        'Save': 'I-save',
        'Cancel': 'Kanselahin',
        'Dashboard': 'Dashboard',
        'Statistics': 'Istatistika',
        'Add Appliance': 'Magdagdag ng Appliance',
        'Planner': 'Planner',
        'Help & Support': 'Tulong at Suporta',
        'About': 'Tungkol',
        'Logout': 'Mag-logout',
        'Your Usage Stats': 'Iyong Stats sa Paggamit',
        'Total Usage': 'Kabuuang Paggamit',
        'Total Cost': 'Kabuuang Gastos',
        'Avg/Day': 'Avg/Araw',
        'Appliance Breakdown': 'Breakdown ng Appliance',
        'Weekly Trend': 'Trend sa Linggo',
        'Energy Insight': 'Insight sa Enerhiya',
        'E-Saver Dashboard': 'E-Saver Dashboard',
        'Get Started': 'Magsimula',
        'Energy Saver': 'Energy Saver',
        'Appliances': 'Mga Appliance',
        'Daily Usage': 'Paggamit sa Araw',
        'Electricity Rate': 'Rate ng Kuryente',
        'Set Rate': 'Itakda ang Rate',
        'Appearance': 'Hitsura',
        'Language & Region': 'Wika at Rehiyon',
        'Electricity': 'Kuryente',
        'Switch to dark theme': 'Lumipat sa madilim na tema',
        'Rate per kWh': 'Rate kada kWh',
        'Enter rate': 'Ilagay ang rate',
        'Save Settings': 'I-save ang Settings',
        'Settings saved successfully!': 'Matagumpay na na-save ang settings!',
        'Notifications coming soon!': 'Darating ang notifications!',
        'Settings coming soon!': 'Darating ang settings!',
        'Help coming soon!': 'Darating ang tulong!',
        'About E-Saver': 'Tungkol sa E-Saver',
        'Logout coming soon!': 'Darating ang logout!',
        'Error loading dashboard': 'Error sa pag-load ng dashboard',
        'Retry': 'Subukang muli',
        'No appliance usage data yet.\nStart tracking to see breakdown!': 'Wala pang data sa paggamit ng appliance.\nMagsimula ng pag-track para makita ang breakdown!',
        'no_appliance_insight': '💡 Magdagdag ng iyong mga appliance para makita ang personalized na energy-saving insights!',
        'high_bill_insight': '⚠️ Ang iyong tinantyang buwanang bill ay {currencySymbol}{cost}. Isaalang-alang ang pagbawas sa paggamit ng high-wattage appliances sa peak hours.',
        'medium_bill_insight': '📊 Ang iyong tinantyang buwanang bill ay {currencySymbol}{cost}. Mabuti ang ginagawa mo - maliliit na adjustment ay maaaring mag-save pa!',
        'low_bill_insight': '🎉 Mahusay na trabaho! Ang iyong tinantyang buwanang bill ay {currencySymbol}{cost}. Panatilihin ang efficient na paggamit ng enerhiya!',
        'tip_monitor_usage': '💡 Tip: Monitor ang paggamit ng {appliance} dahil ito ang iyong pinakamataas na energy consumer.',
        'Loading...': 'Naglo-load...',
        'User': 'User',
        'Add New Appliance': 'Magdagdag ng Appliance',
        'Edit Appliance': 'I-edit ang Appliance',
        'Quick Add (Built-in Appliances)': 'Mabilis na Pagdagdag (Built-in Appliances)',
        'Add Custom Appliance': 'Magdagdag ng Custom Appliance',
        'Appliance Name': 'Pangalan ng Appliance',
        'e.g., Laptop, Blender': 'hal., Laptop, Blender',
        'Wattage (W)': 'Wattage (W)',
        'e.g., 100': 'hal., 100',
        'Hours per Day': 'Oras kada Araw',
        'Minutes per Day': 'Minuto kada Araw',
        'e.g., 2.5': 'hal., 2.5',
        'e.g., 30': 'hal., 30',
        'Unit': 'Yunit',
        'Hours': 'Oras',
        'Minutes': 'Minuto',
        'Category': 'Kategorya',
        'Update Appliance': 'I-update ang Appliance',
        'Set Usage Time for': 'Itakda ang Oras ng Paggamit para sa',
        'How many': 'Ilan ang',
        'per day does this appliance run?': 'kada araw ang appliance na ito ay tumatakbo?',
        'Required': 'Kinakailangan',
        'Invalid': 'Hindi Valid',
        'Max 24h': 'Max 24h',
        'Max 1440m': 'Max 1440m',
        'Add': 'Idagdag',
        'added successfully!': 'matagumpay na naidagdag!',
        'Error adding appliance:': 'Error sa pagdagdag ng appliance:',
        'Keep\nGoodHabits': 'Mabuting\nUgali',
        'Essentials\nBudget': 'Budget\nsa mga Pangunahing',
        'Tips\nTricks': 'Tips\nat Tricks',
        'No Budget Set': 'Walang Budget na Itinakda',
        'Current Estimate': 'Kasalukuyang Tantyang',
        'Cooling Budget': 'Budget sa Pagpapalamig',
        'Update Monthly Budget': 'I-update ang Buwanang Budget',
        'Good habits coming soon!': 'Darating ang mabubuting ugali!',
        'Essentials budget coming soon!': 'Darating ang budget sa essentials!',
        'Energy tips coming soon!': 'Darating ang energy tips!',
        'Good Habits': 'Mabuting Ugali',
        'Keep Good Habits': 'Panatilihin ang Mabuting Ugali',
        'Develop better electricity usage habits': 'Bumuo ng mas mabuting ugali sa paggamit ng kuryente',
        'Daily kWh': 'Araw-araw na kWh',
        'Monthly Cost': 'Buwanang Gastos',
        'Habit Tips': 'Mga Tip sa Ugali',
        'Cooling Tips': 'Mga Tip sa Pagpapalamig',
        'Set your aircon temperature to 25°C or higher to save energy.': 'Itakda ang temperatura ng aircon sa 25°C o mas mataas para makatipid ng enerhiya.',
        'Use fans instead of aircon when possible.': 'Gamitin ang bentilador sa halip na aircon kung maaari.',
        'Clean aircon filters regularly to maintain efficiency.': 'Linisin ang mga filter ng aircon nang regular para mapanatili ang kahusayan.',
        'Entertainment Tips': 'Mga Tip sa Libangan',
        'Turn off TV and other devices when not in use.': 'Patayin ang TV at ibang device kapag hindi ginagamit.',
        'Use power strips to easily turn off multiple devices.': 'Gamitin ang power strip para madaling patayin ang maraming device.',
        'Adjust TV brightness to save energy.': 'I-adjust ang brightness ng TV para makatipid ng enerhiya.',
        'Essentials Tips': 'Mga Tip sa mga Pangunahing Bagay',
        'Keep refrigerator temperature between 3-5°C.': 'Panatilihin ang temperatura ng refrigerator sa 3-5°C.',
        'Defrost freezer regularly.': 'I-defrost ang freezer nang regular.',
        'Avoid opening refrigerator door frequently.': 'Iwasan ang madalas na pagbukas ng refrigerator door.',
        'Cleaning Tips': 'Mga Tip sa Paglilinis',
        'Use timer for washing machine to avoid over-washing.': 'Gamitin ang timer sa washing machine para iwasan ang sobrang paghuhugas.',
        'Wash full loads only.': 'Maghugas lamang ng buong load.',
        'Check for proper insulation in your home.': 'Suriin ang tamang insulation sa iyong bahay.',
        'Personal Care Tips': 'Mga Tip sa Personal na Pangangalaga',
        'Switch to LED bulbs for better efficiency.': 'Lumipat sa LED bulbs para sa mas mabuting kahusayan.',
        'Turn off lights when leaving a room.': 'Patayin ang mga ilaw kapag umaalis sa isang kwarto.',
        'Use natural light when possible.': 'Gamitin ang natural na ilaw kung maaari.',
        'Personal Information': 'Personal na Impormasyon',
        'Update your profile details': 'I-update ang iyong mga detalye sa profile',
        'Notifications': 'Mga Notification',
        'Manage notification preferences': 'Pamahalaan ang mga preference sa notification',
        'Energy Tips': 'Mga Tip sa Enerhiya',
        'View energy saving tips': 'Tingnan ang mga tip sa pag-save ng enerhiya',
        'App preferences and configuration': 'Mga preference at configuration ng app',
        'Notification Settings': 'Mga Setting sa Notification',
        'Enable Notifications': 'Paganahin ang mga Notification',
        'Receive updates about electricity rates and energy tips': 'Tumanggap ng mga update tungkol sa electricity rates at energy tips',
        'Notification Types': 'Mga Uri ng Notification',
        'Electricity Rate Updates': 'Mga Update sa Electricity Rate',
        'Get notified when SAMELCO updates rates': 'Mabigyan ng abiso kapag nag-update ang SAMELCO ng rates',
        'Energy Saving Tips': 'Mga Tip sa Pag-save ng Enerhiya',
        'Weekly tips to reduce your electricity bill': 'Lingguhang mga tip para bawasan ang electricity bill',
        'Weekly Reports': 'Mga Lingguhang Report',
        'Summary of your energy usage': 'Buod ng iyong paggamit ng enerhiya',
        'Done': 'Tapos na',
        'Refrigerator': 'Refrigerator',
        'LED TV': 'LED TV',
        'Washing Machine': 'Washing Machine',
        'Air Conditioner': 'Aircon',
        'Electric Fan': 'Bentilador',
        'Microwave': 'Microwave',
        'Hair Dryer': 'Hair Dryer',
        'Electric Kettle': 'Kettle',
        'Rice Cooker': 'Rice Cooker',
        'Blender': 'Blender',
        'Toaster': 'Toaster',
        'Coffee Maker': 'Coffee Maker',
        'Dishwasher': 'Dishwasher',
        'Vacuum Cleaner': 'Vacuum Cleaner',
        'Iron': 'Plantsa',
        'Connections': 'Mga Koneksyon',
        'Avg Bill Monthly': 'Avg Bill\nBuwanang',
        'Household Average': 'Average\nsa Bahay',
        'No appliances added yet.\nTap the + button to add your first appliance!': 'Wala pang appliance na naidagdag.\nPindutin ang + button para magdagdag ng unang appliance!',
        'Set Monthly Budget': 'Itakda ang Buwanang Budget',
        'Monthly Budget (PHP)': 'Buwanang Budget (PHP)',
        'Set your target monthly electricity expense': 'Itakda ang iyong target na buwanang gastos sa kuryente',
        'Alert Settings': 'Mga Setting sa Alerto',
        'Enable Budget Alerts': 'Paganahin ang mga Alerto sa Budget',
        'Get notified when approaching budget limit': 'Mabigyan ng abiso kapag malapit na sa limitasyon ng budget',
        'Alert Threshold': 'Threshold ng Alerto',
        'Get alerted when you reach this percentage of your budget': 'Mabigyan ng alerto kapag umabot sa ganitong porsyento ng iyong budget',
        'Save Budget': 'I-save ang Budget',
        'Features': 'Mga Tampok',
        'Contact Us': 'Makipag-ugnayan sa Amin',
        'Privacy Policy': 'Patakaran sa Privacy',
        'Terms of Service': 'Mga Tuntunin ng Serbisyo',
        'Frequently Asked Questions': 'Mga Madalas Itanong',
        'Contact Support': 'Makipag-ugnayan sa Suporta',
        'User Guide': 'Gabay ng User',
      };
      return translations[key] ?? englishTranslations[key] ?? key;
    }
    return englishTranslations[key] ?? key;
  }
}
