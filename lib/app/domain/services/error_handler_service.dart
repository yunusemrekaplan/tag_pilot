/// Error Handler Service Interface
/// SOLID: Interface Segregation - Sadece error handling operasyonları
/// SOLID: Single Responsibility - Sadece hata yönetimi
abstract class ErrorHandlerService {
  // Error message processing
  String getErrorMessage(dynamic error);
  String getFirebaseErrorMessage(dynamic error);
  String getAuthErrorMessage(dynamic error);
  String getFirestoreErrorMessage(dynamic error);

  // Error logging
  void logError(String title, dynamic error, {StackTrace? stackTrace});
  void logWarning(String message);
  void logInfo(String message);

  // Error reporting
  Future<void> reportError(dynamic error,
      {StackTrace? stackTrace, Map<String, dynamic>? context});

  // Error categories
  bool isNetworkError(dynamic error);
  bool isPermissionError(dynamic error);
  bool isNotFoundError(dynamic error);
  bool isValidationError(dynamic error);

  /// Merkezi hata bildirimi ve kullanıcıya gösterim fonksiyonu
  void handleAndNotify(
    dynamic error, {
    String? fallbackMessage,
    String? fallbackTitle,
    Duration? duration,
  });
}
