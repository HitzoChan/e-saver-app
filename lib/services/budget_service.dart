import '../models/budget.dart';
import 'base_firebase_service.dart';

class BudgetService extends BaseFirebaseService {
  static const String collectionName = 'budgets';

  /// Create new budget
  Future<Budget> createBudget({
    required double monthlyGoal,
    double alertThreshold = 0.8,
    bool alertsEnabled = true,
  }) async {
    try {
      ensureAuthenticated();
      final budget = Budget.create(
        id: '${currentUserId}_${DateTime.now().millisecondsSinceEpoch}',
        monthlyGoal: monthlyGoal,
        userId: currentUserId!,
        alertThreshold: alertThreshold,
        alertsEnabled: alertsEnabled,
      );

      final docRef = userCollection(collectionName).doc(budget.id);
      await docRef.set(budget.toJson());
      return budget;
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Update existing budget
  Future<void> updateBudget(Budget budget) async {
    try {
      ensureAuthenticated();
      final docRef = userCollection(collectionName).doc(budget.id);
      await docRef.update(budget.toJson());
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Get current budget (most recent active budget)
  Future<Budget?> getCurrentBudget() async {
    try {
      ensureAuthenticated();
      final querySnapshot = await userCollection(collectionName)
          .orderBy('periodEnd', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final budget = Budget.fromJson(querySnapshot.docs.first.data());
        // Check if budget is still current
        if (budget.isCurrentPeriod) {
          return budget;
        }
      }
      return null;
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Get budget by ID
  Future<Budget?> getBudget(String budgetId) async {
    try {
      ensureAuthenticated();
      final docRef = userCollection(collectionName).doc(budgetId);
      final doc = await docRef.get();

      if (doc.exists && doc.data() != null) {
        return Budget.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Get all budgets
  Future<List<Budget>> getAllBudgets() async {
    try {
      ensureAuthenticated();
      final querySnapshot = await userCollection(collectionName)
          .orderBy('periodEnd', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Budget.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Stream current budget
  Stream<Budget?> streamCurrentBudget() {
    if (!isAuthenticated) {
      return Stream.value(null);
    }

    return userCollection(collectionName)
        .orderBy('periodEnd', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final budget = Budget.fromJson(snapshot.docs.first.data());
            return budget.isCurrentPeriod ? budget : null;
          }
          return null;
        });
  }

  /// Update budget usage
  Future<void> updateBudgetUsage(String budgetId, double newUsage) async {
    try {
      ensureAuthenticated();
      final budget = await getBudget(budgetId);
      if (budget != null) {
        final updatedBudget = budget.updateUsage(newUsage);
        await updateBudget(updatedBudget);
      }
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Add to budget usage
  Future<void> addToBudgetUsage(String budgetId, double amount) async {
    try {
      ensureAuthenticated();
      final budget = await getBudget(budgetId);
      if (budget != null) {
        final updatedBudget = budget.addToUsage(amount);
        await updateBudget(updatedBudget);
      }
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Delete budget
  Future<void> deleteBudget(String budgetId) async {
    try {
      ensureAuthenticated();
      final docRef = userCollection(collectionName).doc(budgetId);
      await docRef.delete();
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Calculate current usage from appliances
  Future<double> calculateCurrentUsage() async {
    try {
      // This will be implemented when we integrate with appliance service
      // For now, return 0.0
      return 0.0;
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Check if user has active budget
  Future<bool> hasActiveBudget() async {
    try {
      final budget = await getCurrentBudget();
      return budget != null;
    } catch (e) {
      return false;
    }
  }

  /// Get budget statistics
  Future<Map<String, dynamic>> getBudgetStatistics() async {
    try {
      final budgets = await getAllBudgets();
      final currentBudget = await getCurrentBudget();

      if (budgets.isEmpty) {
        return {
          'totalBudgets': 0,
          'currentBudget': null,
          'averageGoal': 0.0,
          'totalSpent': 0.0,
          'budgetSuccessRate': 0.0,
        };
      }

      final totalSpent = budgets.fold<double>(0.0, (total, budget) => total + budget.currentUsage);
      final averageGoal = budgets.fold<double>(0.0, (total, budget) => total + budget.monthlyGoal) / budgets.length;
      final successfulBudgets = budgets.where((budget) => !budget.isOverBudget).length;
      final budgetSuccessRate = successfulBudgets / budgets.length;

      return {
        'totalBudgets': budgets.length,
        'currentBudget': currentBudget,
        'averageGoal': averageGoal,
        'totalSpent': totalSpent,
        'budgetSuccessRate': budgetSuccessRate,
      };
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Create default budget for new users
  Future<Budget> createDefaultBudget() async {
    return await createBudget(
      monthlyGoal: 2000.0, // Default budget
      alertThreshold: 0.8,
      alertsEnabled: true,
    );
  }
}
