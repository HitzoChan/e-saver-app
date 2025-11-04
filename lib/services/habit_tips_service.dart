import '../models/appliance.dart';
import '../models/appliance_category.dart';

class HabitTipsService {
  static final HabitTipsService _instance = HabitTipsService._internal();
  factory HabitTipsService() => _instance;
  HabitTipsService._internal();

  // Comprehensive habit tips database
  final Map<String, List<String>> _englishTips = {
    // Specific appliance names (case-insensitive partial matches)
    'refrigerator': [
      'Don\'t open fridge unnecessarily - each opening costs energy',
      'Clean fridge coils every 6 months for better efficiency',
      'Set fridge to 4°C and freezer to -18°C for optimal energy use',
      'Ensure fridge door seals are tight to prevent cool air escape',
      'Keep fridge away from heat sources like ovens or direct sunlight',
      'Defrost freezer regularly to maintain efficiency',
    ],
    'fridge': [
      'Don\'t open fridge unnecessarily - each opening costs energy',
      'Clean fridge coils every 6 months for better efficiency',
      'Set fridge to 4°C and freezer to -18°C for optimal energy use',
      'Ensure fridge door seals are tight to prevent cool air escape',
      'Keep fridge away from heat sources like ovens or direct sunlight',
      'Defrost freezer regularly to maintain efficiency',
    ],
    'aircon': [
      'Set temperature to 25°C to save 10-15% on electricity',
      'Use fan together with aircon for faster and more efficient cooling',
      'Clean aircon filter every 2 weeks to maintain efficiency',
      'Turn off aircon when not in room or use timer',
      'Close windows and doors when aircon is running',
      'Service aircon annually for optimal performance',
    ],
    'air conditioner': [
      'Set temperature to 25°C to save 10-15% on electricity',
      'Use fan together with aircon for faster and more efficient cooling',
      'Clean aircon filter every 2 weeks to maintain efficiency',
      'Turn off aircon when not in room or use timer',
      'Close windows and doors when aircon is running',
      'Service aircon annually for optimal performance',
    ],
    'ac': [
      'Set temperature to 25°C to save 10-15% on electricity',
      'Use fan together with aircon for faster and more efficient cooling',
      'Clean aircon filter every 2 weeks to maintain efficiency',
      'Turn off aircon when not in room or use timer',
      'Close windows and doors when aircon is running',
      'Service aircon annually for optimal performance',
    ],
    'tv': [
      'Turn off TV completely when not watching (standby mode still uses power)',
      'Reduce screen brightness to save energy',
      'Use sleep timer or auto-shutoff features',
      'Unplug TV when not using for extended periods',
      'Use energy-efficient LED TV if possible',
    ],
    'television': [
      'Turn off TV completely when not watching (standby mode still uses power)',
      'Reduce screen brightness to save energy',
      'Use sleep timer or auto-shutoff features',
      'Unplug TV when not using for extended periods',
      'Use energy-efficient LED TV if possible',
    ],
    'washing machine': [
      'Use full load for washing machine to maximize efficiency',
      'Set to lowest comfortable temperature (cold water saves most energy)',
      'Use quick wash cycles when appropriate',
      'Clean lint filter after each use',
      'Air dry clothes when possible instead of using dryer',
    ],
    'washer': [
      'Use full load for washing machine to maximize efficiency',
      'Set to lowest comfortable temperature (cold water saves most energy)',
      'Use quick wash cycles when appropriate',
      'Clean lint filter after each use',
      'Air dry clothes when possible instead of using dryer',
    ],
    'microwave': [
      'Use microwave for quick reheating instead of conventional oven',
      'Avoid preheating unless absolutely necessary',
      'Use appropriate container size for better efficiency',
      'Follow recommended cooking times in manual',
      'Keep microwave clean for optimal performance',
    ],
    'oven': [
      'Use microwave for small portions instead of conventional oven',
      'Avoid preheating unless baking requires it',
      'Cook multiple items at once when possible',
      'Use oven light to check cooking progress instead of opening door',
      'Keep oven door seals clean and intact',
    ],
    'light': [
      'Use LED bulbs for 75% less energy than incandescent',
      'Turn off lights when leaving room',
      'Use natural light during daytime',
      'Clean light fixtures regularly for better brightness',
      'Install dimmer switches for adjustable lighting',
    ],
    'bulb': [
      'Use LED bulbs for 75% less energy than incandescent',
      'Turn off lights when leaving room',
      'Use natural light during daytime',
      'Clean light fixtures regularly for better brightness',
      'Install dimmer switches for adjustable lighting',
    ],
    'lamp': [
      'Use LED bulbs for 75% less energy than incandescent',
      'Turn off lights when leaving room',
      'Use natural light during daytime',
      'Clean light fixtures regularly for better brightness',
      'Install dimmer switches for adjustable lighting',
    ],
    'fan': [
      'Use fan on low speed when possible',
      'Turn off fan when leaving room',
      'Clean fan blades regularly for better airflow',
      'Set fan to blow air upward in summer for better cooling effect',
      'Use ceiling fan instead of aircon when temperature allows',
    ],
    'computer': [
      'Use sleep mode when not actively using computer',
      'Turn off computer completely when not using overnight',
      'Clean dust from vents and fans regularly',
      'Use power management settings in OS',
      'Unplug peripherals when not in use',
    ],
    'laptop': [
      'Use sleep mode when not actively using laptop',
      'Turn off completely when not using for extended periods',
      'Keep vents clear and use on hard surface for better cooling',
      'Reduce screen brightness to save battery and energy',
      'Close unnecessary programs and browser tabs',
    ],
    'pc': [
      'Use sleep mode when not actively using computer',
      'Turn off computer completely when not using overnight',
      'Clean dust from vents and fans regularly',
      'Use power management settings in OS',
      'Unplug peripherals when not in use',
    ],
    'dishwasher': [
      'Run full loads only to maximize water and energy efficiency',
      'Use energy-saving or eco mode when available',
      'Air dry dishes instead of using heat dry cycle',
      'Scrape plates before loading (reduces need for pre-rinse)',
      'Load dishwasher properly for best water circulation',
    ],
    'dryer': [
      'Use moisture sensor setting if available',
      'Clean lint filter before each use',
      'Dry full loads when possible',
      'Air dry clothes when weather permits',
      'Use lower heat settings when appropriate',
    ],
    'water heater': [
      'Set temperature to 120°F (49°C) to save energy and prevent burns',
      'Insulate hot water pipes to reduce heat loss',
      'Fix leaky faucets promptly',
      'Take shorter showers to reduce hot water usage',
      'Use low-flow showerheads for water conservation',
    ],
    'heater': [
      'Set thermostat to lowest comfortable temperature',
      'Use programmable thermostat to reduce usage when away',
      'Seal windows and doors to prevent heat loss',
      'Use space heater only in occupied rooms',
      'Service heating system annually',
    ],
    'coffee maker': [
      'Unplug when not in use (phantom load adds up)',
      'Use smaller pot size if making less coffee',
      'Descale regularly according to manufacturer instructions',
      'Turn off auto-brew feature if not needed',
      'Use thermal carafe instead of warming plate when possible',
    ],
    'toaster': [
      'Unplug when not in use',
      'Use appropriate toast setting (not highest unless needed)',
      'Clean crumbs regularly for safety and efficiency',
      'Consider using toaster oven for larger items',
      'Defrost bread first instead of using defrost function',
    ],
    'blender': [
      'Use pulse function instead of continuous blend when possible',
      'Clean immediately after use to prevent motor strain',
      'Use appropriate speed settings for different tasks',
      'Avoid overloading the blender',
      'Store properly to maintain blade sharpness',
    ],
    'vacuum': [
      'Empty dust bin regularly for optimal suction',
      'Change filters as recommended',
      'Use appropriate attachments for different surfaces',
      'Avoid overfilling dust bin',
      'Store cord properly to prevent damage',
    ],
  };

  final Map<String, List<String>> _filipinoTips = {
    // Specific appliance names (case-insensitive partial matches)
    'refrigerator': [
      'Huwag buksan ang ref kapag hindi kailangan - bawat pagbukas ay kumokonsumo ng kuryente',
      'Linisin ang ref coils tuwing 6 buwan para sa mas mahusay na efficiency',
      'Itakda ang ref sa 4°C at freezer sa -18°C para sa pinakamainam na paggamit ng kuryente',
      'Siguraduhing maayos ang pag-seal ng ref door upang hindi tumakas ang malamig na hangin',
      'Ilayo ang ref sa mga heat sources tulad ng oven o direktang sunlight',
      'Regular na defrost ang freezer para mapanatili ang efficiency',
    ],
    'fridge': [
      'Huwag buksan ang ref kapag hindi kailangan - bawat pagbukas ay kumokonsumo ng kuryente',
      'Linisin ang ref coils tuwing 6 buwan para sa mas mahusay na efficiency',
      'Itakda ang ref sa 4°C at freezer sa -18°C para sa pinakamainam na paggamit ng kuryente',
      'Siguraduhing maayos ang pag-seal ng ref door upang hindi tumakas ang malamig na hangin',
      'Ilayo ang ref sa mga heat sources tulad ng oven o direktang sunlight',
      'Regular na defrost ang freezer para mapanatili ang efficiency',
    ],
    'aircon': [
      'Itakda ang temperatura sa 25°C upang makatipid ng 10-15% sa kuryente',
      'Gamitin ang fan kasama ang aircon para mas mabilis at efficient na pag-cool',
      'Linisin ang aircon filter tuwing 2 linggo para mapanatili ang efficiency',
      'Patayin ang aircon kapag wala sa silid o gumamit ng timer',
      'Isara ang mga bintana at pintuan kapag nagre-run ang aircon',
      'Pa-service ang aircon taun-taon para sa optimal na performance',
    ],
    'air conditioner': [
      'Itakda ang temperatura sa 25°C upang makatipid ng 10-15% sa kuryente',
      'Gamitin ang fan kasama ang aircon para mas mabilis at efficient na pag-cool',
      'Linisin ang aircon filter tuwing 2 linggo para mapanatili ang efficiency',
      'Patayin ang aircon kapag wala sa silid o gumamit ng timer',
      'Isara ang mga bintana at pintuan kapag nagre-run ang aircon',
      'Pa-service ang aircon taun-taon para sa optimal na performance',
    ],
    'ac': [
      'Itakda ang temperatura sa 25°C upang makatipid ng 10-15% sa kuryente',
      'Gamitin ang fan kasama ang aircon para mas mabilis at efficient na pag-cool',
      'Linisin ang aircon filter tuwing 2 linggo para mapanatili ang efficiency',
      'Patayin ang aircon kapag wala sa silid o gumamit ng timer',
      'Isara ang mga bintana at pintuan kapag nagre-run ang aircon',
      'Pa-service ang aircon taun-taon para sa optimal na performance',
    ],
    'tv': [
      'Patayin ang TV nang lubusan kapag hindi nanonood (standby mode pa rin ay kumokonsumo)',
      'Bawasan ang screen brightness upang makatipid ng kuryente',
      'Gamitin ang sleep timer o auto-shutoff features',
      'Unplug ang TV kapag hindi ginagamit sa mahabang panahon',
      'Gamitin ang energy-efficient LED TV kung maaari',
    ],
    'television': [
      'Patayin ang TV nang lubusan kapag hindi nanonood (standby mode pa rin ay kumokonsumo)',
      'Bawasan ang screen brightness upang makatipid ng kuryente',
      'Gamitin ang sleep timer o auto-shutoff features',
      'Unplug ang TV kapag hindi ginagamit sa mahabang panahon',
      'Gamitin ang energy-efficient LED TV kung maaari',
    ],
    'washing machine': [
      'Gamitin ang full load para sa washing machine upang mapakinabangan ang efficiency',
      'Itakda sa pinakamababang temperatura na komportable (cold water ang pinakamakakatipid)',
      'Gamitin ang quick wash cycles kung appropriate',
      'Linisin ang lint filter pagkatapos ng bawat gamit',
      'Hang dry ang mga damit kung maaari sa halip na gumamit ng dryer',
    ],
    'washer': [
      'Gamitin ang full load para sa washing machine upang mapakinabangan ang efficiency',
      'Itakda sa pinakamababang temperatura na komportable (cold water ang pinakamakakatipid)',
      'Gamitin ang quick wash cycles kung appropriate',
      'Linisin ang lint filter pagkatapos ng bawat gamit',
      'Hang dry ang mga damit kung maaari sa halip na gumamit ng dryer',
    ],
    'microwave': [
      'Gamitin ang microwave para sa mabilis na pag-init sa halip na conventional oven',
      'Iwasan ang preheating maliban kung talagang kailangan',
      'Gamitin ang appropriate na laki ng container para sa mas mahusay na efficiency',
      'Sundin ang recommended cooking times sa manual',
      'Panatilihing malinis ang microwave para sa optimal na performance',
    ],
    'oven': [
      'Gamitin ang microwave para sa maliliit na portions sa halip na conventional oven',
      'Iwasan ang preheating maliban kung kailangan sa baking',
      'Magluto ng maraming items nang sabay kung maaari',
      'Gamitin ang oven light para suriin ang cooking progress sa halip na buksan ang door',
      'Panatilihing malinis ang oven door seals',
    ],
    'light': [
      'Gamitin ang LED bulbs para sa 75% na mas kaunting kuryente kaysa incandescent',
      'Patayin ang ilaw kapag lumalabas sa silid',
      'Gamitin ang natural light sa araw',
      'Linisin ang light fixtures regularly para sa mas magandang brightness',
      'Mag-install ng dimmer switches para sa adjustable na lighting',
    ],
    'bulb': [
      'Gamitin ang LED bulbs para sa 75% na mas kaunting kuryente kaysa incandescent',
      'Patayin ang ilaw kapag lumalabas sa silid',
      'Gamitin ang natural light sa araw',
      'Linisin ang light fixtures regularly para sa mas magandang brightness',
      'Mag-install ng dimmer switches para sa adjustable na lighting',
    ],
    'lamp': [
      'Gamitin ang LED bulbs para sa 75% na mas kaunting kuryente kaysa incandescent',
      'Patayin ang ilaw kapag lumalabas sa silid',
      'Gamitin ang natural light sa araw',
      'Linisin ang light fixtures regularly para sa mas magandang brightness',
      'Mag-install ng dimmer switches para sa adjustable na lighting',
    ],
    'fan': [
      'Gamitin ang fan sa low speed kung maaari',
      'Patayin ang fan kapag lumalabas sa silid',
      'Linisin ang fan blades regularly para sa mas mahusay na airflow',
      'Itakda ang fan na mag-blow ng hangin pataas sa summer para sa mas mahusay na cooling effect',
      'Gamitin ang ceiling fan sa halip na aircon kung maaari ang temperatura',
    ],
    'computer': [
      'Gamitin ang sleep mode kapag hindi aktibong ginagamit ang computer',
      'Patayin nang lubusan ang computer kapag hindi ginagamit sa gabi',
      'Linisin ang dust sa vents at fans regularly',
      'Gamitin ang power management settings sa OS',
      'Unplug ang mga peripherals kapag hindi ginagamit',
    ],
    'laptop': [
      'Gamitin ang sleep mode kapag hindi aktibong ginagamit ang laptop',
      'Patayin nang lubusan kapag hindi ginagamit sa mahabang panahon',
      'Panatilihing malinis ang vents at gamitin sa hard surface para sa mas mahusay na cooling',
      'Bawasan ang screen brightness para makatipid sa battery at kuryente',
      'Isara ang mga hindi kinakailangang programs at browser tabs',
    ],
    'pc': [
      'Gamitin ang sleep mode kapag hindi aktibong ginagamit ang computer',
      'Patayin nang lubusan ang computer kapag hindi ginagamit sa gabi',
      'Linisin ang dust sa vents at fans regularly',
      'Gamitin ang power management settings sa OS',
      'Unplug ang mga peripherals kapag hindi ginagamit',
    ],
    'dishwasher': [
      'Patakbuhin lang ang full loads para mapakinabangan ang water at energy efficiency',
      'Gamitin ang energy-saving o eco mode kung available',
      'Air dry ang dishes sa halip na gamitin ang heat dry cycle',
      'Scrape ang plates bago i-load (binabawasan ang need para sa pre-rinse)',
      'I-load ng maayos ang dishwasher para sa best water circulation',
    ],
    'dryer': [
      'Gamitin ang moisture sensor setting kung available',
      'Linisin ang lint filter bago bawat gamit',
      'Dry full loads kung maaari',
      'Air dry ang clothes kung maaari ang weather',
      'Gamitin ang lower heat settings kung appropriate',
    ],
    'water heater': [
      'Itakda ang temperatura sa 120°F (49°C) para makatipid ng kuryente at pigilan ang burns',
      'Insulate ang hot water pipes para bawasan ang heat loss',
      'Ayusin agad ang mga tumutulong faucets',
      'Mag-shower nang mas maikli para bawasan ang hot water usage',
      'Gamitin ang low-flow showerheads para sa water conservation',
    ],
    'heater': [
      'Itakda ang thermostat sa pinakamababang komportableng temperatura',
      'Gamitin ang programmable thermostat para bawasan ang usage kapag wala sa bahay',
      'Seal ang mga bintana at pintuan para pigilan ang heat loss',
      'Gamitin ang space heater lang sa occupied rooms',
      'Pa-service ang heating system taun-taon',
    ],
    'coffee maker': [
      'Unplug kapag hindi ginagamit (phantom load ay nagdadagdag)',
      'Gamitin ang mas maliit na pot size kung mas kaunting coffee ang ginagawa',
      'Descale regularly ayon sa manufacturer instructions',
      'Patayin ang auto-brew feature kung hindi kailangan',
      'Gamitin ang thermal carafe sa halip na warming plate kung maaari',
    ],
    'toaster': [
      'Unplug kapag hindi ginagamit',
      'Gamitin ang appropriate na toast setting (hindi highest maliban kung kailangan)',
      'Linisin ang crumbs regularly para sa safety at efficiency',
      'Isa-isip ang paggamit ng toaster oven para sa mas malalaking items',
      'Defrost muna ang bread sa halip na gamitin ang defrost function',
    ],
    'blender': [
      'Gamitin ang pulse function sa halip na continuous blend kung maaari',
      'Linisin agad pagkatapos gamitin para pigilan ang motor strain',
      'Gamitin ang appropriate na speed settings para sa different tasks',
      'Iwasan ang overloading ng blender',
      'I-store ng maayos para mapanatili ang blade sharpness',
    ],
    'vacuum': [
      'Empty dust bin regularly para sa optimal na suction',
      'Palitan ang filters ayon sa recommendation',
      'Gamitin ang appropriate na attachments para sa different surfaces',
      'Iwasan ang overfilling ng dust bin',
      'I-store ng maayos ang cord para pigilan ang damage',
    ],
  };

  // Category-based fallback tips
  final Map<ApplianceCategory, List<String>> _englishCategoryTips = {
    ApplianceCategory.cooling: [
      'Set temperature to 25°C to save 10-15% on electricity',
      'Use fan together with aircon for faster cooling',
      'Clean filters every 2 weeks to maintain efficiency',
      'Turn off when not in room or use timer',
      'Close windows and doors when cooling',
      'Service units annually for optimal performance',
    ],
    ApplianceCategory.entertainment: [
      'Turn off completely when not watching',
      'Reduce screen brightness to save energy',
      'Use sleep timer or auto-shutoff features',
      'Unplug when not using for extended periods',
      'Use energy-efficient LED displays when possible',
    ],
    ApplianceCategory.kitchen: [
      'Use microwave for quick reheating instead of oven',
      'Don\'t open fridge unnecessarily',
      'Clean coils and filters regularly',
      'Set to optimal temperatures',
      'Keep appliances away from heat sources',
    ],
    ApplianceCategory.cleaning: [
      'Use full loads when possible',
      'Set to lowest comfortable temperature',
      'Clean filters and lint traps regularly',
      'Use energy-saving modes when available',
      'Air dry when weather permits',
    ],
    ApplianceCategory.personalCare: [
      'Use LED lighting for better efficiency',
      'Turn off when leaving room',
      'Use natural light during day',
      'Clean fixtures regularly',
      'Use programmable timers when possible',
    ],
    ApplianceCategory.other: [
      'Turn off when not in use',
      'Use in most efficient way possible',
      'Regularly check condition and clean',
      'Follow manufacturer maintenance guidelines',
      'Consider energy-efficient alternatives',
    ],
  };

  final Map<ApplianceCategory, List<String>> _filipinoCategoryTips = {
    ApplianceCategory.cooling: [
      'Itakda ang temperatura sa 25°C upang makatipid ng 10-15% sa kuryente',
      'Gamitin ang fan kasama ang aircon para mas mabilis na pag-cool',
      'Linisin ang filters tuwing 2 linggo para mapanatili ang efficiency',
      'Patayin kapag wala sa silid o gumamit ng timer',
      'Isara ang bintana at pintuan habang nagre-cool',
      'Pa-service ang units taun-taon para sa optimal na performance',
    ],
    ApplianceCategory.entertainment: [
      'Patayin nang lubusan kapag hindi nanonood',
      'Bawasan ang screen brightness upang makatipid ng kuryente',
      'Gamitin ang sleep timer o auto-shutoff features',
      'Unplug kapag hindi ginagamit sa mahabang panahon',
      'Gamitin ang energy-efficient LED displays kung maaari',
    ],
    ApplianceCategory.kitchen: [
      'Gamitin ang microwave para sa mabilis na pag-init sa halip na oven',
      'Huwag buksan ang ref kapag hindi kailangan',
      'Linisin ang coils at filters regularly',
      'Itakda sa optimal na temperatura',
      'Ilayo ang appliances sa heat sources',
    ],
    ApplianceCategory.cleaning: [
      'Gamitin ang full loads kung maaari',
      'Itakda sa pinakamababang komportableng temperatura',
      'Linisin ang filters at lint traps regularly',
      'Gamitin ang energy-saving modes kung available',
      'Air dry kung maaari ang weather',
    ],
    ApplianceCategory.personalCare: [
      'Gamitin ang LED lighting para sa mas mahusay na efficiency',
      'Patayin kapag lumalabas sa silid',
      'Gamitin ang natural light sa araw',
      'Linisin ang fixtures regularly',
      'Gamitin ang programmable timers kung maaari',
    ],
    ApplianceCategory.other: [
      'Patayin kapag hindi ginagamit',
      'Gamitin sa pinaka-efficient na paraan',
      'Regular na suriin ang kondisyon at linisin',
      'Sundin ang manufacturer maintenance guidelines',
      'Isa-isip ang energy-efficient alternatives',
    ],
  };

  /// Get habit tips for a specific appliance
  List<String> getHabitTips(Appliance appliance, String language) {
    final isFilipino = language == 'Filipino';
    final tipsMap = isFilipino ? _filipinoTips : _englishTips;
    final categoryTipsMap = isFilipino ? _filipinoCategoryTips : _englishCategoryTips;

    final applianceName = appliance.name.toLowerCase().trim();

    // 1. Try exact appliance name match first
    if (tipsMap.containsKey(applianceName)) {
      return tipsMap[applianceName]!;
    }

    // 2. Try partial name matching (most specific to least specific)
    final nameParts = applianceName.split(' ');
    for (int i = nameParts.length; i > 0; i--) {
      final partialName = nameParts.take(i).join(' ');
      if (tipsMap.containsKey(partialName)) {
        return tipsMap[partialName]!;
      }
    }

    // 3. Try individual word matching
    for (final word in nameParts) {
      if (word.length > 2 && tipsMap.containsKey(word)) {
        return tipsMap[word]!;
      }
    }

    // 4. Try fuzzy matching for common appliance types
    final fuzzyMatches = _getFuzzyMatches(applianceName, tipsMap);
    if (fuzzyMatches.isNotEmpty) {
      return tipsMap[fuzzyMatches.first]!;
    }

    // 5. Fall back to category-based tips
    if (categoryTipsMap.containsKey(appliance.category)) {
      return categoryTipsMap[appliance.category]!;
    }

    // 6. Ultimate fallback - general tips
    return isFilipino
        ? [
            'Patayin kapag hindi ginagamit',
            'Gamitin sa pinaka-efficient na paraan',
            'Regular na suriin ang kondisyon',
            'Sundin ang user manual para sa proper usage',
            'Isa-isip ang energy-efficient alternatives',
          ]
        : [
            'Turn off when not in use',
            'Use in most efficient way',
            'Regularly check condition',
            'Follow user manual for proper usage',
            'Consider energy-efficient alternatives',
          ];
  }

  /// Get fuzzy matches for appliance names
  List<String> _getFuzzyMatches(String applianceName, Map<String, List<String>> tipsMap) {
    final matches = <String>[];

    // Common appliance name variations
    final variations = {
      'washing machine': ['washer', 'laundry', 'washing'],
      'air conditioner': ['aircon', 'ac', 'cooling', 'air conditioning'],
      'television': ['tv', 'monitor', 'display'],
      'refrigerator': ['fridge', 'freezer', 'cooler'],
      'microwave oven': ['microwave', 'oven'],
      'clothes dryer': ['dryer', 'clothes'],
      'dish washer': ['dishwasher', 'dishes'],
      'water heater': ['heater', 'hot water'],
      'ceiling fan': ['fan', 'ceiling'],
      'coffee machine': ['coffee maker', 'coffeemaker'],
    };

    for (final entry in variations.entries) {
      if (applianceName.contains(entry.key) ||
          entry.value.any((variation) => applianceName.contains(variation))) {
        if (tipsMap.containsKey(entry.key)) {
          matches.add(entry.key);
        }
      }
    }

    return matches;
  }

  /// Get all available appliance types that have tips
  List<String> getAvailableApplianceTypes(String language) {
    final tipsMap = language == 'Filipino' ? _filipinoTips : _englishTips;
    return tipsMap.keys.toList()..sort();
  }

  /// Check if an appliance type has specific tips
  bool hasSpecificTips(String applianceName, String language) {
    final tipsMap = language == 'Filipino' ? _filipinoTips : _englishTips;
    final name = applianceName.toLowerCase().trim();

    return tipsMap.containsKey(name) ||
           _getFuzzyMatches(name, tipsMap).isNotEmpty;
  }
}
