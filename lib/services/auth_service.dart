import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String adminEmail = 'sriramreddydwarampudi@gmail.com';

  Stream<User?> get user => _auth.authStateChanges();

  bool get isAdmin => _auth.currentUser?.email == adminEmail;

  Future<User?> signInWithGoogle() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      
      if (kIsWeb) {
        // Use signInWithPopup for Web
        final UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
        return userCredential.user;
      } else {
        // Use signInWithProvider for Mobile
        final UserCredential userCredential = await _auth.signInWithProvider(googleProvider);
        return userCredential.user;
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      if (e is FirebaseAuthException) {
        debugPrint('Firebase Auth Error Code: ${e.code}');
        debugPrint('Firebase Auth Error Message: ${e.message}');
      }
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Sign-Out Error: $e');
    }
  }
}
