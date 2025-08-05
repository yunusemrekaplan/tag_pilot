import 'package:get/get.dart';
import '../../domain/services/error_handler_service.dart';
import '../../domain/services/auth_service.dart';
import '../utils/app_constants.dart';

/// Base Repository Class
/// Tüm repository'ler için ortak error handling ve utility fonksiyonları
/// SOLID: Single Responsibility - Sadece ortak repository operasyonları
abstract class BaseRepository {
  // Dependencies
  late final ErrorHandlerService _errorHandler;
  late final AuthService _authService;

  // Constructor
  BaseRepository() {
    _initializeDependencies();
  }

  /// Dependencies'leri initialize et
  void _initializeDependencies() {
    _errorHandler = Get.find<ErrorHandlerService>();
    _authService = Get.find<AuthService>();
  }

  /// Current user ID'yi al (null-safe)
  String get currentUserId {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('Kullanıcı oturumu açık değil');
    }
    return userId;
  }

  /// Current user ID'yi al (null döner)
  String? get currentUserIdOrNull => _authService.currentUserId;

  // ============================================================================
  // SAFE EXECUTION PATTERNS
  // ============================================================================

  /// Safe async execution with error handling
  Future<T> executeSafely<T>(
    Future<T> Function() operation, {
    required String operationName,
    String? customErrorMessage,
    bool logError = true,
  }) async {
    try {
      return await operation();
    } catch (e) {
      if (logError) {
        _errorHandler.logError(operationName, e);
      }

      final errorMessage =
          customErrorMessage ?? _errorHandler.getErrorMessage(e);

      throw Exception('$operationName hatası: $errorMessage');
    }
  }

  /// Safe void execution
  Future<void> executeSafelyVoid(
    Future<void> Function() operation, {
    required String operationName,
    String? customErrorMessage,
    bool logError = true,
  }) async {
    await executeSafely(
      operation,
      operationName: operationName,
      customErrorMessage: customErrorMessage,
      logError: logError,
    );
  }

  /// Safe execution with default return value
  Future<T> executeSafelyWithDefault<T>(
    Future<T> Function() operation, {
    required T defaultValue,
    required String operationName,
    bool logError = true,
  }) async {
    try {
      return await operation();
    } catch (e) {
      if (logError) {
        _errorHandler.logError(operationName, e);
      }
      return defaultValue;
    }
  }

  /// Safe list execution (boş liste döner hata durumunda)
  Future<List<T>> executeSafelyList<T>(
    Future<List<T>> Function() operation, {
    required String operationName,
    bool logError = true,
  }) async {
    return executeSafelyWithDefault(
      operation,
      defaultValue: <T>[],
      operationName: operationName,
      logError: logError,
    );
  }

  /// Safe nullable execution
  Future<T?> executeSafelyNullable<T>(
    Future<T> Function() operation, {
    required String operationName,
    bool logError = true,
  }) async {
    return executeSafelyWithDefault<T?>(
      operation,
      defaultValue: null,
      operationName: operationName,
      logError: logError,
    );
  }

  // ============================================================================
  // USER VALIDATION
  // ============================================================================

  /// User oturumu kontrol et
  void validateUserSession() {
    if (currentUserIdOrNull == null) {
      throw Exception('Kullanıcı oturumu açık değil');
    }
  }

  /// User ID'yi validate et
  void validateUserId(String? userId) {
    if (userId == null || userId.isEmpty) {
      throw Exception('Geçersiz kullanıcı ID');
    }
  }

  /// Current user ile karşılaştır
  void validateUserOwnership(String userId) {
    validateUserSession();
    if (userId != currentUserId) {
      throw Exception('Bu işlem için yetkiniz bulunmuyor');
    }
  }

  // ============================================================================
  // VALIDATION HELPERS
  // ============================================================================

  /// ID validation
  void validateId(String? id, String fieldName) {
    if (id == null || id.isEmpty) {
      throw Exception('$fieldName gerekli');
    }
  }

  /// Required field validation
  void validateRequired(dynamic value, String fieldName) {
    if (value == null) {
      throw Exception('$fieldName gerekli');
    }

    if (value is String && value.trim().isEmpty) {
      throw Exception('$fieldName gerekli');
    }
  }

  /// List validation
  void validateList<T>(List<T>? list, String fieldName, {int? minCount}) {
    if (list == null) {
      throw Exception('$fieldName gerekli');
    }

    if (minCount != null && list.length < minCount) {
      throw Exception('$fieldName en az $minCount öğe içermeli');
    }
  }

  /// Date range validation
  void validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      throw Exception('Başlangıç ve bitiş tarihleri gerekli');
    }

    if (startDate.isAfter(endDate)) {
      throw Exception('Başlangıç tarihi bitiş tarihinden önce olmalı');
    }
  }

  /// Amount validation
  void validateAmount(double? amount, String fieldName,
      {double? min, double? max}) {
    validateRequired(amount, fieldName);

    if (amount! <= 0) {
      throw Exception('$fieldName 0\'dan büyük olmalı');
    }

    if (min != null && amount < min) {
      throw Exception('$fieldName en az $min olmalı');
    }

    if (max != null && amount > max) {
      throw Exception('$fieldName en fazla $max olmalı');
    }
  }

  // ============================================================================
  // LOGGING HELPERS
  // ============================================================================

  /// Success log
  void logSuccess(String operation, {String? details}) {
    if (AppConstants.enableLogging) {
      final message = details != null ? '$operation: $details' : operation;
      print('✅ ${runtimeType.toString()}: $message');
    }
  }

  /// Info log
  void logInfo(String message) {
    if (AppConstants.enableLogging) {
      print('ℹ️ ${runtimeType.toString()}: $message');
    }
  }

  /// Warning log
  void logWarning(String message) {
    if (AppConstants.enableLogging) {
      print('⚠️ ${runtimeType.toString()}: $message');
    }
  }

  // ============================================================================
  // COLLECTION PATH HELPERS
  // ============================================================================

  /// User collection path'ini oluştur
  String getUserCollectionPath(String collection) {
    return '${DatabaseConstants.usersCollection}/$currentUserId/$collection';
  }

  /// Document path'ini oluştur
  String getDocumentPath(String collection, String documentId) {
    return '${getUserCollectionPath(collection)}/$documentId';
  }

  /// Global collection path (user-specific olmayan)
  String getGlobalCollectionPath(String collection) {
    return collection;
  }

  /// Global document path
  String getGlobalDocumentPath(String collection, String documentId) {
    return '$collection/$documentId';
  }

  // ============================================================================
  // QUERY HELPERS
  // ============================================================================

  /// Pagination parameters
  Map<String, dynamic> getPaginationParams({
    int? limit,
    String? orderBy,
    bool descending = false,
    dynamic startAfter,
  }) {
    final Map<String, dynamic> params = {
      'limit': limit,
      'orderBy': orderBy,
      'descending': descending,
      'startAfter': startAfter,
    };

    // Remove null values
    params.removeWhere((key, value) => value == null);
    return params;
  }

  /// Date range query parameters
  Map<String, dynamic> getDateRangeParams(
      DateTime startDate, DateTime endDate) {
    validateDateRange(startDate, endDate);
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  // ============================================================================
  // TIMESTAMP HELPERS
  // ============================================================================

  /// Create timestamp map
  Map<String, dynamic> createTimestamps() {
    final now = DateTime.now().toIso8601String();
    return {
      'createdAt': now,
      'updatedAt': now,
    };
  }

  /// Update timestamp map
  Map<String, dynamic> updateTimestamps() {
    return {
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Add timestamps to data
  Map<String, dynamic> withCreateTimestamps(Map<String, dynamic> data) {
    return {
      ...data,
      ...createTimestamps(),
    };
  }

  /// Add update timestamp to data
  Map<String, dynamic> withUpdateTimestamps(Map<String, dynamic> data) {
    return {
      ...data,
      ...updateTimestamps(),
    };
  }
}

/// Repository mixin for common CRUD operations
mixin CrudRepositoryMixin<T> on BaseRepository {
  /// Model'dan JSON'a çevirme fonksiyonu (implement edilmeli)
  Map<String, dynamic> modelToJson(T model);

  /// JSON'dan model'a çevirme fonksiyonu (implement edilmeli)
  T jsonToModel(Map<String, dynamic> json, String id);

  /// Collection adı (implement edilmeli)
  String get collectionName;

  /// Create operation with error handling
  Future<void> createItem(T item, String id) async {
    await executeSafelyVoid(
      () async {
        final data = modelToJson(item);
        final dataWithTimestamps = withCreateTimestamps(data);
        // Database implementation burada olacak
        logSuccess('Item created', details: id);
      },
      operationName: 'Create $collectionName',
    );
  }

  /// Get by ID operation with error handling
  Future<T?> getItemById(String id) async {
    return executeSafelyNullable(
      () async {
        validateId(id, 'ID');
        // Database implementation burada olacak
        // Dummy return for now
        throw UnimplementedError('Database implementation needed');
      },
      operationName: 'Get $collectionName by ID',
    );
  }

  /// Update operation with error handling
  Future<void> updateItem(String id, T item) async {
    await executeSafelyVoid(
      () async {
        validateId(id, 'ID');
        final data = modelToJson(item);
        final dataWithTimestamps = withUpdateTimestamps(data);
        // Database implementation burada olacak
        logSuccess('Item updated', details: id);
      },
      operationName: 'Update $collectionName',
    );
  }

  /// Delete operation with error handling
  Future<void> deleteItem(String id) async {
    await executeSafelyVoid(
      () async {
        validateId(id, 'ID');
        // Database implementation burada olacak
        logSuccess('Item deleted', details: id);
      },
      operationName: 'Delete $collectionName',
    );
  }
}
