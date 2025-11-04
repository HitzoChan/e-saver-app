import '../models/usage_record.dart';
import 'base_firebase_service.dart';

class UsageRecordService extends BaseFirebaseService {
  static const String collectionName = 'usage_records';

  /// Add new usage record
  Future<void> addUsageRecord(UsageRecord record) async {
    try {
      ensureAuthenticated();
      final docRef = userCollection(collectionName).doc(record.id);
      await docRef.set(record.toJson());
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Update existing usage record
  Future<void> updateUsageRecord(UsageRecord record) async {
    try {
      ensureAuthenticated();
      final docRef = userCollection(collectionName).doc(record.id);
      await docRef.update(record.toJson());
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Get usage record by ID
  Future<UsageRecord?> getUsageRecord(String recordId) async {
    try {
      ensureAuthenticated();
      final docRef = userCollection(collectionName).doc(recordId);
      final doc = await docRef.get();

      if (doc.exists && doc.data() != null) {
        return UsageRecord.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Get all usage records for current user
  Future<List<UsageRecord>> getAllUsageRecords() async {
    try {
      ensureAuthenticated();
      final querySnapshot = await userCollection(collectionName)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UsageRecord.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Get usage records for a specific date range
  Future<List<UsageRecord>> getUsageRecordsInRange(DateTime start, DateTime end) async {
    try {
      ensureAuthenticated();
      final querySnapshot = await userCollection(collectionName)
          .where('date', isGreaterThanOrEqualTo: start)
          .where('date', isLessThanOrEqualTo: end)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UsageRecord.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Get usage records for the past week
  Future<List<UsageRecord>> getWeeklyUsageRecords() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return getUsageRecordsInRange(weekAgo, now);
  }

  /// Get daily usage summary for the past week
  Future<Map<DateTime, double>> getWeeklyDailyUsage() async {
    final records = await getWeeklyUsageRecords();
    final dailyUsage = <DateTime, double>{};

    for (final record in records) {
      final dayKey = DateTime(record.date.year, record.date.month, record.date.day);
      dailyUsage[dayKey] = (dailyUsage[dayKey] ?? 0) + record.hoursUsed;
    }

    return dailyUsage;
  }

  /// Delete usage record
  Future<void> deleteUsageRecord(String recordId) async {
    try {
      ensureAuthenticated();
      final docRef = userCollection(collectionName).doc(recordId);
      await docRef.delete();
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Create usage record from appliance usage
  Future<UsageRecord> createUsageRecord({
    required String applianceId,
    required DateTime date,
    required double hoursUsed,
    required int wattage,
    required double ratePerKwh,
    String? notes,
  }) async {
    final record = UsageRecord.calculate(
      id: '${currentUserId}_${applianceId}_${date.millisecondsSinceEpoch}',
      applianceId: applianceId,
      date: date,
      hoursUsed: hoursUsed,
      wattage: wattage,
      ratePerKwh: ratePerKwh,
      userId: currentUserId!,
      notes: notes,
    );

    await addUsageRecord(record);
    return record;
  }

  /// Get usage records by appliance
  Future<List<UsageRecord>> getUsageRecordsByAppliance(String applianceId) async {
    try {
      ensureAuthenticated();
      final querySnapshot = await userCollection(collectionName)
          .where('applianceId', isEqualTo: applianceId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UsageRecord.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Calculate total cost for date range
  Future<double> getTotalCostInRange(DateTime start, DateTime end) async {
    final records = await getUsageRecordsInRange(start, end);
    return records.fold<double>(0.0, (sum, record) => sum + record.cost);
  }

  /// Calculate total hours used in date range
  Future<double> getTotalHoursInRange(DateTime start, DateTime end) async {
    final records = await getUsageRecordsInRange(start, end);
    return records.fold<double>(0.0, (sum, record) => sum + record.hoursUsed);
  }

  /// Stream usage records for real-time updates
  Stream<List<UsageRecord>> streamUsageRecords() {
    if (!isAuthenticated) {
      return Stream.value([]);
    }

    return userCollection(collectionName)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UsageRecord.fromJson(doc.data()))
          .toList();
    });
  }

  /// Check if usage record exists
  Future<bool> usageRecordExists(String recordId) async {
    try {
      ensureAuthenticated();
      final docRef = userCollection(collectionName).doc(recordId);
      final doc = await docRef.get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}
