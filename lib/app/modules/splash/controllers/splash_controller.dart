import 'package:get/get.dart';
import '../../../core/controllers/base_controller.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/services/navigation_service.dart';
import '../../../domain/usecases/auth_usecases.dart' as auth_usecases;
import '../../../domain/usecases/vehicle_usecases.dart' as vehicle_usecases;
import '../../../domain/services/error_handler_service.dart';

/// Splash Controller - Clean Architecture & SOLID Uyumlu
/// Sadece orchestrasyon ve UI state yönetimi içerir
class SplashController extends BaseController {
  // UseCase Bağımlılıkları
  late final auth_usecases.GetCurrentUserUseCase _getCurrentUserUseCase;
  late final auth_usecases.CheckEmailVerificationUseCase _checkEmailVerificationUseCase;
  late final vehicle_usecases.GetDefaultVehicleUseCase _getDefaultVehicleUseCase;
  late final NavigationService _navigationService;
  late final ErrorHandlerService _errorHandler;

  // Reactive Variables
  final RxString _statusMessage = 'Uygulama başlatılıyor...'.obs;
  final RxDouble _progress = 0.0.obs;

  // Getters
  String get statusMessage => _statusMessage.value;

  double get progress => _progress.value;

  @override
  void onInit() {
    super.onInit();
    _initializeDependencies();
    _startSplashSequence();
  }

  /// Gerekli bağımlılıkları al
  void _initializeDependencies() {
    _getCurrentUserUseCase = Get.find<auth_usecases.GetCurrentUserUseCase>();
    _checkEmailVerificationUseCase = Get.find<auth_usecases.CheckEmailVerificationUseCase>();
    _getDefaultVehicleUseCase = Get.find<vehicle_usecases.GetDefaultVehicleUseCase>();
    _navigationService = Get.find<NavigationService>();
    _errorHandler = Get.find<ErrorHandlerService>();
  }

  /// Splash akışını başlat
  Future<void> _startSplashSequence() async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      await _updateProgress(0.2, 'Servisler kontrol ediliyor...');
      await _checkCoreServices();
      await Future.delayed(const Duration(milliseconds: 200));
      await _updateProgress(0.5, 'Kullanıcı durumu kontrol ediliyor...');
      final user = await _getCurrentUser();
      await Future.delayed(const Duration(milliseconds: 200));
      await _updateProgress(0.7, 'Kullanıcı doğrulanıyor...');
      final isValid = await _validateCurrentUser(user);
      await Future.delayed(const Duration(milliseconds: 200));
      await _updateProgress(1.0, 'Tamamlandı');
      await Future.delayed(const Duration(milliseconds: 200));
      await _navigateToAppropriatePage(user, isValid);
    } catch (e, stack) {
      _errorHandler.logError('Splash Başlatma Hatası', e, stackTrace: stack);
      await _handleSplashError(e);
    }
  }

  /// Progress ve status message güncelle
  Future<void> _updateProgress(double progress, String message) async {
    _progress.value = progress;
    _statusMessage.value = message;
    if (AppConstants.enableLogging) {
      print('🚀 Splash Progress: ${(progress * 100).toInt()}% - $message');
    }
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// Core servislerin hazır olup olmadığını kontrol et
  Future<void> _checkCoreServices() async {
    // Burada sadece gerekli servislerin register olup olmadığı kontrol edilebilir
    if (!Get.isRegistered<auth_usecases.GetCurrentUserUseCase>() ||
        !Get.isRegistered<auth_usecases.CheckEmailVerificationUseCase>() ||
        !Get.isRegistered<vehicle_usecases.GetDefaultVehicleUseCase>() ||
        !Get.isRegistered<NavigationService>()) {
      throw Exception('Gerekli servisler başlatılamadı');
    }
    if (AppConstants.enableLogging) {
      print('✅ Core services check completed');
    }
  }

  /// Mevcut kullanıcıyı getir
  Future<dynamic> _getCurrentUser() async {
    try {
      final user = await _getCurrentUserUseCase(const auth_usecases.NoParams());
      if (AppConstants.enableLogging) {
        print('👤 Current user: ${user?.email ?? 'None'}');
      }
      return user;
    } catch (e, stack) {
      _errorHandler.logError('Kullanıcı alınamadı', e, stackTrace: stack);
      return null;
    }
  }

  /// Kullanıcı doğrulama (ör: email doğrulama)
  Future<bool> _validateCurrentUser(dynamic user) async {
    if (user == null) return false;
    try {
      final isVerified = await _checkEmailVerificationUseCase(const auth_usecases.NoParams());
      if (AppConstants.enableLogging) {
        print('✅ Email doğrulama durumu: $isVerified');
      }
      return isVerified;
    } catch (e, stack) {
      _errorHandler.logError('Kullanıcı doğrulama hatası', e, stackTrace: stack);
      return false;
    }
  }

  /// Uygun sayfaya yönlendir
  Future<void> _navigateToAppropriatePage(dynamic user, bool isVerified) async {
    try {
      if (user != null && isVerified) {
        // Default araç var mı kontrolü
        final defaultVehicle = await _getDefaultVehicleUseCase(vehicle_usecases.VehicleParams(userId: user.id));
        if (defaultVehicle != null) {
          _navigationService.navigateToMainApp();
        } else {
          _navigationService.navigateToVehicleForm();
        }
      } else if (user != null && !isVerified) {
        _navigationService.navigateToEmailVerification();
      } else {
        _navigationService.navigateToLogin();
      }
    } catch (e, stack) {
      _errorHandler.logError('Yönlendirme Hatası', e, stackTrace: stack);
      _navigationService.navigateToLogin();
    }
  }

  /// Splash error handling
  Future<void> _handleSplashError(dynamic error) async {
    if (AppConstants.enableLogging) {
      print('🔥 Splash error: $error');
    }
    _errorHandler.logError('Splash error', error);
    final errorMessage = _errorHandler.getErrorMessage(error);
    _statusMessage.value = 'Bir hata oluştu...';
    await Future.delayed(const Duration(seconds: 1));
    Get.offAllNamed('/login');
    _errorHandler.handleAndNotify(
      error,
      fallbackMessage: errorMessage,
      fallbackTitle: 'Başlatma Hatası',
      duration: const Duration(seconds: 3),
    );
  }

  /// Manual refresh için
  Future<void> retrySplash() async {
    _progress.value = 0.0;
    _statusMessage.value = 'Yeniden başlatılıyor...';
    await _startSplashSequence();
  }
}
