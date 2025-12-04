import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/notification_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  User? _user;
  bool _isLoading = true;
  StreamSubscription<User?>? _authStateSubscription;
  bool _isDisposed = false;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _authStateSubscription = _auth.authStateChanges().listen((User? user) {
      if (_isDisposed) return;

      _user = user;
      _isLoading = false;
      notifyListeners();

      // Initialize notifications when user signs in
      if (user != null) {
        _initializeNotifications();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    try {
      await NotificationService().initialize();
      await NotificationService().setNotificationsEnabled(true);
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
    }
  }

  // ✅ FULLY FIXED GOOGLE SIGN-IN FLOW
  Future<bool> signInWithGoogle() async {
    try {
      // If already signed in Firebase → return success immediately
      if (_auth.currentUser != null) {
        debugPrint("User already signed in. Skipping Google UI.");
        _user = _auth.currentUser;
        notifyListeners();
        return true;
      }

      // Start Google login flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If user closes the Google window without selecting an account
      if (googleUser == null) {
        debugPrint("Google Sign-In cancelled by user.");
        return false;
      }

      // Auth details from Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Login to Firebase
      final UserCredential result =
          await _auth.signInWithCredential(credential);

      _user = result.user;
      notifyListeners();
      return true;

    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      _user = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }
}
