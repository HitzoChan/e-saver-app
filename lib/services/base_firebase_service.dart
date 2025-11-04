import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Get user-specific document reference
  DocumentReference<Map<String, dynamic>> userDoc(String collection, String docId) {
    if (currentUserId == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection(collection)
        .doc(docId);
  }

  /// Get user-specific collection reference
  CollectionReference<Map<String, dynamic>> userCollection(String collection) {
    if (currentUserId == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection(collection);
  }

  /// Get global collection reference (for shared data)
  CollectionReference<Map<String, dynamic>> globalCollection(String collection) {
    return _firestore.collection(collection);
  }

  /// Handle Firebase exceptions
  Exception handleFirebaseError(Object error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return Exception('Permission denied. Please check your authentication.');
        case 'not-found':
          return Exception('Document not found.');
        case 'already-exists':
          return Exception('Document already exists.');
        case 'unavailable':
          return Exception('Service temporarily unavailable. Please try again.');
        default:
          return Exception('Firebase error: ${error.message}');
      }
    }
    return Exception('Unknown error occurred: $error');
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Ensure user is authenticated
  void ensureAuthenticated() {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to perform this operation');
    }
  }
}
