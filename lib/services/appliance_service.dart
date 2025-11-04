import '../models/appliance.dart';
import '../models/built_in_appliances.dart';
import 'base_firebase_service.dart';

class ApplianceService extends BaseFirebaseService {
  static const String collectionName = 'appliances';

  /// Add new appliance
  Future<void> addAppliance(Appliance appliance) async {
    try {
      ensureAuthenticated();
      final docRef = userCollection(collectionName).doc(appliance.id);
      await docRef.set(appliance.toJson());
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Update existing appliance
  Future<void> updateAppliance(Appliance appliance) async {
    try {
      ensureAuthenticated();
      final docRef = userCollection(collectionName).doc(appliance.id);
      await docRef.update(appliance.toJson());
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Get appliance by ID
  Future<Appliance?> getAppliance(String applianceId) async {
    try {
      ensureAuthenticated();
      final docRef = userCollection(collectionName).doc(applianceId);
      final doc = await docRef.get();

      if (doc.exists && doc.data() != null) {
        return Appliance.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Get all appliances
  Future<List<Appliance>> getAllAppliances() async {
    try {
      ensureAuthenticated();
      final querySnapshot = await userCollection(collectionName)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Appliance.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Stream all user appliances
  Stream<List<Appliance>> streamAllAppliances() {
    if (!isAuthenticated) {
      return Stream.value([]);
    }

    return userCollection(collectionName).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Appliance.fromJson(doc.data()))
          .toList();
    });
  }

  /// Delete appliance
  Future<void> deleteAppliance(String applianceId) async {
    try {
      ensureAuthenticated();
      final docRef = userCollection(collectionName).doc(applianceId);
      await docRef.delete();
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Add built-in appliance to user collection
  Future<void> addBuiltInAppliance(String applianceId) async {
    try {
      final builtInAppliance = BuiltInAppliances.findById(applianceId);
      if (builtInAppliance == null) {
        throw Exception('Built-in appliance not found');
      }

      // Convert built-in to user appliance
      final userAppliance = Appliance.create(
        id: '${currentUserId}_${builtInAppliance.id}',
        name: builtInAppliance.name,
        wattage: builtInAppliance.wattage,
        category: builtInAppliance.category,
        icon: builtInAppliance.icon,
        userId: currentUserId!,
      );

      await addAppliance(userAppliance);
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Get appliances by category
  Future<List<Appliance>> getAppliancesByCategory(String category) async {
    try {
      ensureAuthenticated();
      final querySnapshot = await userCollection(collectionName)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Appliance.fromJson(Map<String, dynamic>.from(doc.data())))
          .toList();
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Get appliances by power range
  Future<List<Appliance>> getAppliancesByPowerRange({
    double? minWatts,
    double? maxWatts,
  }) async {
    try {
      ensureAuthenticated();
      var query = userCollection(collectionName).orderBy('powerWatts');

      if (minWatts != null) {
        query = query.where('powerWatts', isGreaterThanOrEqualTo: minWatts);
      }
      if (maxWatts != null) {
        query = query.where('powerWatts', isLessThanOrEqualTo: maxWatts);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => Appliance.fromJson(Map<String, dynamic>.from(doc.data())))
          .toList();
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Calculate total daily cost for all appliances
  Future<double> calculateTotalDailyCost(double ratePerKwh, double hoursPerDay) async {
    try {
      final appliances = await getAllAppliances();
      double totalCost = 0.0;

      for (final appliance in appliances) {
        totalCost += appliance.calculateDailyCost(ratePerKwh, hoursPerDay);
      }

      return totalCost;
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Calculate total monthly cost for all appliances
  Future<double> calculateTotalMonthlyCost(double ratePerKwh, double hoursPerDay) async {
    try {
      final appliances = await getAllAppliances();
      double totalCost = 0.0;

      for (final appliance in appliances) {
        totalCost += appliance.calculateMonthlyCost(ratePerKwh, hoursPerDay);
      }

      return totalCost;
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Get appliance count by category
  Future<Map<String, int>> getApplianceCountByCategory() async {
    try {
      final appliances = await getAllAppliances();
      final countMap = <String, int>{};

      for (final appliance in appliances) {
        final category = appliance.category.displayName;
        countMap[category] = (countMap[category] ?? 0) + 1;
      }

      return countMap;
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Search appliances by name
  Future<List<Appliance>> searchAppliances(String query) async {
    try {
      ensureAuthenticated();
      final querySnapshot = await userCollection(collectionName)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return querySnapshot.docs
          .map((doc) => Appliance.fromJson(Map<String, dynamic>.from(doc.data())))
          .toList();
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Bulk add appliances
  Future<void> addMultipleAppliances(List<Appliance> appliances) async {
    try {
      ensureAuthenticated();
      final batch = firestore.batch();

      for (final appliance in appliances) {
        final docRef = userCollection(collectionName).doc(appliance.id);
        batch.set(docRef, appliance.toJson());
      }

      await batch.commit();
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Check if appliance exists
  Future<bool> applianceExists(String applianceId) async {
    try {
      ensureAuthenticated();
      final docRef = userCollection(collectionName).doc(applianceId);
      final doc = await docRef.get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}
