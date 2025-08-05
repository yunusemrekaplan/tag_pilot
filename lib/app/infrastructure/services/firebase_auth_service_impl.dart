import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/utils/app_constants.dart';
import '../../domain/services/auth_service.dart';

/// Firebase Authentication Service Implementation
/// SOLID: Dependency Inversion - AuthService interface'ini implement eder
/// SOLID: Single Responsibility - Sadece authentication operations
class FirebaseAuthServiceImpl implements AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthServiceImpl()
      : _auth = FirebaseAuth.instance,
        _googleSignIn = GoogleSignIn.instance;

  // Constructor for testing
  FirebaseAuthServiceImpl.withInstance(this._auth, this._googleSignIn);

  // ============================================================================
  // CURRENT USER OPERATIONS
  // ============================================================================

  @override
  User? get currentUser => _auth.currentUser;

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Stream<User?> get userChanges => _auth.userChanges();

  // ============================================================================
  // AUTHENTICATION OPERATIONS
  // ============================================================================

  @override
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (AppConstants.enableLogging) {
        print('✅ Sign in with email successful: ${credential.user?.email}');
      }

      return credential.user;
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Sign in with email error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (AppConstants.enableLogging) {
        print('✅ Create user with email successful: ${credential.user?.email}');
      }

      return credential.user;
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Create user with email error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<User?> signInWithGoogle() async {
    try {
      // Initialize Google Sign-In if not already initialized
      await _initializeGoogleSignIn();

      // Check if platform supports authenticate method
      if (!_googleSignIn.supportsAuthenticate()) {
        throw Exception('Google Sign-In not supported on this platform');
      }

      // Attempt lightweight authentication first (silent sign-in)
      GoogleSignInAccount? account;
      final lightweightResult =
          _googleSignIn.attemptLightweightAuthentication();

      if (lightweightResult is Future<GoogleSignInAccount?>) {
        account = await lightweightResult;
      } else {
        account = lightweightResult;
      }

      // If silent sign-in failed, prompt user for authentication
      if (account == null) {
        account = await _googleSignIn.authenticate(
          scopeHint: ['email', 'profile'],
        );
      }

      // Get authorization for basic scopes needed for Firebase
      final authClient = account.authorizationClient;
      final authorization =
          await authClient.authorizationForScopes(['email', 'profile']);

      // Get the authentication tokens (synchronous in v7)
      final GoogleSignInAuthentication googleAuth = account.authentication;

      // Create Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authorization?.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential result =
          await _auth.signInWithCredential(credential);

      if (AppConstants.enableLogging) {
        print('✅ Google sign in successful: ${result.user?.email}');
      }

      return result.user;
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Google sign in error: $e');
      }
      rethrow;
    }
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize(
          // Add configuration if needed
          // clientId: 'your-client-id',
          // serverClientId: 'your-server-client-id',
          );

      if (AppConstants.enableLogging) {
        print('✅ Google Sign-In initialized');
      }
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Google Sign-In initialization error: $e');
      }
      // Don't rethrow - might already be initialized
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Sign out from both Firebase and Google
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);

      if (AppConstants.enableLogging) {
        print('✅ Sign out successful (Firebase + Google)');
      }
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Sign out error: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // EMAIL VERIFICATION
  // ============================================================================

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();

        if (AppConstants.enableLogging) {
          print('✅ Email verification sent to: ${user.email}');
        }
      } else {
        throw Exception('User not found or email already verified');
      }
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Send email verification error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> reloadUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();

        if (AppConstants.enableLogging) {
          print('✅ User reloaded');
        }
      }
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Reload user error: $e');
      }
      rethrow;
    }
  }

  @override
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  @override
  Future<bool> isUserAuthenticatedAndVerified() async {
    final user = currentUser;
    return user != null && user.emailVerified;
  }

  // ============================================================================
  // PASSWORD OPERATIONS
  // ============================================================================

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);

      if (AppConstants.enableLogging) {
        print('✅ Password reset email sent to: $email');
      }
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Send password reset email error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);

        if (AppConstants.enableLogging) {
          print('✅ Password updated');
        }
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Update password error: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // USER PROFILE OPERATIONS
  // ============================================================================

  @override
  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);

        if (AppConstants.enableLogging) {
          print('✅ Display name updated to: $displayName');
        }
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Update display name error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> updatePhotoURL(String photoURL) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePhotoURL(photoURL);

        if (AppConstants.enableLogging) {
          print('✅ Photo URL updated');
        }
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Update photo URL error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateProfile(
          displayName: displayName,
          photoURL: photoURL,
        );

        if (AppConstants.enableLogging) {
          print('✅ Profile updated');
        }
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Update profile error: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // ACCOUNT MANAGEMENT
  // ============================================================================

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();

        if (AppConstants.enableLogging) {
          print('✅ Account deleted');
        }
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Delete account error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> reauthenticateWithCredential(AuthCredential credential) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reauthenticateWithCredential(credential);

        if (AppConstants.enableLogging) {
          print('✅ Reauthentication successful');
        }
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Reauthenticate error: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // TOKEN OPERATIONS
  // ============================================================================

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        return await user.getIdToken(forceRefresh);
      }
      return null;
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Get ID token error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<IdTokenResult> getIdTokenResult({bool forceRefresh = false}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        return await user.getIdTokenResult(forceRefresh);
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Get ID token result error: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // USER VALIDATION
  // ============================================================================

  @override
  Future<bool> validateCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      // Token'ı force refresh ile yenile ve geçerliliğini kontrol et
      final tokenResult = await user.getIdTokenResult(true);

      // Token'ın geçerlilik süresini kontrol et
      if (tokenResult.expirationTime != null) {
        final now = DateTime.now();
        final expirationTime = tokenResult.expirationTime!;

        if (now.isAfter(expirationTime)) {
          if (AppConstants.enableLogging) {
            print('🔥 Token expired: ${tokenResult.expirationTime}');
          }
          return false;
        }
      }

      // Kullanıcı bilgilerini yenile
      await user.reload();

      // Kullanıcının hala mevcut olup olmadığını kontrol et
      if (_auth.currentUser == null) {
        if (AppConstants.enableLogging) {
          print('🔥 User no longer exists after reload');
        }
        return false;
      }

      if (AppConstants.enableLogging) {
        print('✅ User validation successful: ${user.email}');
      }

      return true;
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 User validation error: $e');
      }
      return false;
    }
  }

  @override
  Future<void> clearInvalidUser() async {
    try {
      // Kullanıcıyı sign out yap
      await signOut();

      if (AppConstants.enableLogging) {
        print('✅ Invalid user cleared from cache');
      }
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Clear invalid user error: $e');
      }
      // Hata olsa bile devam et
    }
  }
}
