import 'package:get/get.dart';
import '../utils/app_constants.dart';
import '../utils/notification_helper.dart';

/// Base Controller - Tüm controller'lar için ortak fonksiyonalite
/// SOLID: Single Responsibility - Loading states ve error handling
/// SOLID: Open/Closed - Extension için açık, modifikasyon için kapalı
abstract class BaseController extends GetxController {
  // ============================================================================
  // LOADING STATES
  // ============================================================================

  final RxBool _isLoading = false.obs;
  final RxBool _isCreating = false.obs;
  final RxBool _isUpdating = false.obs;
  final RxBool _isDeleting = false.obs;
  final RxBool _isRefreshing = false.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isCreating => _isCreating.value;
  bool get isUpdating => _isUpdating.value;
  bool get isDeleting => _isDeleting.value;
  bool get isRefreshing => _isRefreshing.value;
  bool get isBusy => isLoading || isCreating || isUpdating || isDeleting;

  // ============================================================================
  // STANDARDIZED EXECUTION PATTERNS
  // ============================================================================

  /// Loading state ile operation execute et
  Future<T> executeWithLoading<T>(
    Future<T> Function() operation, {
    String? errorMessage,
    bool showError = true,
  }) async {
    try {
      _isLoading(true);
      return await operation();
    } catch (e) {
      if (showError) {
        NotificationHelper.showError(
          errorMessage ?? 'İşlem sırasında hata oluştu',
        );
      }
      _logError('Loading operation', e);
      rethrow;
    } finally {
      _isLoading(false);
    }
  }

  /// Creating state ile operation execute et
  Future<T> executeWithCreating<T>(
    Future<T> Function() operation, {
    String? successMessage,
    String? errorMessage,
    bool showSuccess = true,
    bool showError = true,
  }) async {
    try {
      _isCreating(true);
      final result = await operation();

      if (showSuccess && successMessage != null) {
        NotificationHelper.showSuccess(successMessage);
      }

      return result;
    } catch (e) {
      if (showError) {
        NotificationHelper.showError(
          errorMessage ?? 'Oluşturma işlemi sırasında hata oluştu',
        );
      }
      _logError('Create operation', e);
      return false as T;
    } finally {
      _isCreating(false);
    }
  }

  /// Updating state ile operation execute et
  Future<T> executeWithUpdating<T>(
    Future<T> Function() operation, {
    String? successMessage,
    String? errorMessage,
    bool showSuccess = true,
    bool showError = true,
  }) async {
    try {
      _isUpdating(true);
      final result = await operation();

      if (showSuccess && successMessage != null) {
        NotificationHelper.showSuccess(successMessage);
      }

      return result;
    } catch (e) {
      if (showError) {
        NotificationHelper.showError(
          errorMessage ?? 'Güncelleme işlemi sırasında hata oluştu',
        );
      }
      _logError('Update operation', e);
      return false as T;
    } finally {
      _isUpdating(false);
    }
  }

  /// Deleting state ile operation execute et
  Future<T> executeWithDeleting<T>(
    Future<T> Function() operation, {
    String? successMessage,
    String? errorMessage,
    bool showSuccess = true,
    bool showError = true,
  }) async {
    try {
      _isDeleting(true);
      final result = await operation();

      if (showSuccess && successMessage != null) {
        NotificationHelper.showSuccess(successMessage);
      }

      return result;
    } catch (e) {
      if (showError) {
        NotificationHelper.showError(
          errorMessage ?? 'Silme işlemi sırasında hata oluştu',
        );
      }
      _logError('Delete operation', e);
      return false as T;
    } finally {
      _isDeleting(false);
    }
  }

  /// Refreshing state ile operation execute et
  Future<T> executeWithRefreshing<T>(
    Future<T> Function() operation, {
    String? errorMessage,
    bool showError = true,
  }) async {
    try {
      _isRefreshing(true);
      return await operation();
    } catch (e) {
      if (showError) {
        NotificationHelper.showError(
          errorMessage ?? 'Yenileme işlemi sırasında hata oluştu',
        );
      }
      _logError('Refresh operation', e);
      rethrow;
    } finally {
      _isRefreshing(false);
    }
  }

  // ============================================================================
  // SAFE EXECUTION PATTERNS
  // ============================================================================

  /// Safe execution - hata durumunda null döner
  Future<T?> executeSafely<T>(
    Future<T> Function() operation, {
    String? errorMessage,
    bool showError = false,
    bool logError = true,
  }) async {
    try {
      return await operation();
    } catch (e) {
      if (logError) {
        _logError('Safe execution', e);
      }
      if (showError && errorMessage != null) {
        NotificationHelper.showError(errorMessage);
      }
      return null;
    }
  }

  /// Safe void execution - hata durumunda sessizce devam eder
  Future<void> executeSafelyVoid(
    Future<void> Function() operation, {
    String? errorMessage,
    bool showError = false,
    bool logError = true,
  }) async {
    try {
      await operation();
    } catch (e) {
      if (logError) {
        _logError('Safe void execution', e);
      }
      if (showError && errorMessage != null) {
        NotificationHelper.showError(errorMessage);
      }
    }
  }

  // ============================================================================
  // ERROR HANDLING
  // ============================================================================

  /// Standardized error logging
  void _logError(String operation, dynamic error) {
    if (AppConstants.enableLogging) {
      print('🔥 $operation error in ${runtimeType.toString()}: $error');
    }
  }

  /// Manuel loading state control
  void setLoading(bool value) => _isLoading(value);
  void setCreating(bool value) => _isCreating(value);
  void setUpdating(bool value) => _isUpdating(value);
  void setDeleting(bool value) => _isDeleting(value);
  void setRefreshing(bool value) => _isRefreshing(value);

  /// Tüm loading state'leri temizle
  void clearAllLoadingStates() {
    _isLoading(false);
    _isCreating(false);
    _isUpdating(false);
    _isDeleting(false);
    _isRefreshing(false);
  }

  @override
  void onClose() {
    clearAllLoadingStates();
    super.onClose();
  }
}

/// Loading State Mixin - Sadece loading states isteyen controller'lar için
mixin LoadingStateMixin on GetxController {
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  void setLoading(bool value) => _isLoading(value);

  Future<T> withLoading<T>(Future<T> Function() operation) async {
    try {
      setLoading(true);
      return await operation();
    } finally {
      setLoading(false);
    }
  }
}
