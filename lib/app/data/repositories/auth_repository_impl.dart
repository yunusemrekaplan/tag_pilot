import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../core/utils/app_constants.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/database_service.dart';
import '../../domain/services/error_handler_service.dart';
import '../models/user_model.dart';

/// Authentication Repository Implementation (Clean Architecture)
/// SOLID: Dependency Inversion - AuthRepository interface'ini implement eder
/// SOLID: Single Responsibility - Sadece auth operations
class AuthRepositoryImpl implements AuthRepository {
  late final AuthService _authService;
  late final DatabaseService _databaseService;
  late final ErrorHandlerService _errorHandler;

  AuthRepositoryImpl() {
    _authService = Get.find<AuthService>();
    _databaseService = Get.find<DatabaseService>();
    _errorHandler = Get.find<ErrorHandlerService>();
  }

  // ============================================================================
  // AUTH STATE PROPERTIES
  // ============================================================================

  @override
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  @override
  User? get currentUser => _authService.currentUser;

  @override
  bool get isLoggedIn => _authService.currentUser != null;

  @override
  bool get isEmailVerified => _authService.isEmailVerified;

  // ============================================================================
  // AUTHENTICATION METHODS
  // ============================================================================

  @override
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user =
          await _authService.signInWithEmailAndPassword(email, password);

      if (user == null) {
        throw FirebaseAuthException(
          code: 'sign_in_failed',
          message: 'Giriş başarısız.',
        );
      }

      // Create dummy UserCredential since AuthService returns User
      final userCredential = _createUserCredential(user);

      if (AppConstants.enableLogging) {
        print('✅ User signed in: ${user.uid}');
      }

      return userCredential;
    } catch (e) {
      _errorHandler.logError('Sign in with email/password', e);
      rethrow;
    }
  }

  @override
  Future<UserCredential> registerWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user =
          await _authService.createUserWithEmailAndPassword(email, password);

      if (user == null) {
        throw FirebaseAuthException(
          code: 'registration_failed',
          message: 'Kayıt başarısız.',
        );
      }

      // Update display name
      await _authService.updateDisplayName(name);

      // Create user profile in Firestore
      final userModel = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      await createUserProfile(userModel);

      // Create dummy UserCredential
      final userCredential = _createUserCredential(user);

      if (AppConstants.enableLogging) {
        print('✅ User registered: ${user.uid}');
      }

      return userCredential;
    } catch (e) {
      _errorHandler.logError('Register with email/password', e);
      rethrow;
    }
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    try {
      final user = await _authService.signInWithGoogle();

      if (user == null) {
        throw FirebaseAuthException(
          code: 'google_sign_in_cancelled',
          message: 'Google giriş iptal edildi.',
        );
      }

      // Check if user profile exists, if not create it
      final userExists = await doesUserProfileExist(user.uid);
      if (!userExists) {
        final userModel = UserModel(
          uid: user.uid,
          name: user.displayName ?? 'Google User',
          email: user.email ?? '',
          createdAt: DateTime.now(),
        );
        await createUserProfile(userModel);
      }

      // Create dummy UserCredential
      final userCredential = _createUserCredential(user);

      if (AppConstants.enableLogging) {
        print('✅ Google sign in successful: ${user.uid}');
      }

      return userCredential;
    } catch (e) {
      _errorHandler.logError('Google sign in', e);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authService.signOut();

      if (AppConstants.enableLogging) {
        print('✅ User signed out');
      }
    } catch (e) {
      _errorHandler.logError('Sign out', e);
      rethrow;
    }
  }

  // ============================================================================
  // EMAIL VERIFICATION
  // ============================================================================

  @override
  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();

      if (AppConstants.enableLogging) {
        print('✅ Email verification sent');
      }
    } catch (e) {
      _errorHandler.logError('Send email verification', e);
      rethrow;
    }
  }

  @override
  Future<void> reloadUser() async {
    try {
      await _authService.reloadUser();

      if (AppConstants.enableLogging) {
        print('✅ User reloaded');
      }
    } catch (e) {
      _errorHandler.logError('Reload user', e);
      rethrow;
    }
  }

  @override
  Future<bool> checkEmailVerification() async {
    try {
      await _authService.reloadUser();
      return _authService.isEmailVerified;
    } catch (e) {
      _errorHandler.logError('Check email verification', e);
      return false;
    }
  }

  // ============================================================================
  // PASSWORD OPERATIONS
  // ============================================================================

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);

      if (AppConstants.enableLogging) {
        print('✅ Password reset email sent to: $email');
      }
    } catch (e) {
      _errorHandler.logError('Send password reset email', e);
      rethrow;
    }
  }

  @override
  Future<void> updateDisplayName(String name) async {
    try {
      await _authService.updateDisplayName(name);

      if (AppConstants.enableLogging) {
        print('✅ Display name updated to: $name');
      }
    } catch (e) {
      _errorHandler.logError('Update display name', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await deleteUserAccount(); // Use our existing method
    } catch (e) {
      _errorHandler.logError('Delete account', e);
      rethrow;
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await _authService.updatePassword(newPassword);

      if (AppConstants.enableLogging) {
        print('✅ Password updated');
      }
    } catch (e) {
      _errorHandler.logError('Update password', e);
      rethrow;
    }
  }

  // ============================================================================
  // USER PROFILE OPERATIONS
  // ============================================================================

  @override
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _databaseService.setDocument(
        '${DatabaseConstants.usersCollection}/${user.uid}',
        user.toJson(),
      );

      if (AppConstants.enableLogging) {
        print('✅ User profile created: ${user.uid}');
      }
    } catch (e) {
      _errorHandler.logError('Create user profile', e);
      rethrow;
    }
  }

  @override
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _databaseService.getDocumentById(
        '${DatabaseConstants.usersCollection}/$userId',
      );

      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      _errorHandler.logError('Get user profile', e);
      return null;
    }
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _databaseService.updateDocument(
        '${DatabaseConstants.usersCollection}/${user.uid}',
        user.toJson(),
      );

      if (AppConstants.enableLogging) {
        print('✅ User profile updated: ${user.uid}');
      }
    } catch (e) {
      _errorHandler.logError('Update user profile', e);
      rethrow;
    }
  }

  @override
  Future<bool> doesUserProfileExist(String userId) async {
    try {
      final doc = await _databaseService.getDocumentById(
        '${DatabaseConstants.usersCollection}/$userId',
      );

      return doc.exists;
    } catch (e) {
      _errorHandler.logError('Check user profile existence', e);
      return false;
    }
  }

  @override
  Future<void> deleteUserAccount() async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'no_current_user',
          message: 'Silinecek kullanıcı bulunamadı.',
        );
      }

      // Delete user profile from Firestore
      await _databaseService.deleteDocument(
        '${DatabaseConstants.usersCollection}/${user.uid}',
      );

      // Delete Firebase Auth account
      await _authService.deleteAccount();

      if (AppConstants.enableLogging) {
        print('✅ User account deleted: ${user.uid}');
      }
    } catch (e) {
      _errorHandler.logError('Delete user account', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteUserProfile(String uid) async {
    try {
      await _databaseService.deleteDocument(
        '${DatabaseConstants.usersCollection}/$uid',
      );

      if (AppConstants.enableLogging) {
        print('✅ User profile deleted: $uid');
      }
    } catch (e) {
      _errorHandler.logError('Delete user profile', e);
      rethrow;
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return null;

      return await getUserProfile(user.uid);
    } catch (e) {
      _errorHandler.logError('Get current user data', e);
      return null;
    }
  }

  // ============================================================================
  // TOKEN OPERATIONS
  // ============================================================================

  @override
  Future<String?> getIdToken() async {
    try {
      return await _authService.getIdToken();
    } catch (e) {
      _errorHandler.logError('Get ID token', e);
      return null;
    }
  }

  @override
  Future<void> refreshToken() async {
    try {
      await _authService.getIdToken(forceRefresh: true);

      if (AppConstants.enableLogging) {
        print('✅ Token refreshed');
      }
    } catch (e) {
      _errorHandler.logError('Refresh token', e);
      rethrow;
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Creates a dummy UserCredential from User for compatibility
  UserCredential _createUserCredential(User user) {
    return _DummyUserCredential(user);
  }
}

/// Dummy UserCredential implementation for compatibility
/// Bu sadece mevcut kodla uyumluluk için gerekli
class _DummyUserCredential implements UserCredential {
  @override
  final User? user;

  @override
  final AdditionalUserInfo? additionalUserInfo;

  @override
  final AuthCredential? credential;

  _DummyUserCredential(this.user)
      : additionalUserInfo = null,
        credential = null;
}
