import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/electricity_rate.dart';
import '../models/rate_source.dart';
import 'base_firebase_service.dart';

class ElectricityRateService extends BaseFirebaseService {
  static const String collectionName = 'electricity_rates';

  /// Save electricity rate
  Future<void> saveElectricityRate(ElectricityRate rate) async {
    try {
      ensureAuthenticated();
      final docRef = userCollection(collectionName).doc(rate.id);
      await docRef.set(rate.toJson());
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Get current electricity rate
  Future<ElectricityRate?> getCurrentElectricityRate() async {
    try {
      ensureAuthenticated();
      final querySnapshot = await userCollection(collectionName)
          .orderBy('effectiveDate', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ElectricityRate.fromJson(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Get electricity rate by ID
  Future<ElectricityRate?> getElectricityRate(String rateId) async {
    try {
      ensureAuthenticated();
      final docRef = userCollection(collectionName).doc(rateId);
      final doc = await docRef.get();

      if (doc.exists && doc.data() != null) {
        return ElectricityRate.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Get all electricity rates
  Future<List<ElectricityRate>> getAllElectricityRates() async {
    try {
      ensureAuthenticated();
      final querySnapshot = await userCollection(collectionName)
          .orderBy('effectiveDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ElectricityRate.fromJson(Map<String, dynamic>.from(doc.data())))
          .toList();
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Stream current electricity rate
  Stream<ElectricityRate?> streamCurrentElectricityRate() {
    if (!isAuthenticated) {
      return Stream.value(null);
    }

    return userCollection(collectionName)
        .orderBy('effectiveDate', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return ElectricityRate.fromJson(snapshot.docs.first.data());
          }
          return null;
        });
  }

  /// Create new electricity rate
  Future<ElectricityRate> createElectricityRate({
    required double ratePerKwh,
    required String provider,
    required RateSource source,
    String? notes,
    DateTime? effectiveDate,
  }) async {
    final rate = ElectricityRate.manual(
      id: '${currentUserId}_${DateTime.now().millisecondsSinceEpoch}',
      provider: provider,
      ratePerKwh: ratePerKwh,
      userId: currentUserId!,
    );

    await saveElectricityRate(rate);
    return rate;
  }

  /// Update electricity rate
  Future<void> updateElectricityRate(ElectricityRate rate) async {
    try {
      ensureAuthenticated();
      final docRef = userCollection(collectionName).doc(rate.id);
      await docRef.update(rate.toJson());
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Delete electricity rate
  Future<void> deleteElectricityRate(String rateId) async {
    try {
      ensureAuthenticated();
      final docRef = userCollection(collectionName).doc(rateId);
      await docRef.delete();
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Get rates by provider
  Future<List<ElectricityRate>> getRatesByProvider(String provider) async {
    try {
      ensureAuthenticated();
      final querySnapshot = await userCollection(collectionName)
          .where('provider', isEqualTo: provider)
          .orderBy('effectiveDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ElectricityRate.fromJson(Map<String, dynamic>.from(doc.data())))
          .toList();
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Get rates by source
  Future<List<ElectricityRate>> getRatesBySource(RateSource source) async {
    try {
      ensureAuthenticated();
      final querySnapshot = await userCollection(collectionName)
          .where('source', isEqualTo: source.name)
          .orderBy('effectiveDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ElectricityRate.fromJson(Map<String, dynamic>.from(doc.data())))
          .toList();
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Get rate history for date range
  Future<List<ElectricityRate>> getRateHistory({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      ensureAuthenticated();
      Query query = userCollection(collectionName)
          .orderBy('effectiveDate', descending: true);

      if (startDate != null) {
        query = query.where('effectiveDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('effectiveDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => ElectricityRate.fromJson(doc.data()! as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Check if rate is current (most recent)
  Future<bool> isCurrentRate(String rateId) async {
    try {
      final currentRate = await getCurrentElectricityRate();
      return currentRate?.id == rateId;
    } catch (e) {
      return false;
    }
  }

  /// Get rate statistics
  Future<Map<String, dynamic>> getRateStatistics() async {
    try {
      final rates = await getAllElectricityRates();

      if (rates.isEmpty) {
        return {
          'totalRates': 0,
          'averageRate': 0.0,
          'highestRate': 0.0,
          'lowestRate': 0.0,
          'currentRate': null,
          'rateChange': 0.0,
        };
      }

      final currentRate = rates.first;
      final previousRate = rates.length > 1 ? rates[1] : null;

      final ratesList = rates.map((r) => r.ratePerKwh).toList();
      final averageRate = ratesList.reduce((a, b) => a + b) / ratesList.length;
      final highestRate = ratesList.reduce((a, b) => a > b ? a : b);
      final lowestRate = ratesList.reduce((a, b) => a < b ? a : b);

      final rateChange = previousRate != null
          ? ((currentRate.ratePerKwh - previousRate.ratePerKwh) /
              previousRate.ratePerKwh) *
              100
          : 0.0;

      return {
        'totalRates': rates.length,
        'averageRate': averageRate,
        'highestRate': highestRate,
        'lowestRate': lowestRate,
        'currentRate': currentRate,
        'rateChange': rateChange,
      };
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Create default rate for new users
  Future<ElectricityRate> createDefaultRate() async {
    return await createElectricityRate(
      ratePerKwh: 12.0, // Default Philippine rate
      provider: 'Meralco',
      source: RateSource.manual,
      notes: 'Default rate - please update with your actual rate',
    );
  }
}
