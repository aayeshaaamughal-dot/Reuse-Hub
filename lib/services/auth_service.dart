import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with Email and Password
  Future<UserModel?> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String city,
    required String role,
  }) async {
    try {
      final String effectiveRole = role.isNotEmpty ? role : AppConstants.roleMaker;

      UserCredential credential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw 'Registration connection timed out. Please check your internet.',
          );

      if (credential.user != null) {
        UserModel userModel = UserModel(
          uid: credential.user!.uid,
          name: name.trim(),
          email: email.trim(),
          phone: phone.trim(),
          role: effectiveRole,
          city: city.trim(),
          createdAt: DateTime.now(),
        );

        // Save user data asynchronously with a fast timeout
        try {
          await _firestoreService
              .saveUserData(userModel)
              .timeout(const Duration(seconds: 5));
        } catch (_) {
          // If Firestore write is slow, user account is created in Auth anyway
        }

        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw e.toString();
    }
  }

  // Sign in with Email and Password
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw 'Sign in connection timed out. Please check your internet.',
          );

      if (credential.user != null) {
        try {
          final userData = await _firestoreService
              .getUserData(credential.user!.uid)
              .timeout(const Duration(seconds: 4));
          if (userData != null) return userData;
        } catch (_) {}

        // Fallback user model if Firestore fetch is delayed
        return UserModel(
          uid: credential.user!.uid,
          name: email.split('@').first,
          email: email,
          phone: '',
          role: AppConstants.roleMaker,
          city: AppConstants.defaultCity,
          createdAt: DateTime.now(),
        );
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw e.toString();
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Error signing out. Please try again.';
    }
  }

  // Helper to map FirebaseAuth exceptions to friendly user messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is formatted incorrectly.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is not enabled.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet connection.';
      default:
        return e.message ?? 'An unexpected authentication error occurred.';
    }
  }
}
