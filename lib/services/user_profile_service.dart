import '../models/user_profile.dart';
import 'base_firebase_service.dart';

class UserProfileService extends BaseFirebaseService {
  static const String collectionName = 'profile';

  /// Create or update user profile
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      ensureAuthenticated();
      final docRef = userDoc(collectionName, 'main');
      await docRef.set(profile.toJson());
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Get user profile
  Future<UserProfile?> getUserProfile() async {
    try {
      ensureAuthenticated();
      final docRef = userDoc(collectionName, 'main');
      final doc = await docRef.get();

      if (doc.exists && doc.data() != null) {
        return UserProfile.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Create default profile for new user
  Future<UserProfile> createDefaultProfile({
    required String userId,
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    final profile = UserProfile.create(
      userId: userId,
      name: name ?? 'User',
      email: email ?? '',
      photoUrl: photoUrl,
    );

    await saveUserProfile(profile);
    return profile;
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? photoUrl,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      ensureAuthenticated();
      final existingProfile = await getUserProfile();

      if (existingProfile == null) {
        throw Exception('User profile not found');
      }

      final updatedProfile = existingProfile.copyWith(
        name: name,
        email: email,
        photoUrl: photoUrl,
        preferences: preferences,
      );

      await saveUserProfile(updatedProfile);
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Delete user profile
  Future<void> deleteUserProfile() async {
    try {
      ensureAuthenticated();
      final docRef = userDoc(collectionName, 'main');
      await docRef.delete();
    } catch (e) {
      throw handleFirebaseError(e);
    }
  }

  /// Stream user profile changes
  Stream<UserProfile?> streamUserProfile() {
    if (!isAuthenticated) {
      return Stream.value(null);
    }

    final docRef = userDoc(collectionName, 'main');
    return docRef.snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromJson(doc.data()!);
      }
      return null;
    });
  }

  /// Check if user profile exists
  Future<bool> userProfileExists() async {
    try {
      ensureAuthenticated();
      final docRef = userDoc(collectionName, 'main');
      final doc = await docRef.get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}
