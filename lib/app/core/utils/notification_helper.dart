import 'package:get/get.dart';
import '../services/notification_service.dart';

/// Notification Helper
/// SOLID: Single Responsibility, Dependency Inversion
/// Static helper for easy access to notification service
class NotificationHelper {
  static NotificationService get _service => Get.find<NotificationService>();

  /// Show success notification
  /// Usage: NotificationHelper.showSuccess('Operation completed!')
  static void showSuccess(String message, {String? title, Duration? duration}) {
    _service.showSuccess(message, title: title, duration: duration);
  }

  /// Show error notification
  /// Usage: NotificationHelper.showError('Something went wrong')
  static void showError(String message, {String? title, Duration? duration}) {
    _service.showError(message, title: title, duration: duration);
  }

  /// Show warning notification
  /// Usage: NotificationHelper.showWarning('Please check your input')
  static void showWarning(String message, {String? title, Duration? duration}) {
    _service.showWarning(message, title: title, duration: duration);
  }

  /// Show info notification
  /// Usage: NotificationHelper.showInfo('New feature available')
  static void showInfo(String message, {String? title, Duration? duration}) {
    _service.showInfo(message, title: title, duration: duration);
  }

  /// Show loading notification
  /// Usage: NotificationHelper.showLoading('Please wait...')
  static void showLoading(String message) {
    _service.showLoading(message);
  }

  /// Hide loading notification
  /// Usage: NotificationHelper.hideLoading()
  static void hideLoading() {
    _service.hideLoading();
  }

  /// Clear all notifications
  /// Usage: NotificationHelper.clearAll()
  static void clearAll() {
    _service.clearAll();
  }

  // ============================================================================
  // BUSINESS SPECIFIC HELPERS
  // ============================================================================

  /// Authentication related notifications
  static void loginSuccess() {
    showSuccess('Başarıyla giriş yapıldı', title: 'Hoş Geldiniz');
  }

  static void loginError(String error) {
    showError(error, title: 'Giriş Hatası');
  }

  static void registerSuccess() {
    showSuccess(
      'Hesabınız oluşturuldu. Lütfen e-posta adresinizi doğrulayın.',
      title: 'Kayıt Başarılı',
      duration: const Duration(seconds: 5),
    );
  }

  static void registerError(String error) {
    showError(error, title: 'Kayıt Hatası');
  }

  static void emailVerificationSent() {
    showInfo(
      'Doğrulama e-postası gönderildi. Lütfen e-posta kutunuzu kontrol edin.',
      title: 'E-posta Doğrulama',
      duration: const Duration(seconds: 4),
    );
  }

  static void emailVerified() {
    showSuccess('E-posta adresiniz doğrulandı!', title: 'Doğrulama Başarılı');
  }

  static void passwordResetSent() {
    showInfo(
      'Şifre sıfırlama e-postası gönderildi.',
      title: 'Şifre Sıfırlama',
    );
  }

  static void logoutSuccess() {
    showInfo('Başarıyla çıkış yapıldı', title: 'Güle Güle');
  }

  /// Dashboard related notifications
  static void dashboardDataLoading() {
    showLoading('Dashboard verileri yükleniyor...');
  }

  static void dashboardDataLoaded() {
    hideLoading();
  }

  static void dashboardDataError(String error) {
    hideLoading();
    showError(error, title: 'Veri Yükleme Hatası');
  }

  static void refreshSuccess() {
    showSuccess('Veriler güncellendi', duration: const Duration(seconds: 2));
  }

  /// Business operations notifications
  static void rideStarted() {
    showSuccess('Sefer başlatıldı', title: 'Başarılı');
  }

  static void rideCompleted() {
    showSuccess('Sefer tamamlandı', title: 'Başarılı');
  }

  static void expenseAdded() {
    showSuccess('Gider eklendi', title: 'Başarılı');
  }

  static void vehicleAdded() {
    showSuccess('Araç eklendi', title: 'Başarılı');
  }

  static void profileUpdated() {
    showSuccess('Profil güncellendi', title: 'Başarılı');
  }

  static void comingSoon(String feature) {
    showInfo('$feature özelliği yakında eklenecek!', title: 'Yakında');
  }

  /// Error handling notifications
  static void networkError() {
    showError(
      'İnternet bağlantısı hatası. Lütfen bağlantınızı kontrol edin.',
      title: 'Bağlantı Hatası',
    );
  }

  static void unknownError() {
    showError(
      'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.',
      title: 'Hata',
    );
  }

  static void validationError(String message) {
    showWarning(message, title: 'Doğrulama Hatası');
  }

  static void permissionError() {
    showWarning(
      'Bu işlem için gerekli izin bulunmuyor.',
      title: 'İzin Hatası',
    );
  }

  /// Loading states
  static void showLoadingWithMessage(String message) {
    showLoading(message);
  }

  static void authOperationLoading() {
    showLoading('İşleminiz gerçekleştiriliyor...');
  }

  static void dataOperationLoading() {
    showLoading('Veriler işleniyor...');
  }

  static void fileOperationLoading() {
    showLoading('Dosya işleniyor...');
  }
}
