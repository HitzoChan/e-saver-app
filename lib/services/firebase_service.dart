import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

class FirebaseService {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await _seedInitialDataIfNeeded();
  }

  static Future<void> _seedInitialDataIfNeeded() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Check one collection (change 'appliances' to the collection you expect)
      final colRef = firestore.collection('appliances');
      final snapshot = await colRef.limit(1).get();

      if (snapshot.docs.isEmpty) {
        // Prepare seed documents
        final batch = firestore.batch();

        final seedAppliances = <Map<String, dynamic>>[
          {
            'name': 'LED Bulb',
            'power_watts': 9,
            'daily_hours': 3,
            'category': 'Lighting',
            'created_at': FieldValue.serverTimestamp(),
          },
          {
            'name': 'Refrigerator',
            'power_watts': 150,
            'daily_hours': 24,
            'category': 'Kitchen',
            'created_at': FieldValue.serverTimestamp(),
          },
          {
            'name': 'Washing Machine',
            'power_watts': 500,
            'daily_hours': 1,
            'category': 'Laundry',
            'created_at': FieldValue.serverTimestamp(),
          },
        ];

        for (var doc in seedAppliances) {
          final docRef = colRef.doc(); // auto id
          batch.set(docRef, doc);
        }

        await batch.commit();
        // Debug print only — remove or change to logging as needed.
        // ignore: avoid_print
        print('Firestore seeding: appliances collection created with sample data.');
      } else {
        // ignore: avoid_print
        print('Firestore seeding: appliances collection already contains data — skipping seed.');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Firestore seeding failed: $e');
      // Do not rethrow — initialization should still continue.
    }
  }
}
