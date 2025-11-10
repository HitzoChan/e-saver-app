import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/notification_service.dart';
import '../services/onesignal_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  User? _user;
  bool _isLoading = true;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _isLoading = false;
      notifyListeners();

      // Initialize notifications when user signs in
      if (user != null) {
        _initializeNotifications();
      }
    });
  }

  Future<void> _initializeNotifications() async {
    try {
      // Initialize OneSignal with handlers
      await OneSignalService.initializeService();

      // Set user ID for OneSignal (using Firebase UID)
      if (_user?.uid != null) {
        await OneSignalService().setUserId(_user!.uid);
        // Also set current user ID for notification storage
        OneSignalService().setCurrentUserId(_user!.uid);
      }

      // Initialize local notifications
      await NotificationService().initialize();

      // Check if we already have permission before enabling
      final hasPermission = await OneSignalService().hasPermission();
      if (hasPermission) {
        // Enable notifications and subscribe to topics only if permission granted
        await NotificationService().setNotificationsEnabled(true);
      } else {
        // If no permission, request it
        final granted = await OneSignalService().requestPermission();
        if (granted) {
          await NotificationService().setNotificationsEnabled(true);
        }
      }
      // If no permission, we'll handle this in the UI later
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      _user = result.user;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Sign in error: $e');
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      _user = result.user;
      notifyListeners();
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
