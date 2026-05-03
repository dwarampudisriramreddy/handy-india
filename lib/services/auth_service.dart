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
      googleProvider.addScope('email');
      
      if (kIsWeb) {
        // Standard Web flow using Firebase standard Popup
        // This is the most reliable method for Flutter Web
        final UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
        return userCredential.user;
      } else {
        // Universal flow for mobile using Provider
        // This avoids the 'GoogleSignIn' constructor error entirely
        final UserCredential userCredential = await _auth.signInWithProvider(googleProvider);
        return userCredential.user;
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
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
