import 'appliance.dart';
import 'appliance_category.dart';

class BuiltInAppliances {
  static final List<Appliance> all = [
    // Kitchen Appliances
    Appliance.builtIn(
      name: 'Rice Cooker',
      category: ApplianceCategory.kitchen,
      wattage: 700,
    ),
    Appliance.builtIn(
      name: 'Refrigerator',
      category: ApplianceCategory.kitchen,
      wattage: 150,
    ),
    Appliance.builtIn(
      name: 'Chest Freezer',
      category: ApplianceCategory.kitchen,
      wattage: 200,
    ),
    Appliance.builtIn(
      name: 'Microwave Oven',
      category: ApplianceCategory.kitchen,
      wattage: 1000,
    ),
    Appliance.builtIn(
      name: 'Induction Cooker',
      category: ApplianceCategory.kitchen,
      wattage: 1800,
    ),
    Appliance.builtIn(
      name: 'Electric Stove',
      category: ApplianceCategory.kitchen,
      wattage: 1500,
    ),
    Appliance.builtIn(
      name: 'Oven Toaster',
      category: ApplianceCategory.kitchen,
      wattage: 1200,
    ),
    Appliance.builtIn(
      name: 'Air Fryer',
      category: ApplianceCategory.kitchen,
      wattage: 1500,
    ),
    Appliance.builtIn(
      name: 'Electric Kettle',
      category: ApplianceCategory.kitchen,
      wattage: 1500,
    ),
    Appliance.builtIn(
      name: 'Blender',
      category: ApplianceCategory.kitchen,
      wattage: 400,
    ),
    Appliance.builtIn(
      name: 'Coffee Maker',
      category: ApplianceCategory.kitchen,
      wattage: 900,
    ),
    Appliance.builtIn(
      name: 'Slow Cooker',
      category: ApplianceCategory.kitchen,
      wattage: 200,
    ),
    Appliance.builtIn(
      name: 'Deep Fryer',
      category: ApplianceCategory.kitchen,
      wattage: 1700,
    ),
    Appliance.builtIn(
      name: 'Sandwich Maker',
      category: ApplianceCategory.kitchen,
      wattage: 750,
    ),
    Appliance.builtIn(
      name: 'Pressure Cooker (Electric)',
      category: ApplianceCategory.kitchen,
      wattage: 1000,
    ),
    Appliance.builtIn(
      name: 'Juicer',
      category: ApplianceCategory.kitchen,
      wattage: 500,
    ),
    Appliance.builtIn(
      name: 'Food Processor',
      category: ApplianceCategory.kitchen,
      wattage: 700,
    ),
    Appliance.builtIn(
      name: 'Water Dispenser (Hot/Cold)',
      category: ApplianceCategory.kitchen,
      wattage: 500,
    ),
    Appliance.builtIn(
      name: 'Bread Maker',
      category: ApplianceCategory.kitchen,
      wattage: 600,
    ),
    Appliance.builtIn(
      name: 'Electric Grill / Griddle',
      category: ApplianceCategory.kitchen,
      wattage: 1400,
    ),
    Appliance.builtIn(
      name: 'Ice Maker / Ice Crusher',
      category: ApplianceCategory.kitchen,
      wattage: 200,
    ),
    Appliance.builtIn(
      name: 'Rice Mill (Mini)',
      category: ApplianceCategory.kitchen,
      wattage: 2000,
    ),
    Appliance.builtIn(
      name: 'Dish Sterilizer',
      category: ApplianceCategory.kitchen,
      wattage: 400,
    ),
    Appliance.builtIn(
      name: 'Electric Knife Sharpener',
      category: ApplianceCategory.kitchen,
      wattage: 50,
    ),
    Appliance.builtIn(
      name: 'Food Warmer / Bain Marie',
      category: ApplianceCategory.kitchen,
      wattage: 1200,
    ),
    Appliance.builtIn(
      name: 'Water Filter with UV Light',
      category: ApplianceCategory.kitchen,
      wattage: 20,
    ),

    // Cooling & Comfort
    Appliance.builtIn(
      name: 'Air Conditioner (Window Type)',
      category: ApplianceCategory.cooling,
      wattage: 1200,
    ),
    Appliance.builtIn(
      name: 'Air Conditioner (Split Type)',
      category: ApplianceCategory.cooling,
      wattage: 1500,
    ),
    Appliance.builtIn(
      name: 'Electric Fan (Stand/Table)',
      category: ApplianceCategory.cooling,
      wattage: 60,
    ),
    Appliance.builtIn(
      name: 'Ceiling Fan',
      category: ApplianceCategory.cooling,
      wattage: 70,
    ),
    Appliance.builtIn(
      name: 'Air Cooler',
      category: ApplianceCategory.cooling,
      wattage: 150,
    ),
    Appliance.builtIn(
      name: 'Air Purifier',
      category: ApplianceCategory.cooling,
      wattage: 50,
    ),
    Appliance.builtIn(
      name: 'Dehumidifier',
      category: ApplianceCategory.cooling,
      wattage: 400,
    ),
    Appliance.builtIn(
      name: 'Exhaust Fan',
      category: ApplianceCategory.cooling,
      wattage: 60,
    ),
    Appliance.builtIn(
      name: 'Electric Mosquito Killer / Zapper',
      category: ApplianceCategory.cooling,
      wattage: 20,
    ),
    Appliance.builtIn(
      name: 'Humidifier / Diffuser',
      category: ApplianceCategory.cooling,
      wattage: 20,
    ),

    // Laundry
    Appliance.builtIn(
      name: 'Washing Machine (Top Load)',
      category: ApplianceCategory.cleaning,
      wattage: 400,
    ),
    Appliance.builtIn(
      name: 'Washing Machine (Front Load)',
      category: ApplianceCategory.cleaning,
      wattage: 1500,
    ),
    Appliance.builtIn(
      name: 'Clothes Dryer',
      category: ApplianceCategory.cleaning,
      wattage: 3000,
    ),
    Appliance.builtIn(
      name: 'Electric Iron',
      category: ApplianceCategory.cleaning,
      wattage: 1200,
    ),
    Appliance.builtIn(
      name: 'Steam Iron',
      category: ApplianceCategory.cleaning,
      wattage: 1500,
    ),
    Appliance.builtIn(
      name: 'Laundry Spinner / Dryer (Manual)',
      category: ApplianceCategory.cleaning,
      wattage: 200,
    ),

    // Entertainment & Electronics
    Appliance.builtIn(
      name: 'LED TV (32")',
      category: ApplianceCategory.entertainment,
      wattage: 50,
    ),
    Appliance.builtIn(
      name: 'LED TV (55")',
      category: ApplianceCategory.entertainment,
      wattage: 100,
    ),
    Appliance.builtIn(
      name: 'LED TV (65")',
      category: ApplianceCategory.entertainment,
      wattage: 130,
    ),
    Appliance.builtIn(
      name: 'Desktop Computer',
      category: ApplianceCategory.electronics,
      wattage: 300,
    ),
    Appliance.builtIn(
      name: 'Laptop',
      category: ApplianceCategory.electronics,
      wattage: 65,
    ),
    Appliance.builtIn(
      name: 'WiFi Router',
      category: ApplianceCategory.electronics,
      wattage: 15,
    ),
    Appliance.builtIn(
      name: 'Sound System',
      category: ApplianceCategory.entertainment,
      wattage: 200,
    ),
    Appliance.builtIn(
      name: 'Karaoke Player',
      category: ApplianceCategory.entertainment,
      wattage: 20,
    ),
    Appliance.builtIn(
      name: 'Game Console (PS/Xbox)',
      category: ApplianceCategory.entertainment,
      wattage: 200,
    ),
    Appliance.builtIn(
      name: 'Projector',
      category: ApplianceCategory.electronics,
      wattage: 300,
    ),
    Appliance.builtIn(
      name: 'Tablet / iPad',
      category: ApplianceCategory.electronics,
      wattage: 15,
    ),
    Appliance.builtIn(
      name: 'Smart Speaker (e.g., Alexa/Google Home)',
      category: ApplianceCategory.electronics,
      wattage: 10,
    ),

    // Cleaning
    Appliance.builtIn(
      name: 'Vacuum Cleaner',
      category: ApplianceCategory.cleaning,
      wattage: 1200,
    ),
    Appliance.builtIn(
      name: 'Electric Mop',
      category: ApplianceCategory.cleaning,
      wattage: 400,
    ),
    Appliance.builtIn(
      name: 'Dish Washer',
      category: ApplianceCategory.cleaning,
      wattage: 1500,
    ),
    Appliance.builtIn(
      name: 'Steam Cleaner',
      category: ApplianceCategory.cleaning,
      wattage: 1200,
    ),
    Appliance.builtIn(
      name: 'Robotic Vacuum Cleaner',
      category: ApplianceCategory.cleaning,
      wattage: 30,
    ),

    // Personal Care
    Appliance.builtIn(
      name: 'Hair Dryer',
      category: ApplianceCategory.personalCare,
      wattage: 1600,
    ),
    Appliance.builtIn(
      name: 'Hair Straightener',
      category: ApplianceCategory.personalCare,
      wattage: 200,
    ),
    Appliance.builtIn(
      name: 'Water Heater (Electric Shower)',
      category: ApplianceCategory.personalCare,
      wattage: 3500,
    ),
    Appliance.builtIn(
      name: 'Electric Shaver',
      category: ApplianceCategory.personalCare,
      wattage: 15,
    ),
    Appliance.builtIn(
      name: 'Facial Steamer',
      category: ApplianceCategory.personalCare,
      wattage: 200,
    ),
    Appliance.builtIn(
      name: 'Massage Chair / Massager',
      category: ApplianceCategory.personalCare,
      wattage: 150,
    ),
    Appliance.builtIn(
      name: 'Electric Toothbrush',
      category: ApplianceCategory.personalCare,
      wattage: 3,
    ),
    Appliance.builtIn(
      name: 'Hair Clipper / Trimmer',
      category: ApplianceCategory.personalCare,
      wattage: 10,
    ),

    // Lighting & Power
    Appliance.builtIn(
      name: 'LED Bulb',
      category: ApplianceCategory.lighting,
      wattage: 10,
    ),
    Appliance.builtIn(
      name: 'Fluorescent Lamp',
      category: ApplianceCategory.lighting,
      wattage: 30,
    ),
    Appliance.builtIn(
      name: 'Emergency Light',
      category: ApplianceCategory.lighting,
      wattage: 8,
    ),
    Appliance.builtIn(
      name: 'Outdoor Lamp',
      category: ApplianceCategory.lighting,
      wattage: 25,
    ),
    Appliance.builtIn(
      name: 'Solar Light',
      category: ApplianceCategory.lighting,
      wattage: 10,
    ),
    Appliance.builtIn(
      name: 'Flashlight (Rechargeable)',
      category: ApplianceCategory.lighting,
      wattage: 5,
    ),
    Appliance.builtIn(
      name: 'Ring Light',
      category: ApplianceCategory.lighting,
      wattage: 20,
    ),
    Appliance.builtIn(
      name: 'Extension Cord with Switch',
      category: ApplianceCategory.lighting,
      wattage: 15,
    ),

    // School / Small Business
    Appliance.builtIn(
      name: 'Photocopier / Printer',
      category: ApplianceCategory.business,
      wattage: 1000,
    ),
    Appliance.builtIn(
      name: 'Cash Register / POS System',
      category: ApplianceCategory.business,
      wattage: 150,
    ),
    Appliance.builtIn(
      name: 'CCTV Camera',
      category: ApplianceCategory.business,
      wattage: 15,
    ),
    Appliance.builtIn(
      name: 'Refrigerator (Display Type)',
      category: ApplianceCategory.business,
      wattage: 250,
    ),
    Appliance.builtIn(
      name: 'Water Pump',
      category: ApplianceCategory.business,
      wattage: 750,
    ),
    Appliance.builtIn(
      name: 'Neon Sign / LED Board',
      category: ApplianceCategory.business,
      wattage: 100,
    ),
    Appliance.builtIn(
      name: 'Coffee Vending Machine',
      category: ApplianceCategory.business,
      wattage: 1200,
    ),
    Appliance.builtIn(
      name: 'Air Curtain',
      category: ApplianceCategory.business,
      wattage: 300,
    ),
    Appliance.builtIn(
      name: 'Barcode Scanner',
      category: ApplianceCategory.business,
      wattage: 5,
    ),
    Appliance.builtIn(
      name: 'Laminating Machine',
      category: ApplianceCategory.business,
      wattage: 500,
    ),
    Appliance.builtIn(
      name: 'Cash Drawer',
      category: ApplianceCategory.business,
      wattage: 5,
    ),
    Appliance.builtIn(
      name: 'Refrigerator (for Ice Cream or Drinks)',
      category: ApplianceCategory.business,
      wattage: 400,
    ),

    // Boarding House / Dorm
    Appliance.builtIn(
      name: 'Mini Refrigerator',
      category: ApplianceCategory.dorm,
      wattage: 80,
    ),
    Appliance.builtIn(
      name: 'Electric Fan',
      category: ApplianceCategory.dorm,
      wattage: 60,
    ),
    Appliance.builtIn(
      name: 'Laptop / Phone Charger',
      category: ApplianceCategory.dorm,
      wattage: 15,
    ),
    Appliance.builtIn(
      name: 'Rice Cooker (Small)',
      category: ApplianceCategory.dorm,
      wattage: 400,
    ),
    Appliance.builtIn(
      name: 'Electric Kettle',
      category: ApplianceCategory.dorm,
      wattage: 1200,
    ),
    Appliance.builtIn(
      name: 'Electric Iron',
      category: ApplianceCategory.dorm,
      wattage: 1000,
    ),
    Appliance.builtIn(
      name: 'Power Bank',
      category: ApplianceCategory.dorm,
      wattage: 5,
    ),
    Appliance.builtIn(
      name: 'Portable Speaker',
      category: ApplianceCategory.dorm,
      wattage: 15,
    ),
    Appliance.builtIn(
      name: 'Mini Electric Stove',
      category: ApplianceCategory.dorm,
      wattage: 1000,
    ),
    Appliance.builtIn(
      name: 'LED Desk Lamp',
      category: ApplianceCategory.dorm,
      wattage: 10,
    ),
  ];

  static List<Appliance> byCategory(ApplianceCategory category) {
    return all.where((appliance) => appliance.category == category).toList();
  }

  static Appliance? findById(String id) {
    return all.where((appliance) => appliance.id == id).firstOrNull;
  }

  static Appliance? findByName(String name) {
    return all.where((appliance) =>
        appliance.name.toLowerCase() == name.toLowerCase()).firstOrNull;
  }

  static List<String> get categoryNames {
    return ApplianceCategory.values
        .map((category) => category.displayName)
        .toList();
  }

  static Map<ApplianceCategory, List<Appliance>> groupedByCategory() {
    final Map<ApplianceCategory, List<Appliance>> grouped = {};

    for (final category in ApplianceCategory.values) {
      grouped[category] = byCategory(category);
    }

    return grouped;
  }
}
