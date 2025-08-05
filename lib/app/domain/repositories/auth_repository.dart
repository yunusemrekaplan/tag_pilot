import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';

/// Authentication Repository Interface
/// Data layer'dan presentation layer'ı ayırır
abstract class AuthRepository {
  // Auth State
  Stream<User?> get authStateChanges;
  User? get currentUser;
  bool get isLoggedIn;
  bool get isEmailVerified;

  // Authentication Methods
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<UserCredential> registerWithEmailPassword({
    required String email,
    required String password,
    required String name,
  });

  Future<UserCredential> signInWithGoogle();

  Future<void> signOut();

  // Email Verification
  Future<void> sendEmailVerification();
  Future<bool> checkEmailVerification();

  // Password Reset
  Future<void> sendPasswordResetEmail(String email);

  // Account Management
  Future<void> updateDisplayName(String name);
  Future<void> deleteAccount();

  // User Data Management
  Future<UserModel?> getCurrentUserData();
  Future<void> createUserProfile(UserModel user);
  Future<void> updateUserProfile(UserModel user);
  Future<void> deleteUserProfile(String uid);
}
