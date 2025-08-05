import 'package:firebase_auth/firebase_auth.dart';

import '../../core/utils/app_constants.dart';
import '../../domain/services/error_handler_service.dart';
import '../../core/utils/notification_helper.dart';

/// Error Handler Service Implementation
/// SOLID: Single Responsibility - Sadece error handling
/// SOLID: Open/Closed - Yeni error types kolayca eklenebilir
class ErrorHandlerServiceImpl implements ErrorHandlerService {
  // ============================================================================
  // ERROR MESSAGE PROCESSING
  // ============================================================================

  @override
  String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return getAuthErrorMessage(error);
    } else if (error is FirebaseException) {
      return getFirestoreErrorMessage(error);
    } else if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    } else {
      return error?.toString() ?? MessageConstants.errorGeneral;
    }
  }

  @override
  String getFirebaseErrorMessage(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return MessageConstants.errorPermission;
        case 'not-found':
          return MessageConstants.errorNotFound;
        case 'network-request-failed':
          return MessageConstants.errorNetwork;
        case 'too-many-requests':
          return 'Çok fazla istek gönderdiniz. Lütfen bekleyin.';
        case 'quota-exceeded':
          return 'Veri limitine ulaşıldı. Daha sonra tekrar deneyin.';
        case 'unavailable':
          return 'Servis şu anda kullanılamıyor. Lütfen daha sonra deneyin.';
        case 'deadline-exceeded':
          return 'İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.';
        case 'resource-exhausted':
          return 'Kaynak limiti aşıldı. Lütfen daha sonra deneyin.';
        default:
          if (AppConstants.enableLogging) {
            print('🔥 Firebase error: ${error.code} - ${error.message}');
          }
          return error.message ?? MessageConstants.errorGeneral;
      }
    }
    return MessageConstants.errorGeneral;
  }

  @override
  String getAuthErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.';
        case 'wrong-password':
          return 'Yanlış şifre girdiniz.';
        case 'email-already-in-use':
          return 'Bu e-posta adresi zaten kullanımda.';
        case 'weak-password':
          return 'Şifre çok zayıf. En az 6 karakter olmalı.';
        case 'invalid-email':
          return 'Geçersiz e-posta adresi formatı.';
        case 'user-disabled':
          return 'Bu kullanıcı hesabı devre dışı bırakılmış.';
        case 'too-many-requests':
          return 'Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin.';
        case 'operation-not-allowed':
          return 'Bu işlem şu anda izin verilmiyor.';
        case 'invalid-credential':
          return 'Geçersiz kimlik bilgileri.';
        case 'account-exists-with-different-credential':
          return 'Bu e-posta adresi farklı bir yöntemle kayıtlı.';
        case 'requires-recent-login':
          return 'Bu işlem için yeniden giriş yapmanız gerekiyor.';
        case 'provider-already-linked':
          return 'Bu hesap zaten başka bir sağlayıcı ile bağlantılı.';
        case 'no-such-provider':
          return 'Bu hesap için belirtilen sağlayıcı bulunamadı.';
        case 'invalid-user-token':
          return 'Kullanıcı oturumu geçersiz. Lütfen yeniden giriş yapın.';
        case 'network-request-failed':
          return MessageConstants.errorNetwork;
        case 'user-token-expired':
          return 'Oturum süresi doldu. Lütfen yeniden giriş yapın.';
        default:
          if (AppConstants.enableLogging) {
            print('🔥 Auth error: ${error.code} - ${error.message}');
          }
          return error.message ?? MessageConstants.errorAuth;
      }
    }
    return MessageConstants.errorAuth;
  }

  @override
  String getFirestoreErrorMessage(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'cancelled':
          return 'İşlem iptal edildi.';
        case 'unknown':
          return 'Bilinmeyen bir hata oluştu.';
        case 'invalid-argument':
          return 'Geçersiz parametre.';
        case 'deadline-exceeded':
          return 'İşlem zaman aşımına uğradı.';
        case 'not-found':
          return MessageConstants.errorNotFound;
        case 'already-exists':
          return 'Bu kayıt zaten mevcut.';
        case 'permission-denied':
          return MessageConstants.errorPermission;
        case 'resource-exhausted':
          return 'Kaynak limiti aşıldı.';
        case 'failed-precondition':
          return 'İşlem önkoşulları sağlanmadı.';
        case 'aborted':
          return 'İşlem iptal edildi.';
        case 'out-of-range':
          return 'Geçersiz aralık.';
        case 'unimplemented':
          return 'Bu özellik henüz desteklenmiyor.';
        case 'internal':
          return 'Dahili sunucu hatası.';
        case 'unavailable':
          return 'Servis şu anda kullanılamıyor.';
        case 'data-loss':
          return 'Veri kaybı algılandı.';
        case 'unauthenticated':
          return 'Kimlik doğrulama gerekli.';
        default:
          if (AppConstants.enableLogging) {
            print('🔥 Firestore error: ${error.code} - ${error.message}');
          }
          return error.message ?? MessageConstants.errorGeneral;
      }
    }
    return MessageConstants.errorGeneral;
  }

  // ============================================================================
  // ERROR LOGGING
  // ============================================================================

  @override
  void logError(String title, dynamic error, {StackTrace? stackTrace}) {
    if (AppConstants.enableLogging) {
      print('❌ ERROR: $title');
      print('   Message: $error');
      if (stackTrace != null) {
        print('   Stack: $stackTrace');
      }
    }

    // TODO: Send to crash reporting service (Firebase Crashlytics, Sentry, etc.)
    // if (AppConstants.enableCrashlytics) {
    //   FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: false);
    // }
  }

  @override
  void logWarning(String message) {
    if (AppConstants.enableLogging) {
      print('⚠️ WARNING: $message');
    }
  }

  @override
  void logInfo(String message) {
    if (AppConstants.enableLogging) {
      print('ℹ️ INFO: $message');
    }
  }

  // ============================================================================
  // ERROR REPORTING
  // ============================================================================

  @override
  Future<void> reportError(dynamic error, {StackTrace? stackTrace, Map<String, dynamic>? context}) async {
    try {
      // Log locally first
      logError('Reported Error', error, stackTrace: stackTrace);

      // TODO: Implement crash reporting
      // if (AppConstants.enableCrashlytics) {
      //   await FirebaseCrashlytics.instance.recordError(
      //     error,
      //     stackTrace,
      //     fatal: false,
      //     parameters: context,
      //   );
      // }

      if (AppConstants.enableLogging) {
        print('📊 Error reported to crash analytics');
        if (context != null) {
          print('   Context: $context');
        }
      }
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Failed to report error: $e');
      }
    }
  }

  // ============================================================================
  // ERROR CATEGORIES
  // ============================================================================

  @override
  bool isNetworkError(dynamic error) {
    if (error is FirebaseException) {
      return error.code == 'network-request-failed' || error.code == 'unavailable';
    }

    final errorMessage = error.toString().toLowerCase();
    return errorMessage.contains('network') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('timeout') ||
        errorMessage.contains('unreachable');
  }

  @override
  bool isPermissionError(dynamic error) {
    if (error is FirebaseException) {
      return error.code == 'permission-denied' || error.code == 'unauthenticated';
    }

    final errorMessage = error.toString().toLowerCase();
    return errorMessage.contains('permission') ||
        errorMessage.contains('unauthorized') ||
        errorMessage.contains('forbidden');
  }

  @override
  bool isNotFoundError(dynamic error) {
    if (error is FirebaseException) {
      return error.code == 'not-found';
    }

    final errorMessage = error.toString().toLowerCase();
    return errorMessage.contains('not found') || errorMessage.contains('not exist');
  }

  @override
  bool isValidationError(dynamic error) {
    if (error is FirebaseException) {
      return error.code == 'invalid-argument' || error.code == 'failed-precondition' || error.code == 'out-of-range';
    }

    if (error is FirebaseAuthException) {
      return error.code == 'weak-password' || error.code == 'invalid-email' || error.code == 'invalid-credential';
    }

    final errorMessage = error.toString().toLowerCase();
    return errorMessage.contains('validation') || errorMessage.contains('invalid') || errorMessage.contains('required');
  }

  @override
  void handleAndNotify(
    dynamic error, {
    String? fallbackMessage,
    String? fallbackTitle,
    Duration? duration,
  }) {
    if (isNetworkError(error)) {
      NotificationHelper.networkError();
    } else if (isValidationError(error)) {
      NotificationHelper.validationError(getErrorMessage(error));
    } else if (isPermissionError(error)) {
      NotificationHelper.permissionError();
    } else if (error is FirebaseAuthException) {
      // Sadece gerçek Firebase Auth hataları için auth error göster
      NotificationHelper.showError(
        getAuthErrorMessage(error),
        title: 'Kimlik Doğrulama Hatası',
        duration: duration,
      );
    } else {
      NotificationHelper.showError(
        fallbackMessage ?? getErrorMessage(error),
        title: fallbackTitle ?? 'Hata',
        duration: duration,
      );
    }
  }
}
