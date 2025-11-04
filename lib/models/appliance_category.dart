enum ApplianceCategory {
  kitchen('Kitchen', '🍳'),
  cooling('Cooling', '❄️'),
  laundry('Laundry', '🧺'),
  entertainment('Entertainment', '🎮'),
  electronics('Electronics', '📱'),
  cleaning('Cleaning', '🧹'),
  personalCare('Personal Care', '💆'),
  lighting('Lighting', '💡'),
  business('Business', '🏫'),
  dorm('Dorm', '🏠'),
  essentials('Essentials', '🏠'),
  other('Other', '🔌');

  const ApplianceCategory(this.displayName, this.icon);

  final String displayName;
  final String icon;

  static ApplianceCategory fromString(String value) {
    return ApplianceCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => ApplianceCategory.other,
    );
  }
}
