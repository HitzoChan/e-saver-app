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
      // Initialize local notifications
      await NotificationService().initialize();
      // Enable notifications
      await NotificationService().setNotificationsEnabled(true);
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      // Auth state will be updated automatically by authStateChanges listener
      return true;
    } catch (e) {
      debugPrint('Sign in error: $e');
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
      // Auth state will be updated automatically by authStateChanges listener
      return true;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('Google Sign In cancelled by user');
        return false;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google Auth credentials
      final UserCredential result = await _auth.signInWithCredential(credential);
      _user = result.user;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Google Sign In error: $e');
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
