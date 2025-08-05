import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

/// Base Use Case class
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

// ============================================================================
// LOGIN USE CASES
// ============================================================================

/// Email ve şifre ile giriş yapma use case
class LoginWithEmailUseCase implements UseCase<UserCredential, LoginParams> {
  final AuthRepository repository;

  LoginWithEmailUseCase(this.repository);

  @override
  Future<UserCredential> call(LoginParams params) async {
    return await repository.signInWithEmailPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}

/// Google ile giriş yapma use case
class LoginWithGoogleUseCase implements UseCase<UserCredential, NoParams> {
  final AuthRepository repository;

  LoginWithGoogleUseCase(this.repository);

  @override
  Future<UserCredential> call(NoParams params) async {
    return await repository.signInWithGoogle();
  }
}

// ============================================================================
// REGISTER USE CASES
// ============================================================================

/// Email ve şifre ile kayıt olma use case
class RegisterWithEmailUseCase
    implements UseCase<UserCredential, RegisterParams> {
  final AuthRepository repository;

  RegisterWithEmailUseCase(this.repository);

  @override
  Future<UserCredential> call(RegisterParams params) async {
    return await repository.registerWithEmailPassword(
      email: params.email,
      password: params.password,
      name: params.name,
    );
  }
}

class RegisterParams {
  final String email;
  final String password;
  final String name;

  RegisterParams({
    required this.email,
    required this.password,
    required this.name,
  });
}

// ============================================================================
// EMAIL VERIFICATION USE CASES
// ============================================================================

/// Email doğrulama gönderme use case
class SendEmailVerificationUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  SendEmailVerificationUseCase(this.repository);

  @override
  Future<void> call(NoParams params) async {
    return await repository.sendEmailVerification();
  }
}

/// Email doğrulama kontrol etme use case
class CheckEmailVerificationUseCase implements UseCase<bool, NoParams> {
  final AuthRepository repository;

  CheckEmailVerificationUseCase(this.repository);

  @override
  Future<bool> call(NoParams params) async {
    return await repository.checkEmailVerification();
  }
}

// ============================================================================
// PASSWORD RESET USE CASES
// ============================================================================

/// Şifre sıfırlama emaili gönderme use case
class SendPasswordResetUseCase implements UseCase<void, PasswordResetParams> {
  final AuthRepository repository;

  SendPasswordResetUseCase(this.repository);

  @override
  Future<void> call(PasswordResetParams params) async {
    return await repository.sendPasswordResetEmail(params.email);
  }
}

class PasswordResetParams {
  final String email;

  PasswordResetParams({required this.email});
}

// ============================================================================
// USER PROFILE USE CASES
// ============================================================================

/// Kullanıcı verileri getirme use case
class GetCurrentUserUseCase implements UseCase<UserModel?, NoParams> {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  Future<UserModel?> call(NoParams params) async {
    return await repository.getCurrentUserData();
  }
}

/// Kullanıcı profilini güncelleme use case
class UpdateUserProfileUseCase implements UseCase<void, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateUserProfileUseCase(this.repository);

  @override
  Future<void> call(UpdateProfileParams params) async {
    // Firestore'da güncelle
    await repository.updateUserProfile(params.user);

    // Auth'da display name güncelle
    if (params.updateDisplayName) {
      await repository.updateDisplayName(params.user.name);
    }
  }
}

class UpdateProfileParams {
  final UserModel user;
  final bool updateDisplayName;

  UpdateProfileParams({
    required this.user,
    this.updateDisplayName = true,
  });
}

// ============================================================================
// LOGOUT & ACCOUNT MANAGEMENT USE CASES
// ============================================================================

/// Çıkış yapma use case
class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<void> call(NoParams params) async {
    return await repository.signOut();
  }
}

/// Hesap silme use case
class DeleteAccountUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  DeleteAccountUseCase(this.repository);

  @override
  Future<void> call(NoParams params) async {
    return await repository.deleteAccount();
  }
}

// ============================================================================
// AUTH STATE USE CASES
// ============================================================================

/// Auth state stream'i getirme use case
class GetAuthStateUseCase implements UseCase<Stream<User?>, NoParams> {
  final AuthRepository repository;

  GetAuthStateUseCase(this.repository);

  @override
  Future<Stream<User?>> call(NoParams params) async {
    return repository.authStateChanges;
  }
}

/// Current user getirme use case
class GetCurrentFirebaseUserUseCase implements UseCase<User?, NoParams> {
  final AuthRepository repository;

  GetCurrentFirebaseUserUseCase(this.repository);

  @override
  Future<User?> call(NoParams params) async {
    return repository.currentUser;
  }
}

// ============================================================================
// HELPER CLASSES
// ============================================================================

/// Parametre gerektirmeyen use case'ler için
class NoParams {
  const NoParams();
}
