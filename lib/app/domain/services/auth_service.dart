import 'package:firebase_auth/firebase_auth.dart';

/// Authentication Service Interface
/// SOLID: Interface Segregation - Sadece auth operasyonları
/// SOLID: Dependency Inversion - High-level modules buna bağımlı olacak
abstract class AuthService {
  // Current user operations
  User? get currentUser;
  String? get currentUserId;
  Stream<User?> get authStateChanges;
  Stream<User?> get userChanges;

  // Authentication operations
  Future<User?> signInWithEmailAndPassword(String email, String password);
  Future<User?> createUserWithEmailAndPassword(String email, String password);
  Future<User?> signInWithGoogle();
  Future<void> signOut();

  // Email verification
  Future<void> sendEmailVerification();
  Future<void> reloadUser();
  bool get isEmailVerified;

  // Password operations
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updatePassword(String newPassword);

  // User profile operations
  Future<void> updateDisplayName(String displayName);
  Future<void> updatePhotoURL(String photoURL);
  Future<void> updateProfile({String? displayName, String? photoURL});

  // Account management
  Future<void> deleteAccount();
  Future<void> reauthenticateWithCredential(AuthCredential credential);

  // Token operations
  Future<String?> getIdToken({bool forceRefresh = false});
  Future<IdTokenResult> getIdTokenResult({bool forceRefresh = false});

  // User validation
  Future<bool> validateCurrentUser();
  Future<void> clearInvalidUser();

  /// Kullanıcı hem giriş yapmış hem de email doğrulanmış mı?
  Future<bool> isUserAuthenticatedAndVerified();
}
