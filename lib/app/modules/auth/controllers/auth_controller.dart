import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_constants.dart';
import '../../../domain/usecases/auth_usecases.dart';
import '../../../domain/usecases/vehicle_usecases.dart' as vehicle_usecases;
import '../../../domain/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../core/utils/notification_helper.dart';
import '../../../core/services/navigation_service.dart';
import '../../../core/controllers/base_controller.dart';

/// Clean Architecture uyumlu Authentication Controller
/// SOLID: Single Responsibility - Sadece UI state management ve business logic orchestration
/// SOLID: Dependency Inversion - Use case'lere ve service'lere bağımlı, concrete implementation'lara değil
/// Data operations'lar use case'ler ve repository'ler üzerinden yapılır
/// BaseController: Standardized loading states ve execution patterns kullanır
class AuthController extends BaseController {
  // Dependencies (Use Cases)
  late final LoginWithEmailUseCase _loginWithEmailUseCase;
  late final LoginWithGoogleUseCase _loginWithGoogleUseCase;
  late final RegisterWithEmailUseCase _registerWithEmailUseCase;
  late final SendEmailVerificationUseCase _sendEmailVerificationUseCase;
  late final CheckEmailVerificationUseCase _checkEmailVerificationUseCase;
  late final SendPasswordResetUseCase _sendPasswordResetUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final UpdateUserProfileUseCase _updateUserProfileUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final DeleteAccountUseCase _deleteAccountUseCase;
  late final GetAuthStateUseCase _getAuthStateUseCase;
  late final vehicle_usecases.GetAllVehiclesUseCase _getAllVehiclesUseCase;

  // Dependencies (Services)
  late final NavigationService _navigationService;

  // Reactive State Variables
  final Rx<User?> _firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> _userModel = Rx<UserModel?>(null);
  final RxBool _isEmailVerificationSent = false.obs;

  // Public Getters
  User? get firebaseUser => _firebaseUser.value;
  UserModel? get userModel => _userModel.value;
  // isLoading BaseController'dan geliyor
  bool get isLoggedIn => _firebaseUser.value != null;
  bool get isEmailVerified => _firebaseUser.value?.emailVerified ?? false;
  bool get isEmailVerificationSent => _isEmailVerificationSent.value;

  @override
  void onInit() {
    super.onInit();

    // Use case'leri dependency injection ile al
    _initializeUseCases();

    // Auth state changes'i dinle
    _setupAuthStateListener();
  }

  /// Use case ve service dependency'lerini initialize et
  /// SOLID: Dependency Inversion - Interface'ler üzerinden dependency injection
  void _initializeUseCases() {
    _loginWithEmailUseCase = Get.find<LoginWithEmailUseCase>();
    _loginWithGoogleUseCase = Get.find<LoginWithGoogleUseCase>();
    _registerWithEmailUseCase = Get.find<RegisterWithEmailUseCase>();
    _sendEmailVerificationUseCase = Get.find<SendEmailVerificationUseCase>();
    _checkEmailVerificationUseCase = Get.find<CheckEmailVerificationUseCase>();
    _sendPasswordResetUseCase = Get.find<SendPasswordResetUseCase>();
    _getCurrentUserUseCase = Get.find<GetCurrentUserUseCase>();
    _updateUserProfileUseCase = Get.find<UpdateUserProfileUseCase>();
    _logoutUseCase = Get.find<LogoutUseCase>();
    _deleteAccountUseCase = Get.find<DeleteAccountUseCase>();
    _getAuthStateUseCase = Get.find<GetAuthStateUseCase>();
    _getAllVehiclesUseCase = Get.find<vehicle_usecases.GetAllVehiclesUseCase>();

    // Services
    _navigationService = Get.find<NavigationService>();
  }

  /// Auth state listener'ı setup et
  void _setupAuthStateListener() async {
    try {
      final authStream = await _getAuthStateUseCase(const NoParams());
      _firebaseUser.bindStream(authStream);
      ever(_firebaseUser, _onAuthStateChanged);

      // Uygulama başlatıldığında mevcut kullanıcıyı validate et
      await _validateExistingUser();
    } catch (e) {
      _handleError('Auth listener kurulum hatası', e);
    }
  }

  /// Mevcut kullanıcıyı validate et
  Future<void> _validateExistingUser() async {
    try {
      final currentUser = _firebaseUser.value;
      if (currentUser != null) {
        // Kullanıcıyı validate et
        final isValid = await _validateUser(currentUser);

        if (!isValid) {
          // Geçersiz kullanıcıyı temizle
          await _clearInvalidUser();
        }
      }
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Validate existing user error: $e');
      }
    }
  }

  /// Kullanıcıyı validate et
  Future<bool> _validateUser(User user) async {
    try {
      // Auth service üzerinden kullanıcıyı validate et
      final authService = Get.find<AuthService>();
      return await authService.validateCurrentUser();
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 User validation error: $e');
      }
      return false;
    }
  }

  /// Geçersiz kullanıcıyı temizle
  Future<void> _clearInvalidUser() async {
    try {
      final authService = Get.find<AuthService>();
      await authService.clearInvalidUser();

      if (AppConstants.enableLogging) {
        print('✅ Invalid user cleared');
      }
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Clear invalid user error: $e');
      }
    }
  }

  /// Firebase Auth state değişikliklerini handle eder (Business Logic)
  /// SOLID: Single Responsibility - Auth state, vehicle check ve navigation orchestration
  void _onAuthStateChanged(User? user) async {
    if (user != null) {
      await _loadUserData(user.uid);
      await _handleAuthenticatedUser(user);
    } else {
      _userModel.value = null;
      _navigationService.navigateToLogin();
    }
  }

  /// Authenticate edilmiş kullanıcı için business logic
  /// SOLID: Single Responsibility - Araç kontrolü business logic'i
  Future<void> _handleAuthenticatedUser(User user) async {
    // Email doğrulanmamışsa email verification'a git
    if (!user.emailVerified) {
      _navigationService.navigateToEmailVerification();
      return;
    }

    // Email doğrulandıysa araç kontrolü yap
    try {
      final vehicles = await _getAllVehiclesUseCase(
        vehicle_usecases.VehicleParams(userId: user.uid),
      );

      if (vehicles.isEmpty) {
        // Kullanıcının aracı yoksa araç kayıt sayfasına git
        _navigationService.navigateToVehicleForm();
        _logBusinessAction('No vehicles found - redirecting to vehicle form');
      } else {
        // Araç varsa ana uygulamaya git
        _navigationService.navigateToMainApp();
        _logBusinessAction('User has vehicles - redirecting to main app');
      }
    } catch (e) {
      // Hata durumunda login'e gönder
      _handleError('Araç kontrolü sırasında hata', e);
      _navigationService.navigateToLogin();
    }
  }

  /// Business action logging (debugging için)
  void _logBusinessAction(String action) {
    if (AppConstants.enableLogging) {
      print('🏢 Auth Business Logic: $action');
    }
  }

  /// Kullanıcı verilerini yükle
  /// SOLID: Single Responsibility - Sadece user data loading
  Future<void> _loadUserData(String uid) async {
    try {
      final userData = await _getCurrentUserUseCase(const NoParams());
      _userModel.value = userData;
    } catch (e) {
      _handleError('Kullanıcı verileri yüklenirken hata', e);
    }
  }

  // ============================================================================
  // PUBLIC METHODS (UI Actions)
  // ============================================================================

  /// Email ve şifre ile giriş yapma
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    await _executeAuthOperation(() async {
      final params = LoginParams(email: email, password: password);
      await _loginWithEmailUseCase(params);

      NotificationHelper.loginSuccess();
    });
  }

  /// Email ve şifre ile kayıt olma
  Future<void> registerWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    await _executeAuthOperation(() async {
      final params = RegisterParams(
        email: email,
        password: password,
        name: name,
      );
      await _registerWithEmailUseCase(params);

      // Kayıt sonrası email verification gönder
      await sendEmailVerification();

      NotificationHelper.registerSuccess();
    });
  }

  /// Google ile giriş yapma
  Future<void> signInWithGoogle() async {
    await executeWithLoading(() async {
      try {
        await _loginWithGoogleUseCase(const NoParams());
        NotificationHelper.loginSuccess();
      } on FirebaseAuthException catch (e) {
        // Google Sign-In specific error handling
        String userMessage;

        switch (e.code) {
          case 'google_sign_in_canceled':
            userMessage = 'Google ile giriş iptal edildi.';
            break;
          case 'google_sign_in_unknownError':
            userMessage = 'Google hesabınız bulunamadı. Lütfen cihazınıza Google hesabı ekleyin.';
            break;
          case 'google_sign_in_not_supported':
            userMessage = 'Bu cihazda Google ile giriş desteklenmiyor.';
            break;
          case 'missing_id_token':
            userMessage = 'Google kimlik doğrulama hatası. Lütfen tekrar deneyin.';
            break;
          case 'google_sign_in_failed':
            userMessage = 'Google ile giriş başarısız. İnternet bağlantınızı kontrol edin.';
            break;
          default:
            userMessage = 'Google ile giriş sırasında hata oluştu. Lütfen tekrar deneyin.';
        }

        NotificationHelper.showError(userMessage);

        if (AppConstants.enableLogging) {
          print('🔥 Google Sign-In Error: ${e.code} - ${e.message}');
        }
        rethrow;
      } catch (e) {
        NotificationHelper.showError('Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.');

        if (AppConstants.enableLogging) {
          print('🔥 Unexpected Google Sign-In Error: $e');
        }
        rethrow;
      }
    }, showError: false);
  }

  /// Email doğrulama gönderme
  Future<void> sendEmailVerification() async {
    try {
      await _sendEmailVerificationUseCase(const NoParams());
      _isEmailVerificationSent.value = true;

      NotificationHelper.emailVerificationSent();
    } catch (e) {
      _handleError('Email doğrulama gönderilirken hata', e);
    }
  }

  /// Email doğrulama durumunu kontrol etme
  /// SOLID: Single Responsibility - Sadece email verification check logic'i
  Future<void> checkEmailVerification() async {
    try {
      final isVerified = await _checkEmailVerificationUseCase(const NoParams());

      if (isVerified) {
        NotificationHelper.emailVerified();
        // SOLID: Separation of Concerns - Navigation logic ayrı service'te
        _navigationService.navigateToVehicleForm();
      } else {
        NotificationHelper.showInfo('Email adresiniz henüz doğrulanmadı.');
      }
    } catch (e) {
      _handleError('Email doğrulama kontrol edilirken hata', e);
    }
  }

  /// Şifre sıfırlama emaili gönderme
  Future<void> sendPasswordResetEmail(String email) async {
    await _executeAuthOperation(() async {
      final params = PasswordResetParams(email: email);
      await _sendPasswordResetUseCase(params);

      NotificationHelper.passwordResetSent();
    });
  }

  /// Kullanıcı profilini güncelleme
  Future<void> updateUserProfile({
    String? name,
    String? defaultVehicleId,
  }) async {
    await _executeAuthOperation(() async {
      if (_userModel.value != null) {
        final updatedUser = _userModel.value!.copyWith(
          name: name,
          defaultVehicleId: defaultVehicleId,
        );

        final params = UpdateProfileParams(
          user: updatedUser,
          updateDisplayName: name != null,
        );

        await _updateUserProfileUseCase(params);
        _userModel.value = updatedUser;

        NotificationHelper.profileUpdated();
      }
    });
  }

  /// Çıkış yapma
  Future<void> signOut() async {
    await _executeAuthOperation(() async {
      await _logoutUseCase(const NoParams());
      NotificationHelper.logoutSuccess();
    });
  }

  /// Hesabı silme
  Future<void> deleteAccount() async {
    await _executeAuthOperation(() async {
      await _deleteAccountUseCase(const NoParams());
      NotificationHelper.showSuccess('Hesabınız başarıyla silindi');
    });
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /// Firebase Auth hatalarını handle eden wrapper
  Future<void> _executeAuthOperation(Future<void> Function() operation) async {
    await executeWithLoading(() async {
      try {
        await operation();
      } on FirebaseAuthException catch (e) {
        _handleAuthError(e);
        rethrow; // BaseController'ın error handling'ine de geçir
      }
    }, showError: false); // Auth-specific error handling kullanıyoruz
  }

  /// Firebase Auth hatalarını handle etme
  void _handleAuthError(FirebaseAuthException e) {
    String message = _getAuthErrorMessage(e.code);

    if (e.code == 'user-not-found' || e.code == 'wrong-password') {
      NotificationHelper.loginError(message);
    } else if (e.code == 'email-already-in-use' || e.code == 'weak-password') {
      NotificationHelper.registerError(message);
    } else if (e.code == 'network-request-failed') {
      NotificationHelper.networkError();
    } else {
      NotificationHelper.showError(message);
    }

    if (AppConstants.enableLogging) {
      print('🔥 Firebase Auth Error: ${e.code} - ${e.message}');
    }
  }

  /// Auth error code'unu Türkçe mesaja çevirme
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Bu email adresi ile kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Hatalı şifre.';
      case 'email-already-in-use':
        return 'Bu email adresi zaten kullanımda.';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter olmalı.';
      case 'invalid-email':
        return 'Geçersiz email adresi.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'too-many-requests':
        return 'Çok fazla deneme. Lütfen daha sonra tekrar deneyin.';
      case 'network-request-failed':
        return 'İnternet bağlantısı hatası.';
      case 'sign_in_canceled':
        return 'Giriş işlemi iptal edildi.';
      case 'requires-recent-login':
        return 'Bu işlem için yeniden giriş yapmanız gerekiyor.';
      default:
        return 'Bilinmeyen bir hata oluştu.';
    }
  }

  /// Genel hata handling
  void _handleError(String title, dynamic error) {
    NotificationHelper.showError(
      error.toString(),
      title: title,
    );

    if (AppConstants.enableLogging) {
      print('❌ $title: $error');
    }
  }

  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }
}
