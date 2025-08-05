import 'package:get/get.dart';

import '../../core/utils/app_constants.dart';
import '../../domain/repositories/user_preferences_repository.dart';
import '../../domain/services/database_service.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/error_handler_service.dart';
import '../models/user_preferences_model.dart';

/// User Preferences Repository Implementation (Clean Architecture)
/// SOLID: Dependency Inversion - UserPreferencesRepository interface'ini implement eder
/// SOLID: Single Responsibility - Sadece user preferences data operations
class UserPreferencesRepositoryImpl implements UserPreferencesRepository {
  late final DatabaseService _databaseService;
  late final AuthService _authService;
  late final ErrorHandlerService _errorHandler;

  UserPreferencesRepositoryImpl() {
    _databaseService = Get.find<DatabaseService>();
    _authService = Get.find<AuthService>();
    _errorHandler = Get.find<ErrorHandlerService>();
  }

  // Middleware kontrolü yaptığı için ! operatörü güvenli
  String get _userId => _authService.currentUserId!;

  // ============================================================================
  // CRUD OPERATIONS
  // ============================================================================

  @override
  Future<UserPreferencesModel?> getUserPreferences(String userId) async {
    try {
      final doc = await _databaseService.getDocumentById(
        '${DatabaseConstants.usersCollection}/$userId/${DatabaseConstants.preferencesCollection}/settings',
      );

      if (doc.exists && doc.data() != null) {
        return UserPreferencesModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }

      return null;
    } catch (e) {
      _errorHandler.logError('Get user preferences', e);
      return null;
    }
  }

  @override
  Future<void> saveUserPreferences(UserPreferencesModel preferences) async {
    try {
      final preferencesWithTimestamp = preferences.copyWith(
        updatedAt: DateTime.now(),
      );

      await _databaseService.setDocument(
        '${DatabaseConstants.usersCollection}/${preferences.userId}/${DatabaseConstants.preferencesCollection}/settings',
        preferencesWithTimestamp.toJson(),
      );

      if (AppConstants.enableLogging) {
        print('✅ User preferences saved: ${preferences.userId}');
      }
    } catch (e) {
      _errorHandler.logError('Save user preferences', e);
      throw Exception('Kullanıcı tercihleri kaydedilirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<void> updateDailyTarget(String userId, double dailyTarget) async {
    try {
      final currentPreferences = await getUserPreferences(userId);

      if (currentPreferences != null) {
        final updatedPreferences = currentPreferences.copyWith(
          dailyTarget: dailyTarget,
          updatedAt: DateTime.now(),
        );
        await saveUserPreferences(updatedPreferences);
      } else {
        // Yeni preferences oluştur
        final newPreferences = UserPreferencesModel(
          id: 'settings',
          userId: userId,
          dailyTarget: dailyTarget,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await saveUserPreferences(newPreferences);
      }

      if (AppConstants.enableLogging) {
        print('✅ Daily target updated: $dailyTarget for user: $userId');
      }
    } catch (e) {
      _errorHandler.logError('Update daily target', e);
      throw Exception('Günlük hedef güncellenirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<void> updateDefaultVehicleId(String userId, String? vehicleId) async {
    try {
      final currentPreferences = await getUserPreferences(userId);

      if (currentPreferences != null) {
        final updatedPreferences = currentPreferences.copyWith(
          defaultVehicleId: vehicleId,
          updatedAt: DateTime.now(),
        );
        await saveUserPreferences(updatedPreferences);
      } else {
        // Yeni preferences oluştur
        final newPreferences = UserPreferencesModel(
          id: 'settings',
          userId: userId,
          defaultVehicleId: vehicleId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await saveUserPreferences(newPreferences);
      }

      if (AppConstants.enableLogging) {
        print('✅ Default vehicle updated: $vehicleId for user: $userId');
      }
    } catch (e) {
      _errorHandler.logError('Update default vehicle', e);
      throw Exception('Varsayılan araç güncellenirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<void> updateNotificationSettings(String userId, bool enabled) async {
    try {
      final currentPreferences = await getUserPreferences(userId);

      if (currentPreferences != null) {
        final updatedPreferences = currentPreferences.copyWith(
          notificationsEnabled: enabled,
          updatedAt: DateTime.now(),
        );
        await saveUserPreferences(updatedPreferences);
      } else {
        // Yeni preferences oluştur
        final newPreferences = UserPreferencesModel(
          id: 'settings',
          userId: userId,
          notificationsEnabled: enabled,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await saveUserPreferences(newPreferences);
      }

      if (AppConstants.enableLogging) {
        print('✅ Notification settings updated: $enabled for user: $userId');
      }
    } catch (e) {
      _errorHandler.logError('Update notification settings', e);
      throw Exception('Bildirim ayarları güncellenirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<void> deleteUserPreferences(String userId) async {
    try {
      await _databaseService.deleteDocument(
        '${DatabaseConstants.usersCollection}/$userId/${DatabaseConstants.preferencesCollection}/settings',
      );

      if (AppConstants.enableLogging) {
        print('✅ User preferences deleted: $userId');
      }
    } catch (e) {
      _errorHandler.logError('Delete user preferences', e);
      throw Exception('Kullanıcı tercihleri silinirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }
}
